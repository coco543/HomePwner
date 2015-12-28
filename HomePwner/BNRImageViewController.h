//
//  BNRImageViewController.h
//  HomePwner
//
//  Created by 郑克明 on 15/12/26.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRImageViewController : UIViewController

//创建当前控制器后,要把UIImage赋值给image,随后在BNRImageViewController将要显示视图的时候把image赋值给BNRImageViewController 对象的view.image
@property (nonatomic,strong) UIImage *image;
@end
