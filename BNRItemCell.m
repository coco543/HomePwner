//
//  BNRItemCell.m
//  HomePwner
//
//  Created by 郑克明 on 15/12/23.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import "BNRItemCell.h"

@implementation BNRItemCell

//- (IBAction)showImage:(id)sender{
//    
//}
- (IBAction)showImage:(id)sender {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

@end
