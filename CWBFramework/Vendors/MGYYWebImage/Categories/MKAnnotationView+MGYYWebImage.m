//
//  MKAnnotationView+MGYYWebImage.m
//  MGYYWebImage <MGYYWebImage>
//
//  Created by ciome on 15/2/23.
//  Copyright (c) 2015 ciome.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MKAnnotationView+MGYYWebImage.h"
#import "MGYYWebImageOperation.h"
#import "_MGYYWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface MKAnnotationView_MGYYWebImage : NSObject @end
@implementation MKAnnotationView_MGYYWebImage @end


static int _MGYYWebImageSetterKey;

@implementation MKAnnotationView (MGYYWebImage)

- (NSURL *)MGYY_imageURL {
    _MGYYWebImageSetter *setter = objc_getAssociatedObject(self, &_MGYYWebImageSetterKey);
    return setter.imageURL;
}

- (void)setMGYY_imageURL:(NSURL *)imageURL {
    [self MGYY_setImageWithURL:imageURL
              placeholder:nil
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self MGYY_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:kNilOptions
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL options:(MGYYWebImageOptions)options {
    [self MGYY_setImageWithURL:imageURL
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(MGYYWebImageOptions)options
                completion:(MGYYWebImageCompletionBlock)completion {
    [self MGYY_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(MGYYWebImageOptions)options
                  progress:(MGYYWebImageProgressBlock)progress
                 transform:(MGYYWebImageTransformBlock)transform
                completion:(MGYYWebImageCompletionBlock)completion {
    [self MGYY_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(MGYYWebImageOptions)options
                   manager:(MGYYWebImageManager *)manager
                  progress:(MGYYWebImageProgressBlock)progress
                 transform:(MGYYWebImageTransformBlock)transform
                completion:(MGYYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [MGYYWebImageManager sharedManager];
    
    _MGYYWebImageSetter *setter = objc_getAssociatedObject(self, &_MGYYWebImageSetterKey);
    if (!setter) {
        setter = [_MGYYWebImageSetter new];
        objc_setAssociatedObject(self, &_MGYYWebImageSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _MGYY_dispatch_sync_on_main_queue(^{
        if ((options & MGYYWebImageOptionSetImageWithFadeAnimation) &&
            !(options & MGYYWebImageOptionAvoidSetImage)) {
            if (!self.highlighted) {
                [self.layer removeAnimationForKey:_MGYYWebImageFadeAnimationKey];
            }
        }
        if (!imageURL) {
            if (!(options & MGYYWebImageOptionIgnorePlaceHolder)) {
                self.image = placeholder;
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & MGYYWebImageOptionUseNSURLCache) &&
            !(options & MGYYWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:MGYYImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & MGYYWebImageOptionAvoidSetImage)) {
                self.image = imageFromMemory;
            }
            if(completion) completion(imageFromMemory, imageURL, MGYYWebImageFromMemoryCacheFast, MGYYWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & MGYYWebImageOptionIgnorePlaceHolder)) {
            self.image = placeholder;
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([_MGYYWebImageSetter setterQueue], ^{
            MGYYWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            MGYYWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, MGYYWebImageFromType from, MGYYWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == MGYYWebImageStageFinished || stage == MGYYWebImageStageProgress) && image && !(options & MGYYWebImageOptionAvoidSetImage);
                BOOL showFade = ((options & MGYYWebImageOptionSetImageWithFadeAnimation) && !self.highlighted);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == MGYYWebImageStageFinished ? _MGYYWebImageFadeTime : _MGYYWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self.layer addAnimation:transition forKey:_MGYYWebImageFadeAnimationKey];
                        }
                        self.image = image;
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, MGYYWebImageFromNone, MGYYWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)MGYY_cancelCurrentImageRequest {
    _MGYYWebImageSetter *setter = objc_getAssociatedObject(self, &_MGYYWebImageSetterKey);
    if (setter) [setter cancel];
}

@end
