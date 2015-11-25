//
//  ItemsViewController.m
//  HomePwner
//
//  Created by 郑克明 on 15/11/24.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "ItemsViewController.h"
#import "ItemStore.h"
#import "BNRItem.h"
@interface ItemsViewController()
@property (nonatomic) NSInteger bigItemsCount;
@property (nonatomic) NSArray *sortedItmes;
@end
@implementation ItemsViewController{
    int _pBigItemsIndexs[100];
}

//无论调用哪一个初始化方法,最后都是返回一个UITableViewStylePlain类型的Table对象
- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self){
        for (int i =0; i<5; i++) {
            [[ItemStore sharedStore] createItem];
        }
    }
    NSInteger val = 50;
    _bigItemsCount =[self getBigItemsCount:val];
    
    //先初始化数组
    //memset(_pBigItemsIndexs, -1, sizeof(_pBigItemsIndexs));
    //[self getBigItemsIndexs:50 indexs:_pBigItemsIndexs];
    
    //获取排序之后的结果
    _sortedItmes = [self getSortItemsBigThan:val formItems:[[ItemStore sharedStore] allItems]];
    NSLog(@"%@",[[ItemStore sharedStore] allItems]);
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style{
    self = [self init];
    return self;
}


// 下面两个方法都是UITableViewDataSource 协议的.
// UITableViewController  初始化后会创建一个UITableView 对象,然后把这个对象的数据源和委托对象指向了自己
// 这样当UITableView对象要获取数据的时候,就会执行下面的两个方法来获取了.
// 注意,UITableViewController 本身就已经遵循了UITableViewDelegate, UITableViewDataSource 等协议
// 详情可参考SDK
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSLog(@"%d",section);
    int count =self.bigItemsCount;
    if(section == 0){
        return count;
    }
    return [[[ItemStore sharedStore] allItems] count] - count;
}

-(int)getBigItemsCount:(NSInteger)value{
    static int count =0;
    if(count >0){
        return count;
    }
    NSArray *items = [[ItemStore sharedStore]allItems];
    for (BNRItem *item in items) {
        if(item.valueInDollars > value){
            count++;
        }
    }
    return count;
}

///未使用
-(void)getBigItemsIndexs:(NSInteger)value indexs:(int *)indexs{
    int key = 0;
    NSArray *items = [[ItemStore sharedStore] allItems];
    for (int i=0; i<items.count; i++) {
        if ([items[i] valueInDollars] > value) {
            indexs[key] = i;
            key++;
        }
    }
}

-(NSArray *)getSortItemsBigThan:(NSInteger)value formItems:(NSArray *)items{
    NSArray *sortedItems = [items sortedArrayUsingComparator:^(id obj1, id obj2) {
        
        if ([obj1 valueInDollars] < [obj2 valueInDollars]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 valueInDollars] > [obj2 valueInDollars]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"section = %ld",(long)indexPath.section);
    NSLog(@"row = %ld",(long)indexPath.row);
    //UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    //创建可重复使用的
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    NSArray *items = self.sortedItmes;
    BNRItem *item;
    if (indexPath.section == 0) {
        item = items[indexPath.row];
    }else{
        item = items[indexPath.row + self.bigItemsCount];
    }
    
    cell.textLabel.text = [item description];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

@end
