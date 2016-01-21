//
//  BNRItem.h
//  HomePwner
//
//  Created by 郑克明 on 16/1/11.
//  Copyright © 2016年 郑克明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BNRItem : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@property (nullable, nonatomic, strong) NSDate *dateCreated;
@property (nullable, nonatomic, strong) NSString *itemKey;
@property (nullable, nonatomic, strong) NSString *itemName;
//double 方便排序.插入某个位置时,值取前后元素排序值的中值即可
@property (nonatomic) double orderingValue;
@property (nullable, nonatomic, strong) NSString *serialNumber;
@property (nullable, nonatomic, strong) UIImage  *thumbnail;
@property (nonatomic) int valueInDollars;
@property (nullable, nonatomic, strong) NSManagedObject *assetType;


- (void)setThumbnailFromImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
