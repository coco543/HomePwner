//
//  BNRItemCell.h
//  HomePwner
//
//  Created by 郑克明 on 15/12/23.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

//创建block是在栈中创建的.对它使用strong,它也会随着方法栈被释放而释放的.所以一定要用copy,复制一份到堆中保存.
@property (nonatomic,copy) void (^actionBlock)(void);
@end
