//
//  CALayer+MGYYWebImage.h
//  MGYYWebImage <MGYYWebImage>
//
//  Created by ciome on 15/2/23.
//  Copyright (c) 2015 ciome.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MGYYWebImageManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Web image methods for CALayer.
 It will set image to layer.contents.
 */
@interface CALayer (MGYYWebImage)

#pragma mark - image

/**
 Current image URL.
 
 @discussion Set a new value to this property will cancel the previous request
 operation and create a new request operation to fetch image. Set nil to clear
 the image and image URL.
 */
@property (nullable, nonatomic, strong) NSURL *MGYY_imageURL;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL    The image url (remote or local file path).
 @param placeholder The image to be set initially, until the image request finishes.
 */
- (void)MGYY_setImageWithURL:(nullable NSURL *)imageURL placeholder:(nullable UIImage *)placeholder;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL The image url (remote or local file path).
 @param options  The options to use when request the image.
 */
- (void)MGYY_setImageWithURL:(nullable NSURL *)imageURL options:(MGYYWebImageOptions)options;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL    The image url (remote or local file path).
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)MGYY_setImageWithURL:(nullable NSURL *)imageURL
               placeholder:(nullable UIImage *)placeholder
                   options:(MGYYWebImageOptions)options
                completion:(nullable MGYYWebImageCompletionBlock)completion;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL    The image url (remote or local file path).
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param progress    The block invoked (on main thread) during image request.
 @param transform   The block invoked (on background thread) to do additional image process.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)MGYY_setImageWithURL:(nullable NSURL *)imageURL
               placeholder:(nullable UIImage *)placeholder
                   options:(MGYYWebImageOptions)options
                  progress:(nullable MGYYWebImageProgressBlock)progress
                 transform:(nullable MGYYWebImageTransformBlock)transform
                completion:(nullable MGYYWebImageCompletionBlock)completion;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL    The image url (remote or local file path).
 @param placeholder he image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param manager     The manager to create image request operation.
 @param progress    The block invoked (on main thread) during image request.
 @param transform   The block invoked (on background thread) to do additional image process.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)MGYY_setImageWithURL:(nullable NSURL *)imageURL
               placeholder:(nullable UIImage *)placeholder
                   options:(MGYYWebImageOptions)options
                   manager:(nullable MGYYWebImageManager *)manager
                  progress:(nullable MGYYWebImageProgressBlock)progress
                 transform:(nullable MGYYWebImageTransformBlock)transform
                completion:(nullable MGYYWebImageCompletionBlock)completion;

/**
 Cancel the current image request.
 */
- (void)MGYY_cancelCurrentImageRequest;

@end

NS_ASSUME_NONNULL_END
