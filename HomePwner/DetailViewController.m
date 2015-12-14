//
//  DetailViewController.m
//  HomePwner
//
//  Created by 郑克明 on 15/11/27.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "DetailViewController.h"
#import "BNRItem.h"
#import "ImageStore.h"
#import "CameraLayerView.h"
@import MobileCoreServices;
@interface DetailViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak,nonatomic) IBOutlet UIButton *dateButton;

@property (nonatomic,strong) UIDatePicker *datePicker;
@end

@implementation DetailViewController

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
    
    //载入BNRItem对象的图片
    NSString *key = self.item.itemKey;
    UIImage *img = [[ImageStore sharedStore] imageForKey:key];
    self.imageView.image = img;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    BNRItem *item = self.item;
    item.itemName = self.nameField.text;
    item.serialNumber = self.serialNumberField.text;
    item.valueInDollars = [self.valueField.text intValue];
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
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
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
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType = info[@"UIImagePickerControllerMediaType"];
    if (mediaType == (NSString *)kUTTypeImage) {
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        //UIImage *img = info[UIImagePickerControllerEditedImage];
        
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

    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
