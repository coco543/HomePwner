//
//  DetailViewController.m
//  HomePwner
//
//  Created by 郑克明 on 15/11/27.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "DetailViewController.h"
//#import "BNRItem.h"
#import "ImageStore.h"
#import "CameraLayerView.h"
#import "ItemStore.h"
#import "CameraPopoverBackgroundView.h"
#import "BNRAssetTypeVIewController.h"
#import "AppDelegate.h"

@import MobileCoreServices;
@interface DetailViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *assetTypeButton;

//用于实现动态字体
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;


@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong) UIPopoverController *imagePickerPopover;
@property (nonatomic,strong) UIPopoverController *assetTypePopover;


@end

@implementation DetailViewController

#pragma mark - 视图初始化和生命周期
-(instancetype)initForNewItem:(BOOL)isNew{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}

//点击保存的时候,只需要让呈现当前视图的控制器关闭当前视图就可以了.item已经加入到数据源中了,会在当前视图小时候,自动被表格调用后自动被显示在表格里的
-(void)save:(id)sender{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

//取消的话,需要移除被添加到数据源中的itme
-(void)cancel:(id)sender{
    [[ItemStore sharedStore] removeItem:self.item];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}
- (IBAction)showAssetTypePicker:(id)sender {
    [self.view endEditing:YES];
    
    BNRAssetTypeVIewController *avc = [[BNRAssetTypeVIewController alloc] init];
    
    avc.item = self.item;
    
    //ipad 专用控制器UIPopverController
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.assetTypePopover = [[UIPopoverController alloc] initWithContentViewController:avc];
        self.assetTypePopover.delegate = self;
        
        //显示出UIPopverController 对象
        [self.assetTypePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        [self.navigationController pushViewController:avc animated:YES];
    }
}

//禁止直接使用默认初始化方法
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"Use initForNewItem:" userInfo:nil];
    return nil;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    UIImageView *iv = [[UIImageView alloc] initWithImage:nil];
    iv.frame = [[UIScreen mainScreen] bounds];
    //设置缩放模式
    iv.contentMode = UIViewContentModeScaleAspectFit;
    
    //告诉自动布局系统不要把自动缩放的掩码转换为约束
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:iv];
    self.imageView = iv;
    
    NSDictionary *nameMap = @{@"imageView":self.imageView,
                              @"dateButton":self.dateButton,
                              @"toolbar":self.toolbar};
    //左右距离父视图分别为0
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|" options:0 metrics:nil views:nameMap];
    
    //顶边距离date控件8点,距离toolbal也是8点
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateButton]-8-[imageView]-8-[toolbar]" options:0 metrics:nil views:nameMap];
    
    //约束要添加到哪一个视图上?根据判定法则添加 P313
    [self.view addConstraints:horizontalConstraints];
    [self.view addConstraints:verticalConstraints];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareForOrientation:io];
    
    BNRItem *item = self.item;
    self.nameField.text = item.itemName;
    self.serialNumberField.text = item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d",item.valueInDollars];
    
    static NSDateFormatter *dateFormatter = nil;
    if (! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
    
    //为数字输入框定制一个工具栏,用于回收键盘
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setBarStyle:UIBarStyleBlack];
    //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
    UIBarButtonItem *btn1 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *btn2 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(resignKeyboard)];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:btn1,btn2,doneButton,nil];
    [topView setItems:buttonsArray];
    [self.valueField setInputAccessoryView:topView];
    
    //载入BNRItem对象的图片,key为空则放回的图片也是nil,运行正常
    NSString *key = self.item.itemKey;
    UIImage *imageToDisplay = [[ImageStore sharedStore] imageForKey:key];
    self.imageView.image = imageToDisplay;
    
    //让item的分类也显示出来
    NSString *typeLabel = [self.item.assetType valueForKey:@"label"];
    if (!typeLabel) {
        typeLabel = @"none";
    }
    self.assetTypeButton.title = [NSString stringWithFormat:@"Type:%@",typeLabel];
    
    //动态字体
    [self updateFonts];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    BNRItem *item = self.item;
    item.itemName = self.nameField.text;
    item.serialNumber = self.serialNumberField.text;
//    用户偏好设置,优化用户体验,把用户当前填入的值设置成下一次新建的默认值
//    item.valueInDollars = [self.valueField.text intValue];
    int newValue = [self.valueField.text intValue];
    if (newValue != item.valueInDollars) {
        //如果有改动,则赋值给item,随后保持进用户设置里
        item.valueInDollars = newValue;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:newValue forKey:BNRNextItemValuePrefsKey];
    }
    
}

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    NSLog(@"%@",identifierComponents);
    BOOL isNew = NO;
    if ([identifierComponents count] == 3) {
        isNew = YES;
    }
    return [[self alloc]initForNewItem:isNew];
}

//选择需要恢复的数据进行保存和恢复 -P464
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.item.itemKey forKey:@"item.itemKey"];
    
    //保存文本框中的数据
    self.item.itemName       = self.nameField.text;
    self.item.serialNumber   = self.serialNumberField.text;
    self.item.valueInDollars = [self.valueField.text intValue];
    
    [[ItemStore sharedStore] saveChanges];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    NSString *itemKey = [coder decodeObjectForKey:@"item.itemKey"];
    for (BNRItem *item in [[ItemStore sharedStore] allItems]) {
        if ([itemKey isEqualToString:item.itemKey]) {
            self.item = item;
            break;
        }
    }
    [super decodeRestorableStateWithCoder:coder];
}

- (void)dealloc{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)viewDidLayoutSubviews{
    for (UIView *subView in self.view.subviews) {
        if ([subView hasAmbiguousLayout]) {
            NSLog(@"AMBIGUOUS: %@",subView);
        }
    }
}

-(void)setItem:(BNRItem *)item{
    _item = item;
    self.navigationItem.title = item.itemName;

}

//隐藏键盘
-(void)resignKeyboard
{
    [self.valueField resignFirstResponder];
}

#pragma mark - Detail edit
//圧入一个新页面
-(IBAction)changeDate:(id)sender{
    //方法1 新建一个视图,里面放好一个时间视图和一个按钮
    //方法2 新建一个视图控制器,在控制器里面做相关操作
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIViewController *viewCtl = [[UIViewController alloc] init];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    viewCtl.view = view;
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 100)];
    //self.datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
    [view addSubview:self.datePicker];
    
    UIButton *updateTimeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    updateTimeBtn.frame = CGRectMake(bounds.size.width/2 - 50, 250, 100, 45);
    [updateTimeBtn setTitle: @"Save Time" forState: UIControlStateNormal];
    updateTimeBtn.backgroundColor = [UIColor whiteColor];
    [updateTimeBtn addTarget:self action:@selector(saveTime:) forControlEvents:UIControlEventTouchDown];
    
    [view addSubview:updateTimeBtn];
    [self.navigationController pushViewController:viewCtl animated:YES];
}

-(void)saveTime:(id)sender{
    
    NSDate *date = self.datePicker.date;
    self.item.dateCreated = date;
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"perss return");
    [textField resignFirstResponder];
    return YES;
}

//DetailView 顶层视图已经修改为UIContrl,所以可以响应用户的触摸事件(跟UIResponder里的事件有区别)
- (IBAction)backgroundTapped:(id)sender {
    NSLog(@"Tapped~");
    [self.view endEditing:YES];
    
    //运动有歧义的视图,方便调试(正式发布前建议不要使用)
    for (UIView *subView in self.view.subviews) {
        if ([subView hasAmbiguousLayout]) {
            [subView exerciseAmbiguityInLayout];
        }
    }
}
- (IBAction)deleteImage:(id)sender {
    NSLog(@"Delete Image");
    [[ImageStore sharedStore] deleteImageForKey:self.item.itemKey];
    self.imageView.image = nil;
}

#pragma mark - Camera
//拍照按钮
- (IBAction)takePicture:(id)sender {
//IOS8中发现如果popover是显示了的,是会把对应的按钮覆盖住的,所以不能点在没消失前第二次点击同样的按钮
//    if ([self.imagePickerPopover isPopoverVisible]) {
//        [self.imagePickerPopover dismissPopoverAnimated:YES];
//        self.imagePickerPopover = nil;
//        return;
//    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if (false && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        CameraLayerView *overLayImgView = [[CameraLayerView alloc] initWithFrame:CGRectMake(0, 0, 320, 640)];
        overLayImgView.image = [UIImage imageNamed:@"cameraLayer.png"];
        imagePicker.cameraOverlayView = overLayImgView;
    }else{
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    
    
    //设置模态方式呈现摄像视图
//    [self presentViewController:imagePicker animated:YES completion:nil];
    //ipad 专用控制器UIPopverController
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.imagePickerPopover.delegate = self;
        
        //显示出UIPopverController 对象
//        self.imagePickerPopover.popoverBackgroundViewClass = [CameraPopoverBackgroundView class];
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType = info[@"UIImagePickerControllerMediaType"];
    if (mediaType == (NSString *)kUTTypeImage) {
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        //UIImage *img = info[UIImagePickerControllerEditedImage];
        
        [self.item setThumbnailFromImage:img];
        [[ImageStore sharedStore] setImage:img forkey:self.item.itemKey];
        
        self.imageView.image = img;
        //UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    }else if (mediaType == (NSString *)kUTTypeMovie){
        NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
        
        //是否可以保存这个地址的内容到相册
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([mediaUrl path])) {
            UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], nil, nil, nil);
            [[NSFileManager defaultManager] removeItemAtPath:[mediaUrl path] error:nil];
            NSLog(@"Video has been saved");
        }
    }
    
    //用户选择图片后如果是ipad的话,则顺便释放popover控制器对象
    if (self.imagePickerPopover) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//相机按钮Popover窗口消失时候触发(发送dismissPopoverAnimated消息主动让它消失的时候不会触发)
//类型选择也触发该方法
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    NSLog(@"User dismissed popover");
    self.imagePickerPopover = nil;
    self.assetTypePopover = nil;
}

#pragma mark - Device
-(void)prepareForOrientation:(UIInterfaceOrientation)orientation{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return;
    }
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    } else {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}
//旋转屏幕时候触发,在IOS8之后可以使用Size Classes了.这个方法过期
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self prepareForOrientation:toInterfaceOrientation];
}

//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    [self prepareForOrientation:toInterfaceOrientation];
//}

#pragma mark - 动态字体
- (void)updateFonts{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.nameLabel.font = font;
    self.valueLabel.font = font;
    self.serialNumberLabel.font = font;
    self.dateLabel.font = font;
    
    self.nameField.font = font;
    self.serialNumberField.font = font;
    self.valueField.font = font;
    
}
@end







