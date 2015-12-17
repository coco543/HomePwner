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
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Homepwner";
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        navItem.rightBarButtonItem = bbi;
        
        navItem.leftBarButtonItem = self.editButtonItem;
        //下面的代码可以实现相同的功能:添加左边编辑按钮
        //navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditModel:)];
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
    NSLog(@"cellForRowAtIndexPath %@",indexPath);
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
    [self.tableView setRowHeight:44];
    //禁止回弹
    [self.tableView setBounces:NO];
    //设置背景图
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    [self.tableView setBackgroundView:imgView];
    
    //增加一个头视图
    //UIView *headView = self.headerView;
    //[self.tableView setTableHeaderView:headView];
}


//-(UIView *)headerView{
//    //延迟载入,当需要用到了才载入
//    if(!_headerView){
//        [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil];
//    }
//    return _headerView;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 44;
//}

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
    BNRItem *item = [[ItemStore sharedStore] createItem];
//    NSInteger lastRow = [[[ItemStore sharedStore] allItems] indexOfObject:item];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    DetailViewController *detailViewControll = [[DetailViewController alloc] initForNewItem:YES];
    detailViewControll.item = item;
    detailViewControll.dismissBlock = ^{
        [self.tableView reloadData];
    };
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:detailViewControll];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
}

-(IBAction)toggleEditModel:(id)sender{
    if (self.isEditing) {
        [self setEditing:NO animated:YES];
        //注释掉的代码是为了成为UIBarButtonItem 的action时,改变相应的UIBarButtonItem的标题
        //[self.navigationItem.leftBarButtonItem setTitle:@"编辑"];
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
    }else{
        [self setEditing:YES animated:NO];
        //[self.navigationItem.leftBarButtonItem setTitle:@"完成"];
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

//实现移动
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSLog(@"move: %@",[[ItemStore sharedStore] allItems]);
    NSLog(@"befor =>%@",self.tableView.visibleCells);
    if (destinationIndexPath.section == 0 && (destinationIndexPath.row == [[[ItemStore sharedStore] allItems] count] - 1)) {
        //reloadRowsAtIndexPaths 会在内存里的目标行帮忙创建一个cell.所以数据源个数不变但是cell数量多了一个,会有异常..
        //[self.tableView reloadRowsAtIndexPaths:@[sourceIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
        
    }else{
        [[ItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    }
    NSLog(@"alter =>%@",self.tableView.visibleCells);
    return;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"remove";
}

//UITableViewDataSource 协议里的方法
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && (indexPath.row == [[[ItemStore sharedStore] allItems] count] - 1)){
        return NO;
    }
    return YES;
}

//选中某行时
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:NO];
    
    detailViewController.item = [[ItemStore sharedStore] allItems][indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}

//视图要显示的时候,刷新一下表格的数据
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
@end
