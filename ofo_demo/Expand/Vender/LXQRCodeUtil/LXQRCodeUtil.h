//
//  LXQRCodeUtil.h
//  LXQRCodeUtil_demo
//
//  Created by 从今以后 on 2017/5/25.
//  Copyright © 2017年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 将以 pt 为单位的浮点值沿远离 0 的方向像素对齐
CG_INLINE CGFloat
LXCeilInPixel(CGFloat value, CGFloat scale) {
    if (value > 0)
        return ceil(value * scale) / scale;
    if (value < 0)
        return floor(value * scale) / scale;
    return 0;
}

/// 将一个以 pt 为单位 CGPoint 的坐标沿负方向调整从而像素对齐
CG_INLINE CGPoint
LXPointFloorInPixel(CGPoint point, CGFloat scale) {
    return CGPointMake(floor(point.x * scale) / scale, floor(point.y * scale) / scale);
}

/// 将一个以 pt 为单位的 CGSize 的宽高沿远离 0 的方向调整从而像素对齐
CG_INLINE CGSize
LXSizeCeilInPixel(CGSize size, CGFloat scale) {
    return CGSizeMake(LXCeilInPixel(size.width, scale), LXCeilInPixel(size.height, scale));
}

/// 对一个以 pt 为单位的 CGRect 进行像素对齐，origin 沿负方向对齐，size 沿正方向对齐
CG_INLINE CGRect
LXRectFlatted(CGRect rect, CGFloat scale) {
    rect.origin = LXPointFloorInPixel(rect.origin, scale);
    rect.size = LXSizeCeilInPixel(rect.size, scale);
    return rect;
}

NS_ASSUME_NONNULL_BEGIN

@interface LXQRCodeUtil : NSObject

/// 读取二维码图片信息
+ (NSString *)readQRCodeInfoFromImage:(UIImage *)image;

/**
 *  生成二维码图片
 *
 *  @param message         二维码内容
 *  @param size            二维码尺寸，以 pt 为单位
 *  @param logo            二维码中心图案
 *  @param logoSize        二维码中心图案尺寸，以 pt 为单位
 *  @param foregroundColor 前景色，默认黑色
 *  @param backgroundColor 背景色，默认白色
 */
+ (UIImage *)QRCodeImageWithMessage:(NSString *)message
                               size:(CGSize)size
                               logo:(nullable UIImage *)logo
                           logoSize:(CGSize)logoSize
                    foregroundColor:(nullable UIColor *)foregroundColor
                    backgroundColor:(nullable UIColor *)backgroundColor;
@end

NS_ASSUME_NONNULL_END
