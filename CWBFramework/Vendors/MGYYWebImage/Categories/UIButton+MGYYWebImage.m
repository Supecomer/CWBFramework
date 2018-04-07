//
//  UIButton+MGYYWebImage.m
//  MGYYWebImage <MGYYWebImage>
//
//  Created by ciome on 15/2/23.
//  Copyright (c) 2015 ciome.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIButton+MGYYWebImage.h"
#import "MGYYWebImageOperation.h"
#import "_MGYYWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface UIButton_MGYYWebImage : NSObject @end
@implementation UIButton_MGYYWebImage @end

static inline NSNumber *UIControlStateSingle(UIControlState state) {
    if (state & UIControlStateHighlighted) return @(UIControlStateHighlighted);
    if (state & UIControlStateDisabled) return @(UIControlStateDisabled);
    if (state & UIControlStateSelected) return @(UIControlStateSelected);
    return @(UIControlStateNormal);
}

static inline NSArray *UIControlStateMulti(UIControlState state) {
    NSMutableArray *array = [NSMutableArray new];
    if (state & UIControlStateHighlighted) [array addObject:@(UIControlStateHighlighted)];
    if (state & UIControlStateDisabled) [array addObject:@(UIControlStateDisabled)];
    if (state & UIControlStateSelected) [array addObject:@(UIControlStateSelected)];
    if ((state & 0xFF) == 0) [array addObject:@(UIControlStateNormal)];
    return array;
}

static int _MGYYWebImageSetterKey;
static int _MGYYWebImageBackgroundSetterKey;


@interface _MGYYWebImageSetterDicForButton : NSObject
- (_MGYYWebImageSetter *)setterForState:(NSNumber *)state;
- (_MGYYWebImageSetter *)lazySetterForState:(NSNumber *)state;
@end

@implementation _MGYYWebImageSetterDicForButton {
    NSMutableDictionary *_dic;
    dispatch_semaphore_t _lock;
}
- (instancetype)init {
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    _dic = [NSMutableDictionary new];
    return self;
}
- (_MGYYWebImageSetter *)setterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _MGYYWebImageSetter *setter = _dic[state];
    dispatch_semaphore_signal(_lock);
    return setter;
    
}
- (_MGYYWebImageSetter *)lazySetterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _MGYYWebImageSetter *setter = _dic[state];
    if (!setter) {
        setter = [_MGYYWebImageSetter new];
        _dic[state] = setter;
    }
    dispatch_semaphore_signal(_lock);
    return setter;
}
@end


@implementation UIButton (MGYYWebImage)

#pragma mark - image

- (void)_MGYY_setImageWithURL:(NSURL *)imageURL
             forSingleState:(NSNumber *)state
                placeholder:(UIImage *)placeholder
                    options:(MGYYWebImageOptions)options
                    manager:(MGYYWebImageManager *)manager
                   progress:(MGYYWebImageProgressBlock)progress
                  transform:(MGYYWebImageTransformBlock)transform
                 completion:(MGYYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [MGYYWebImageManager sharedManager];
    
    _MGYYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_MGYYWebImageSetterKey);
    if (!dic) {
        dic = [_MGYYWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_MGYYWebImageSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _MGYYWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _MGYY_dispatch_sync_on_main_queue(^{
        if (!imageURL) {
            if (!(options & MGYYWebImageOptionIgnorePlaceHolder)) {
                [self setImage:placeholder forState:state.integerValue];
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
                [self setImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, MGYYWebImageFromMemoryCacheFast, MGYYWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & MGYYWebImageOptionIgnorePlaceHolder)) {
            [self setImage:placeholder forState:state.integerValue];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setImage:image forState:state.integerValue];
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

- (void)_MGYY_cancelImageRequestForSingleState:(NSNumber *)state {
    _MGYYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_MGYYWebImageSetterKey);
    _MGYYWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)MGYY_imageURLForState:(UIControlState)state {
    _MGYYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_MGYYWebImageSetterKey);
    _MGYYWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder {
    [self MGYY_setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
                   options:(MGYYWebImageOptions)options {
    [self MGYY_setImageWithURL:imageURL
                    forState:state
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(MGYYWebImageOptions)options
                completion:(MGYYWebImageCompletionBlock)completion {
    [self MGYY_setImageWithURL:imageURL
                    forState:state
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(MGYYWebImageOptions)options
                  progress:(MGYYWebImageProgressBlock)progress
                 transform:(MGYYWebImageTransformBlock)transform
                completion:(MGYYWebImageCompletionBlock)completion {
    [self MGYY_setImageWithURL:imageURL
                    forState:state
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)MGYY_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(MGYYWebImageOptions)options
                   manager:(MGYYWebImageManager *)manager
                  progress:(MGYYWebImageProgressBlock)progress
                 transform:(MGYYWebImageTransformBlock)transform
                completion:(MGYYWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _MGYY_setImageWithURL:imageURL
                   forSingleState:num
                      placeholder:placeholder
                          options:options
                          manager:manager
                         progress:progress
                        transform:transform
                       completion:completion];
    }
}

- (void)MGYY_cancelImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _MGYY_cancelImageRequestForSingleState:num];
    }
}


#pragma mark - background image

- (void)_MGYY_setBackgroundImageWithURL:(NSURL *)imageURL
                       forSingleState:(NSNumber *)state
                          placeholder:(UIImage *)placeholder
                              options:(MGYYWebImageOptions)options
                              manager:(MGYYWebImageManager *)manager
                             progress:(MGYYWebImageProgressBlock)progress
                            transform:(MGYYWebImageTransformBlock)transform
                           completion:(MGYYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [MGYYWebImageManager sharedManager];
    
    _MGYYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_MGYYWebImageBackgroundSetterKey);
    if (!dic) {
        dic = [_MGYYWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_MGYYWebImageBackgroundSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _MGYYWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _MGYY_dispatch_sync_on_main_queue(^{
        if (!imageURL) {
            if (!(options & MGYYWebImageOptionIgnorePlaceHolder)) {
                [self setBackgroundImage:placeholder forState:state.integerValue];
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
                [self setBackgroundImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, MGYYWebImageFromMemoryCacheFast, MGYYWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & MGYYWebImageOptionIgnorePlaceHolder)) {
            [self setBackgroundImage:placeholder forState:state.integerValue];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setBackgroundImage:image forState:state.integerValue];
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

- (void)_MGYY_cancelBackgroundImageRequestForSingleState:(NSNumber *)state {
    _MGYYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_MGYYWebImageBackgroundSetterKey);
    _MGYYWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)MGYY_backgroundImageURLForState:(UIControlState)state {
    _MGYYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_MGYYWebImageBackgroundSetterKey);
    _MGYYWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)MGYY_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder {
    [self MGYY_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:kNilOptions
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:nil];
}

- (void)MGYY_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                             options:(MGYYWebImageOptions)options {
    [self MGYY_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:nil
                               options:options
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:nil];
}

- (void)MGYY_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(MGYYWebImageOptions)options
                          completion:(MGYYWebImageCompletionBlock)completion {
    [self MGYY_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:options
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:completion];
}

- (void)MGYY_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(MGYYWebImageOptions)options
                            progress:(MGYYWebImageProgressBlock)progress
                           transform:(MGYYWebImageTransformBlock)transform
                          completion:(MGYYWebImageCompletionBlock)completion {
    [self MGYY_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:options
                               manager:nil
                              progress:progress
                             transform:transform
                            completion:completion];
}

- (void)MGYY_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(MGYYWebImageOptions)options
                             manager:(MGYYWebImageManager *)manager
                            progress:(MGYYWebImageProgressBlock)progress
                           transform:(MGYYWebImageTransformBlock)transform
                          completion:(MGYYWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _MGYY_setBackgroundImageWithURL:imageURL
                             forSingleState:num
                                placeholder:placeholder
                                    options:options
                                    manager:manager
                                   progress:progress
                                  transform:transform
                                 completion:completion];
    }
}

- (void)MGYY_cancelBackgroundImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _MGYY_cancelBackgroundImageRequestForSingleState:num];
    }
}

@end
