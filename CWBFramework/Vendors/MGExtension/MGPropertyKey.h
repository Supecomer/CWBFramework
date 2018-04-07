//
//  MGPropertyKey.h
//  MGExtensionExample
//
//  Created by MG Lee on 15/8/11.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MGPropertyKeyTypeDictionary = 0, // 字典的key
    MGPropertyKeyTypeArray // 数组的key
} MGPropertyKeyType;

/**
 *  属性的key
 */
@interface MGPropertyKey : NSObject
/** key的名字 */
@property (copy,   nonatomic) NSString *name;
/** key的种类，可能是@"10"，可能是@"age" */
@property (assign, nonatomic) MGPropertyKeyType type;

/**
 *  根据当前的key，也就是name，从object（字典或者数组）中取值
 */
- (id)valueInObject:(id)object;

@end
