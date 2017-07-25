//
//  LXQRCodeScanner.h
//  LXQRCodeUtil_demo
//
//  Created by 从今以后 on 2017/5/25.
//  Copyright © 2017年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXCaptureVideoPreviewView : UIView
/// 默认为 0.75。
@property (nonatomic) IBInspectable CGFloat maskAlpha;
@end


@interface LXQRCodeScanner : NSObject 

/// 是否开启手电筒。
@property(nonatomic, getter=isTorchActive) BOOL torchActive;

/// 取值范围 0.0 ~ 1.0，默认为 { 0.0 , 0.0, 1.0, 1.0 }。
@property (nonatomic) IBInspectable CGRect rectOfInterest;
/// 若使用 IB，可通过 outlet 设置该属性；若使用代码，可通过该属性获取一个 `LXCaptureVideoPreviewView` 视图。
@property (null_resettable, nonatomic, readonly) IBOutlet LXCaptureVideoPreviewView *previewView;

/// 扫码过程中发生错误时调用。
@property (nullable, nonatomic) void (^failureBlock)(NSError *error);
/// 扫码成功后调用，`messages` 数组一定含有元素。
@property (nullable, nonatomic) void (^completionBlock)(LXQRCodeScanner *scanner, NSArray<NSString *> *messages);

- (void)startRunningWithCompletion:(void (^_Nullable)(BOOL success, NSError *_Nullable error))completion;
- (void)stopRunningWithCompletion:(void (^_Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
