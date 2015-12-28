//
//  BNRImageViewController.m
//  HomePwner
//
//  Created by 郑克明 on 15/12/26.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "BNRImageViewController.h"

@interface BNRImageViewController () <UIScrollViewDelegate>

@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) UIScrollView *scrollView;
@end

@implementation BNRImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    //这里不需要任何约束. UIImageView在被加进PopoverController之后会自动适配其长宽
    //self.view = imageView;
    
    CGRect screenRect = self.view.bounds;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:screenRect];
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 0.5;
    scrollView.maximumZoomScale = 2;
    [scrollView addSubview:imageView];
    [scrollView setContentSize:CGSizeMake(600, 600)];
    [scrollView setPagingEnabled:NO];
    self.imgView = imageView;
    self.scrollView = scrollView;
    self.view = scrollView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //self.view 被定义未UIView,必须强制转换
    //UIImageView *imageView = (UIImageView *)self.view;
    UIImageView *imageView = self.imgView;
    imageView.frame = self.view.frame;
    imageView.image = self.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//缩放事件
//缩放事件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imgView;
}

@end
