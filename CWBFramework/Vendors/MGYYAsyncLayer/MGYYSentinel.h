//
//  MGYYSentinel.h
//  MGYYKit 
//
//  Created by ciome on 15/4/13.
//  Copyright (c) 2015 ciome.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 MGYYSentinel is a thread safe incrementing counter.
 It may be used in some multi-threaded situation.
 */
@interface MGYYSentinel : NSObject

/// Returns the current value of the counter.
@property (readonly) int32_t value;

/// Increase the value atomically.
/// @return The new value.
- (int32_t)increase;

@end

NS_ASSUME_NONNULL_END
