//
//  DetailViewController.h
//  HomePwner
//
//  Created by 郑克明 on 15/11/27.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BNRItem;
@interface DetailViewController : UIViewController <UIViewControllerRestoration>
@property (nonatomic,strong) BNRItem *item;
@property (nonatomic,strong) void (^dismissBlock)(void);

-(instancetype)initForNewItem:(BOOL)isNew;

@end
