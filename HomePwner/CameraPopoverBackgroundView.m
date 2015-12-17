//
//  CameraPopoverBackgroundView.m
//  HomePwner
//
//  Created by 郑克明 on 15/12/17.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "CameraPopoverBackgroundView.h"
#define kArrowBase 30.0f
#define kArrowHeight 20.0f
#define kBorderInset 8.0f
@implementation CameraPopoverBackgroundView{
    UIPopoverArrowDirection _arrowDirection;
    CGFloat _offset;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

+(CGFloat)arrowBase{
    return kArrowBase;
}

+(CGFloat)arrowHeight{
    return kArrowHeight;
}

+ (UIEdgeInsets)contentViewInsets{
    return UIEdgeInsetsMake(kBorderInset,kBorderInset,kBorderInset,kBorderInset);
}

- (CGFloat)arrowOffset{
    return _offset;
}

- (void)setArrowOffset:(CGFloat)arrowOffset{
    _offset = arrowOffset;
    [self setNeedsLayout];
}


- (UIPopoverArrowDirection)arrowDirection{
    return _arrowDirection;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}


@end
