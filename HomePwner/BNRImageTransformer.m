//
//  BNRImageTransformer.m
//  HomePwner
//
//  Created by 郑克明 on 16/1/8.
//  Copyright © 2016年 郑克明. All rights reserved.
//

#import "BNRImageTransformer.h"

@implementation BNRImageTransformer

//转化之后的类型
+ (Class)transformedValueClass{
    return [NSData class];
}

- (id)transformedValue:(id)value{
    if (!value) {
        return nil;
    }
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value{
    return [UIImage imageWithData:value];
}

@end
