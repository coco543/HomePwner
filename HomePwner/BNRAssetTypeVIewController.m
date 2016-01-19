//
//  BNRAssetTypeVIewController.m
//  HomePwner
//
//  Created by 郑克明 on 16/1/14.
//  Copyright © 2016年 郑克明. All rights reserved.
//

#import "BNRAssetTypeVIewController.h"
#import "BNRItem.h"
#import "ItemStore.h"
@interface BNRAssetTypeVIewController () <UINavigationControllerDelegate>
@property (nonatomic,strong) UINavigationController *navController;
@property (nonatomic,strong) UITextField *typeNameTextField;
@end


@implementation BNRAssetTypeVIewController

- (instancetype)init{
    return [super initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style{
    return [super initWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewAssetType:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[ItemStore sharedStore] allAssetTypes] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray *allAssets =[[ItemStore sharedStore] allAssetTypes];
    NSManagedObject *assetType = allAssets[indexPath.row];
    NSString *label = [assetType valueForKey:@"label"];
    cell.textLabel.text = label;
    
    //为选中的对象加上勾选的标记
    if (assetType == self.item.assetType) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSArray *allAssets = [[ItemStore sharedStore] allAssetTypes];
    NSManagedObject *assetType = allAssets[indexPath.row];
    self.item.assetType = assetType;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self.tableView reloadData];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Navigation itemBar
- (void)addNewAssetType:(id)sender{
    NSLog(@"click add assettype");
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view = [[UIView alloc] init];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(addNewAssetTypeCancel:)];
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addNewAssetTypeDone:)];
    vc.navigationItem.title = @"New asset type";
    navController.delegate = self;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(0, 0, 100, 30);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    //一定要加上下面这句禁止自动生成缩略约束...
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [vc.view addSubview:textField];
    NSDictionary *nameMap = @{@"textField":textField};
    //左右距离父视图分别为1
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[textField]-40-|" options:0 metrics:nil views:nameMap];
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:vc.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:150.f];
    
    //约束要添加到哪一个视图上?根据判定法则添加 P313
    [vc.view addConstraints:horizontalConstraints];
    [vc.view addConstraint:verticalConstraint];
    
    
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.navController = navController;
    self.typeNameTextField = textField;
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)addNewAssetTypeDone:(id)sender{
    UIViewController *uvc = self.navController.topViewController;
    [uvc.view endEditing:YES];
    NSString *typeName = [self.typeNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[ItemStore sharedStore] addNewAssetType:typeName];
    [self.tableView reloadData];
    [uvc.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)addNewAssetTypeCancel:(id)sender{
    UIViewController *uvc = self.navController.topViewController;
    [uvc.view endEditing:YES];
    [self.navController.topViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.typeNameTextField = nil;
    self.navController = nil;
}


@end
