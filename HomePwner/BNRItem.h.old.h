//
//  BNRItem.h
//  RandomItems
//
//  Created by John Gallagher on 1/12/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRItem : NSObject <NSCoding>
{
    NSString *_itemName;
    NSString *_serialNumber;
    NSMutableString *_varietyString;
    int _valueInDollars;
    NSDate *_dateCreated;
}
//copy,strong都可以
@property (nonatomic,copy) NSString *itemKey;
//存放缩略图
@property (nonatomic,strong) UIImage *thumbnail;

+ (instancetype)randomItem;

// Designated initializer for BNRItem
- (instancetype)initWithItemName:(NSString *)name
                  valueInDollars:(int)value
                    serialNumber:(NSString *)sNumber;

- (instancetype)initWithItemName:(NSString *)name;


- (void)setItemName:(NSString *)str;
- (NSString *)itemName;

- (void)setSerialNumber:(NSString *)str;
- (NSString *)serialNumber;

- (void)setValueInDollars:(int)v;
- (int)valueInDollars;

-(void)setVarietyString:(NSMutableString *)string;
-(NSMutableString *)varietyString;

- (NSDate *)dateCreated;
- (void)setDateCreated:(NSDate *)date;

- (void)setThumbnailFromImage:(UIImage *)image;
@end
