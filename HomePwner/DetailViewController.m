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

@interface DetailViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic,strong) UIDatePicker *datePicker;
@end

@implementation DetailViewController

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

-(void)setItem:(BNRItem *)item{
    _item = item;
    self.navigationItem.title = item.itemName;

}

//隐藏键盘
-(void)resignKeyboard
{
    [self.valueField resignFirstResponder];
}

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

//拍照按钮
- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    //设置模态方式呈现摄像视图
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //UIImage *img = info[UIImagePickerControllerOriginalImage];
    UIImage *img = info[UIImagePickerControllerEditedImage];
    
    [[ImageStore sharedStore] setImage:img forkey:self.item.itemKey];
    
    self.imageView.image = img;

    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"perss return");
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch");
}

//DetailView 顶层视图已经修改为UIContrl,所以可以响应用户的触摸事件(跟UIResponder里的事件有区别)
- (IBAction)backgroundTapped:(id)sender {
    NSLog(@"Tapped~");
    [self.view endEditing:YES];
}

@end
