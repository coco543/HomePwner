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

//必须调用这个方法去初始化
-(instancetype) initPrivate{
    self = [super init];
    if(self){
        _privateItems = [[NSMutableArray alloc] init];
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
@end
