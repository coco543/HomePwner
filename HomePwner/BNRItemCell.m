//
//  BNRItemCell.m
//  HomePwner
//
//  Created by 郑克明 on 15/12/23.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "BNRItemCell.h"
@interface BNRItemCell()

//左侧ImageView宽高约束
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
//优化约束,让宽度等于高度,就只设置高度即可
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation BNRItemCell

- (void)awakeFromNib{
    [self updateInterfaceForDynamicTypeSize];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateInterfaceForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    //优化约束,让宽度等于高度,就只设置高度即可
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.thumbnailView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    [self.thumbnailView addConstraint:constraint];
}

- (void)dealloc{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}
- (IBAction)showImage:(id)sender {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)updateInterfaceForDynamicTypeSize{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.nameLabel.font = font;
    self.serialNumberLabel.font = font;
    self.valueLabel.font = font;
    
    static NSDictionary *imageSizeDictionary;
    if (!imageSizeDictionary) {
        imageSizeDictionary = @{ UIContentSizeCategoryExtraSmall : @40,
                                 UIContentSizeCategorySmall : @40,
                                 UIContentSizeCategoryMedium : @40,
                                 UIContentSizeCategoryLarge : @40,
                                 UIContentSizeCategoryExtraLarge : @45,
                                 UIContentSizeCategoryExtraExtraLarge : @55,
                                 UIContentSizeCategoryExtraExtraExtraLarge : @65 };
    }
    
    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    NSNumber *imageSize = imageSizeDictionary[userSize];
//    self.imageViewWidthConstraint.constant = imageSize.floatValue;
    self.imageViewHeightConstraint.constant = imageSize.floatValue;
    
}

@end
