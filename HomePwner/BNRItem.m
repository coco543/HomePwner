//
//  BNRItem.m
//  HomePwner
//
//  Created by 郑克明 on 16/1/11.
//  Copyright © 2016年 郑克明. All rights reserved.
//

#import "BNRItem.h"

@implementation BNRItem

@dynamic dateCreated;
@dynamic itemKey;
@dynamic itemName;
@dynamic orderingValue;
@dynamic serialNumber;
@dynamic thumbnail;
@dynamic valueInDollars;
@dynamic assetType;

// Insert code here to add functionality to your managed object subclass


- (void)setThumbnailFromImage:(UIImage *)image {
    CGSize originImageSize = image.size;
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    //根据当前屏幕scaling factor创建一个透明的位图图形上下文(此处不能直接从UIGraphicsGetCurrentContext获取,原因是UIGraphicsGetCurrentContext获取的是上下文栈的顶,在drawRect:方法里栈顶才有数据,其他地方只能获取一个nil.详情看文档)
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    //保持宽高比例,确定缩放倍数
    //(原图的宽高做分母,导致大的结果比例更小,做MAX后,ratio*原图长宽得到的值最小是40,最大则比40大,这样的好处是可以让原图在画进40*40的缩略矩形画布时,origin可以取=(缩略矩形长宽 减 原图长宽*ratio)/2 ,这样可以得到一个可能包含负数的origin,结合缩放的原图长宽size之后,最终原图缩小后的缩略图中央刚好可以对准缩略矩形画布中央)
    float ratio = MAX(newRect.size.width / originImageSize.width, newRect.size.height / originImageSize.height);
    
    //创建一个圆角的矩形 UIBezierPath对象
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    
    //用Bezier对象裁剪上下文
    [path addClip];
    
    //让image在缩略图范围内居中()
    CGRect projectRect;
    projectRect.size.width = originImageSize.width * ratio;
    projectRect.size.height = originImageSize.height * ratio;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2;
    //在上下文中画图
    [image drawInRect:projectRect];
    
    //从图形上下文获取到UIImage对象,赋值给thumbnai属性
    UIImage *smallImg = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnail = smallImg;
    
    //清理图形上下文(用了UIGraphicsBeginImageContext 需要清理)
    UIGraphicsEndImageContext();
}

//插入新数据时,自动生成时间和key
- (void)awakeFromInsert{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    self.itemKey = key;
}
@end






