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
@property (nonatomic,strong) IBOutlet UIView *headerView;
@end
@implementation ItemsViewController

//无论调用哪一个初始化方法,最后都是返回一个UITableViewStylePlain类型的Table对象
- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self){
//        for (int i =0; i<5; i++) {
//            [[ItemStore sharedStore] createItem];
//        }
    }
    
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
    return [[[ItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    //创建可重复使用的
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    NSArray *items = [[ItemStore sharedStore]allItems];
    BNRItem *item = items[indexPath.row];
    
    cell.textLabel.text = [item description];
    
    return cell;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView setRowHeight:60];
    
    //设置背景图
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    [self.tableView setBackgroundView:imgView];
    
    //增加一个头视图
    UIView *headView = self.headerView;
    [self.tableView setTableHeaderView:headView];
}


-(UIView *)headerView{
    //延迟载入,当需要用到了才载入
    if(!_headerView){
        [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil];
    }
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    if (section != 0) {
        return;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    cell.textLabel.text = @"No more items";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:cell];
    return ;
}

-(IBAction)addNewItem:(id)sender{
    //创建一个新的item对象
    BNRItem *itme = [[ItemStore sharedStore] createItem];
    NSInteger lastRow = [[[ItemStore sharedStore] allItems] indexOfObject:itme];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

-(IBAction)toggleEditModel:(id)sender{
    if (self.isEditing) {
        [self setEditing:NO animated:YES];
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
    }else{
        [self setEditing:YES animated:NO];
        [sender setTitle:@"Done" forState:UIControlStateNormal];
    }
}

//实现删除
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *items = [[ItemStore sharedStore] allItems];
        BNRItem *item = items[indexPath.row];
        [[ItemStore sharedStore] removeItem:item];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [[ItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}



@end
