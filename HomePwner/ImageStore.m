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
//必须调用这个方法去初始化(私有的,外部无法调用,保证了外部只能通过sharedStore获取对象,从而实现单例模式)
- (instancetype)initPrivate{
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc]init];
    }
    
    //把当前对象设置为低内存警告的观察者,用来获取通知信息 P358
    //通知中心只有一个
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //最后一个参数的作用是指定发送消息的对象,nil表示接受任何对象来的发送消息
    [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    return self;
}

- (void)setImage:(UIImage *)image forkey:(NSString *)key{
    //[self.dictionary setObject:image forKey:key];
    self.dictionary[key] = image;
    
    NSString *imagePath = [self imagePathForKey:key];
    
    //从图片提取出JPEG格式的数据
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    [data writeToFile:imagePath atomically:YES];
}

-(UIImage *)imageForKey:(NSString *)key{
    //return [self.dictionary objectForKey:key];
//    return self.dictionary[key];
    
    UIImage *result = self.dictionary[key];
    if (!result) {
        NSString *imagePath = [self imagePathForKey:key];
        result = [UIImage imageWithContentsOfFile:imagePath];
        
        if (result) {
            self.dictionary[key] = result;
        }else{
            NSLog(@"unable to find %@",[self imagePathForKey:key]);
        }
    }
    return result;
}

-(void)deleteImageForKey:(NSString *)key{
    if(!key){
        return;
    }
    [self.dictionary removeObjectForKey:key];
    
    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

#pragma mark - 固化操作
- (NSString *)imagePathForKey:(NSString *)key {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void)clearCache:(NSNotificationCenter *)note{
    NSLog(@"flushing %lu images out of the cache",(unsigned long)[self.dictionary count]);
    [self.dictionary removeAllObjects];
}


@end
