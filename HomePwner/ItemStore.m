//
//  ItemStore.m
//  HomePwner
//
//  Created by 郑克明 on 15/11/24.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "ItemStore.h"
#import "ImageStore.h"
@interface ItemStore ()
@property (nonatomic,strong) NSMutableArray *privateItems;
@end

@implementation ItemStore

+(instancetype) sharedStore{
    static ItemStore *sharedStore = nil;
//    if(!sharedStore){
//        sharedStore = [[self alloc] initPrivate];
//    }
    //上面代码在多线程同时触发时候可能创建多个sharedStore,所以需要修改
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedStore = [[self alloc] initPrivate];
    });
    return sharedStore;
}


//提醒用户要使用 initPrivate初始化
-(instancetype) init{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[ItemStore initPrivate]" userInfo:nil];
}

//必须调用这个方法去初始化(私有的,外部无法调用,保证了外部只能通过sharedStore获取对象,从而实现单例模式)
-(instancetype) initPrivate{
    self = [super init];
    if(self){
        
        //尝试从固化文件中解固保存的对象
        NSString *path = [self itemArchivePath];
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!_privateItems) {
            _privateItems = [[NSMutableArray alloc] init];
            NSLog(@"Init new items");
        }
    }
    return self;
}

//外部得到的privateItems是一个不可修改的数组,而内部的privateItems则是一个可以修改的数组
//不过要注意,外部仍然可以把返回的数组转型成可变的,但是这个就违反了编程约定.
-(NSArray *)allItems{
    return self.privateItems;
}

-(BNRItem *)createItem{
    BNRItem *item = [BNRItem randomItem];
    [[self privateItems] addObject:item];
    return item;
}

-(void)removeItem:(BNRItem *)item{
    
    NSString *key = item.itemKey;
    [[ImageStore sharedStore] deleteImageForKey:key];
    
    [self.privateItems removeObjectIdenticalTo:item];
}

-(void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex{
    
    if(fromIndex == toIndex){
        return;
    }
    BNRItem *item = self.privateItems[fromIndex];
    [self removeItem:item];
    [self.privateItems insertObject:item atIndex:toIndex];
    
}

#pragma mark - 固化相关

/**
 *  获取Items对象的保存路径 保存到沙盒的Document文件夹下
 *
 *  @return NSString* 路径
 */
- (NSString *)itemArchivePath{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSLog(@"documentDirectories = %@",documentDirectories);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (BOOL)saveChanges{
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
}
@end
