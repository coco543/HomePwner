//
//  ItemsViewController.m
//  HomePwner
//
//  Created by 郑克明 on 15/11/24.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "ItemsViewController.h"
#import "ItemStore.h"
//#import "BNRItem.h"
#import "ImageStore.h"
#import "BNRImageViewController.h"
@interface ItemsViewController() <UIPopoverControllerDelegate, UIDataSourceModelAssociation>
@property (nonatomic,strong) IBOutlet UIView *headerView;
@property (nonatomic,strong) UIPopoverController *imagePopover;
@end

@implementation ItemsViewController


#pragma mark - 初始化
//无论调用哪一个初始化方法,最后都是返回一个UITableViewStylePlain类型的Table对象
- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self){
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Homepwner";
        //设置恢复标识和恢复类
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        navItem.rightBarButtonItem = bbi;
        
        navItem.leftBarButtonItem = self.editButtonItem;
        //下面的代码可以实现相同的功能:添加左边编辑按钮
        //navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditModel:)];
        
        //添加字体变更的消息通知
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(updateTableViewForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style{
    return [super initWithStyle:(UITableViewStyle)style];
}


#pragma mark - 视图周期

-(void)viewDidLoad{
    [super viewDidLoad];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    //使用自定义的Cell视图文件注册表格单元
    [self.tableView registerNib:[UINib nibWithNibName:@"BNRItemCell" bundle:nil] forCellReuseIdentifier:@"BNRItemCell"];
    self.tableView.restorationIdentifier = @"ItemsViewControllerTableView";
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

//视图要显示的时候,刷新一下表格的数据
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self updateTableViewForDynamicTypeSize];
    [self.tableView reloadData];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    return [[self alloc] init];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    [coder encodeBool:self.isEditing forKey:@"TableViewIsEditing"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    BOOL isEditing = [coder decodeBoolForKey:@"TableViewIsEditing"];
    self.editing = isEditing;
    [super decodeRestorableStateWithCoder:coder];
}

//用于恢复选中行
- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view{
    NSString *identifier = nil;
    if (idx && view) {
        BNRItem *item = [[ItemStore sharedStore] allItems][idx.row];
        identifier = item.itemKey;
    }
    return identifier;
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view{
    NSIndexPath *idx = nil;
    if (identifier && view) {
        NSArray *items = [[ItemStore sharedStore] allItems];
        for (BNRItem *item in items) {
            if ([identifier isEqualToString:item.itemKey]) {
                NSInteger row = [items indexOfObjectIdenticalTo: item];
                idx = [NSIndexPath indexPathForRow:row inSection:0];
            }
        }
    }
    return idx;
}

#pragma mark - 动态字体
//动态调节表格行高
- (void)updateTableViewForDynamicTypeSize
{
    static NSDictionary *cellHeightDictionary;
    
    if (!cellHeightDictionary) {
        cellHeightDictionary = @{ UIContentSizeCategoryExtraSmall : @44,
                                  UIContentSizeCategorySmall : @44,
                                  UIContentSizeCategoryMedium : @44,
                                  UIContentSizeCategoryLarge : @44,
                                  UIContentSizeCategoryExtraLarge : @55,
                                  UIContentSizeCategoryExtraExtraLarge : @65,
                                  UIContentSizeCategoryExtraExtraExtraLarge : @75 };
    }
    
    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    
    NSNumber *cellHeight = cellHeightDictionary[userSize];
    [self.tableView setRowHeight:cellHeight.floatValue];
    [self.tableView reloadData];
}

- (void)dealloc{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

#pragma mark - TableView视图相关

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
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    BNRItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNRItemCell" forIndexPath:indexPath];
    
    
    if ([cell.contentView isKindOfClass:[NSObject class]]) {
        NSLog(@"contentView is Kind of UIScrollView");
    }
    NSArray *items = [[ItemStore sharedStore]allItems];
    BNRItem *item = items[indexPath.row];
    
//    cell.textLabel.text = [item description];
    cell.nameLabel.text = item.itemName;
    cell.serialNumberLabel.text = item.serialNumber;
    
    //处理货币本地化
    static NSNumberFormatter *currencyFormatter = nil;
    if (currencyFormatter == nil) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    
//    cell.valueLabel.text = [NSString stringWithFormat:@"$%i",item.valueInDollars];
    cell.valueLabel.text = [currencyFormatter stringForObjectValue:@(item.valueInDollars)];
    if (item.valueInDollars >= 50) {
        cell.valueLabel.textColor = [UIColor redColor];
    }
    cell.thumbnailView.image = item.thumbnail;
    
    //为了避免Cell视图直接操作控制器或者访问数据源,直接给Cell视图设置一个块让他在需要的时候调用
    //在block外弱引用cell对象,可以防止block中对cell产生引用循环
    __weak BNRItemCell *weakCell = cell;
    cell.actionBlock = ^{
        //block在运行时才会对cell保持强引用.这样就不会出现引用循环问题了
        //定义strong 目的是为了保证block在运行的时候从头到尾都可以访问到cell,所以在block开始执行时,strongCell就对cell保持强引用.直到block结束后释放局部变量strongCell,此时strongCell就会结束对cell的强引用
        //注意,如果把下面代码修改成BNRItemCell *strongCell = cell这样就会产生引用循环.因为cell出现在block内,即被block强引用,而cell对象又强引用了block(cell.actionBlock = ****).猜测,因为weakCell是弱引用变量,所以出现在block内不会增加对象的引用计数
        BNRItemCell *strongCell = weakCell;
        NSLog(@"Going to show image for %@",item);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            NSString *itemKey = item.itemKey;
            UIImage *img = [[ImageStore sharedStore] imageForKey:itemKey];
            if (!img) {
                return;
            }
            //根据TableView对象的座标系,获取UIImageView对象的位置和大小,弹出层箭头指向改区域
            CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds fromView:strongCell.thumbnailView];
            
            BNRImageViewController *ivc = [[BNRImageViewController alloc]init];
            ivc.image = img;
            
            self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
            self.imagePopover.delegate = self;
            self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
            [self.imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    };
    
    return cell;
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
//    BNRItem * __strong *items = &item;
//    NSInteger lastRow = [[[ItemStore sharedStore] allItems] indexOfObject:item];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    DetailViewController *detailViewControll = [[DetailViewController alloc] initForNewItem:YES];
    detailViewControll.item = item;
    detailViewControll.dismissBlock = ^{
        [self.tableView reloadData];
    };
    
    //这里用一个导航控制器展示detailViewControll,原因就是在用模态显示detailViewControll时,如果不用导航控制器,则没有UINavigationBar了需要手动再定制一个,所以使用导航控制器比较方便.(presentViewController要显示的视图必须是非active,被[[UINavigationController alloc]initWithRootViewController:detailViewControll]之后的视图已经是active了)
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:detailViewControll];
    
    //设置恢复标识,不用设置恢复类,同AppDelegate里描述
    navController.restorationIdentifier = NSStringFromClass([navController class]);
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    //navController.modalPresentationStyle = UIModalPresentationFormSheet;
    //修改成
    //navController.modalPresentationStyle = UIModalPresentationCurrentContext;
    //self.definesPresentationContext = YES;
    //可以不让顶部控制器行使模态操作权,转而让self来用模态显示navControler,这样navController就不会盖住nagivation对象了(没覆盖在上方导致无法点击了...) P344
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
#pragma mark - 其他委托代理
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    self.imagePopover =nil;
}


@end
