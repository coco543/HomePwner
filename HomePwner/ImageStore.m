//
//  ImageStore.m
//  HomePwner
//
//  Created by 郑克明 on 15/12/1.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "ImageStore.h"

@interface ImageStore()
@property (nonatomic,strong) NSMutableDictionary *dictionary;
@end

@implementation ImageStore
+ (instancetype)sharedStore{
    static ImageStore *sharedStore = nil;
    
//    if (!sharedStore) {
//        sharedStore = [[self alloc] initPrivate];
//    }
    //上面代码在多线程同时触发时候可能创建多个sharedStore,所以需要修改
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedStore = [[self alloc] initPrivate];
    });
    return sharedStore;
}

-(instancetype)init{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[ImageStore sharedStore]" userInfo:nil];
    return nil;
}
- (instancetype)initPrivate{
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)setImage:(UIImage *)image forkey:(NSString *)key{
    //[self.dictionary setObject:image forKey:key];
    self.dictionary[key] = image;
}

-(UIImage *)imageForKey:(NSString *)key{
    //return [self.dictionary objectForKey:key];
    return self.dictionary[key];
}

-(void)deleteImageForKey:(NSString *)key{
    if(!key){
        return;
    }
    [self.dictionary removeObjectForKey:key];
}



@end
