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

@end
