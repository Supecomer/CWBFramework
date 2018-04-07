//
//  MGYYSentinel.m
//  MGYYKit 
//  Created by ciome on 15/4/13.
//  Copyright (c) 2015 ciome.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MGYYSentinel.h"
#import <libkern/OSAtomic.h>

@implementation MGYYSentinel {
    int32_t _value;
}

- (int32_t)value {
    return _value;
}

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end
