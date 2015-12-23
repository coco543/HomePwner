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
@property (nonatomic,readonly,strong) NSArray *allItems;
@property (nonatomic,strong) NSArray *testValue;
+(instancetype) sharedStore;

-(BNRItem *)createItem;

-(void)removeItem:(BNRItem *)item;

-(void)moveItemAtIndex:(NSUInteger)formIndex toIndex:(NSUInteger)toIndex;

- (BOOL)saveChanges;
@end
