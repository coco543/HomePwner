//
//  ItemStore.h
//  HomePwner
//
//  Created by 郑克明 on 15/11/24.
//  Copyright © 2015年 郑克明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNRItem.h"
@interface ItemStore : NSObject
@property (nonatomic,readonly) NSArray *allItems;
+(instancetype) sharedStore;
-(BNRItem *)createItem;
@end
