//
//  ImageStore.h
//  HomePwner
//
//  Created by 郑克明 on 15/12/1.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageStore : NSObject

+ (instancetype)sharedStore;
- (void)setImage:(UIImage *)image forkey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;

- (NSString *)imagePathForKey:(NSString *)key;
@end
