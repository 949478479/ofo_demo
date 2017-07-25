//
//  LXQRCodeUtil.m
//  LXQRCodeUtil_demo
//
//  Created by 从今以后 on 2017/5/25.
//  Copyright © 2017年 从今以后. All rights reserved.
//

#import "LXQRCodeUtil.h"
#import <CoreImage/CoreImage.h>

@implementation LXQRCodeUtil

+ (NSString *)readQRCodeInfoFromImage:(UIImage *)image
{
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    NSArray *features = [detector featuresInImage:ciImage];
    if (features.count > 0) {
        return [(CIQRCodeFeature *)features.firstObject messageString];
    }
    return nil;
}

+ (UIImage *)QRCodeImageWithMessage:(NSString *)message
                               size:(CGSize)size
                               logo:(nullable UIImage *)logo
                           logoSize:(CGSize)logoSize
                    foregroundColor:(nullable UIColor *)foregroundColor
                    backgroundColor:(nullable UIColor *)backgroundColor
{
    NSData *messageData = [message dataUsingEncoding:NSISOLatin1StringEncoding];
    CIFilter *QRCodeFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [QRCodeFilter setValue:messageData forKey:@"inputMessage"];
    [QRCodeFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *outputCIImage = QRCodeFilter.outputImage;
    CGRect extent = outputCIImage.extent;
    CGImageRef outputCGImage = [[CIContext new] createCGImage:outputCIImage fromRect:extent];
    
    if (foregroundColor || backgroundColor) {
        size_t pixelsWide = CGImageGetWidth(outputCGImage);
        size_t pixelsHigh = CGImageGetHeight(outputCGImage);
        size_t countOfPixels = pixelsWide * pixelsHigh;
        UInt32 *pixels = calloc(countOfPixels, sizeof(UInt32));
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        CGContextRef context = CGBitmapContextCreate(pixels, pixelsWide, pixelsHigh, 8, 4 * pixelsWide, colorSpace, bitmapInfo);
        CGContextDrawImage(context, (CGRect){.size = extent.size}, outputCGImage);
        
        CGFloat fRed = 0, fGreen = 0, fBlue = 0;
        CGFloat bRed = 0, bGreen = 0, bBlue = 0, bAlpha = 0;
        [foregroundColor getRed:&fRed green:&fGreen blue:&fBlue alpha:NULL];
        [backgroundColor getRed:&bRed green:&bGreen blue:&bBlue alpha:&bAlpha];
        
        UInt8 *components = NULL;
        UInt32 *currentPixel = pixels;
        for (size_t i = 0; i < countOfPixels; ++i) {
            components = (UInt8 *)currentPixel;
            if (*currentPixel == 0xFF000000) { // 黑色，即前景
                if (foregroundColor) {
                    components[2] = fRed   * 255.0; // R
                    components[1] = fGreen * 255.0; // G
                    components[0] = fBlue  * 255.0; // B
                }
            } else if (backgroundColor) {
                if (bAlpha == 0.0) {
                    *currentPixel = 0;
                } else {
                    components[2] = bRed   * 255.0; // R
                    components[1] = bGreen * 255.0; // G
                    components[0] = bBlue  * 255.0; // B
                }
            }
            ++currentPixel;
        }
        
        CGImageRelease(outputCGImage);
        outputCGImage = CGBitmapContextCreateImage(context);
        
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        free(pixels);
    }
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    size = LXSizeCeilInPixel(size, scale);
    UIGraphicsBeginImageContextWithOptions(size, ![backgroundColor isEqual:[UIColor clearColor]], scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 让二维码更清晰
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    // 翻转，不然是上下颠倒的
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, (CGRect){.size = size}, outputCGImage);
    CGImageRelease(outputCGImage);
    
    if (logo) {
        logoSize = LXSizeCeilInPixel(logoSize, scale);
        CGRect logoRect = {.size = logoSize};
        logoRect.origin.x = (size.width - logoSize.width) / 2;
        logoRect.origin.y = (size.height - logoSize.height) / 2;
        logoRect = LXRectFlatted(logoRect, scale);
        CGContextDrawImage(context, logoRect, logo.CGImage);
    }
    
    UIImage *QRCodeimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return QRCodeimage;
}

@end
