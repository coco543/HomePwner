//
//  ItemStore.m
//  HomePwner
//
//  Created by 郑克明 on 15/11/24.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "ItemStore.h"
#import "ImageStore.h"
@import CoreData;

@interface ItemStore ()
@property (nonatomic, strong) NSMutableArray *privateItems;
@property (nonatomic, strong) NSMutableArray *allAssetTypes;
/*Core Data 的使用方法如下 -P 440
 NSManagedObjectContext 负责应用和数据库之间的互交工作
 通过NSManagedObjectContext对象所使用的NSPersistentStoreCoordinator,可以打开指定的SQLite文件.NSPersistentStoreCoordinatord对象需要 NSManagedObjectModel的配合才能工作
 */
@property (nonatomic, strong) NSManagedObjectContext *content;
@property (nonatomic, strong) NSManagedObjectModel *model;
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
        /*NSString *path = [self itemArchivePath];
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!_privateItems) {
            _privateItems = [[NSMutableArray alloc] init];
            NSLog(@"Init new items");
        }*/
        //读取HomePwner.xcdatamodeld
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        //设置SQL文件路径
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            @throw [NSException exceptionWithName:@"OpenFailure" reason:[error localizedDescription] userInfo:nil];
        }
        
        //创建NSManagedObjectContext
        _content = [[NSManagedObjectContext alloc] init];
        _content.persistentStoreCoordinator = psc;
        
        [self loadAllItems];
        
    }
    return self;
}

//外部得到的privateItems是一个不可修改的数组,而内部的privateItems则是一个可以修改的数组
//不过要注意,外部仍然可以把返回的数组转型成可变的,但是这个就违反了编程约定.
-(NSArray *)allItems{
    return self.privateItems;
}

-(BNRItem *)createItem{
//    BNRItem *item = [BNRItem randomItem];
//    BNRItem *item = [[BNRItem alloc] init];
    
    //使用Core Data获取新对象
    //double 方便排序.插入某个位置时,值去前后元素排序值的中值即可
    double order;
    if ([self.allItems count] == 0) {
        order = 1.0;
    }else{
        order = [[self.allItems lastObject] orderingValue] + 1.0;
    }
    NSLog(@"Adding after %lu items,order = %.2f", (unsigned long)[self.privateItems count], order);
    
    BNRItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"BNRItem" inManagedObjectContext:self.content];
    item.orderingValue = order;
    
    [[self privateItems] addObject:item];
    return item;
}

-(void)removeItem:(BNRItem *)item{
    
    NSString *key = item.itemKey;
    [[ImageStore sharedStore] deleteImageForKey:key];
    
    [self.content deleteObject:item];
    [self.privateItems removeObjectIdenticalTo:item];
}

-(void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex{
    
    if(fromIndex == toIndex){
        return;
    }
    BNRItem *item = self.privateItems[fromIndex];
    [self removeItem:item];
    [self.privateItems insertObject:item atIndex:toIndex];
    //移动后,计算新的order
    double lowerBound = 0.0, upperBound = 0.0;
    //判断对象前后是否有元素
    if (toIndex > 0) {
        lowerBound = [self.privateItems[toIndex - 1] orderingValue];
    }else{
        lowerBound = [self.privateItems[1] orderingValue] - 2.0;
    }
    if (toIndex < ([self.privateItems count] -1 )) {
        upperBound = [self.privateItems[(toIndex - 1)] orderingValue];
    }else{
        upperBound = [self.privateItems[(toIndex - 1)] orderingValue] + 2.0;
    }
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    NSLog(@"moving to order %f",newOrderValue);
    item.orderingValue = newOrderValue;
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
    
//    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}


//这个方法进入后台时会被自动调用
- (BOOL)saveChanges{
//    NSString *path = [self itemArchivePath];
//    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
    NSError *error;
    BOOL successful = [self.content save:&error];
    
    if (!successful) {
        NSLog(@"Error saving:%@",[error localizedDescription]);
    }
    return successful;
}

//一次取出所有对象
- (void)loadAllItems{
    if (!self.privateItems) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"BNRItem" inManagedObjectContext:self.content];
        request.entity = e;
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
        
        request.sortDescriptors = @[sd];
        NSError *error;
        NSArray *result = [self.content executeFetchRequest:request error:&error];
        
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason %@",[error localizedDescription]];
        }
        self.privateItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (NSArray *)allAssetTypes{
    if (!_allAssetTypes) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [NSEntityDescription entityForName:@"BNRAssetType" inManagedObjectContext:self.content];
        request.entity = e;
        
        NSError *error;
        NSArray *result = [self.content executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@",[error localizedDescription]];
        }
        _allAssetTypes = [result mutableCopy];
        
        //第一次运行
        if ([_allAssetTypes count] == 0) {
            NSManagedObject *type;
            type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:self.content];
            [type setValue:@"Furniture" forKey:@"label"];
            [_allAssetTypes addObject:type];
            
            type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:self.content];
            [type setValue:@"Jewelry" forKey:@"label"];
            [_allAssetTypes addObject:type];
            
            type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:self.content];
            [type setValue:@"Electronics" forKey:@"label"];
            [_allAssetTypes addObject:type];
        }
    }
    return _allAssetTypes;
}

-(void)addNewAssetType:(NSString *)typeName {
    if (![typeName length]) {
        return;
    }
    NSManagedObject *type;
    type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:self.content];
    [type setValue:typeName forKey:@"label"];
    [_allAssetTypes addObject:type];
}

@end



