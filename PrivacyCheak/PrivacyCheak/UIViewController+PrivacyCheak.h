//
//  UIViewController+PrivacyCheak.h
//  PrivacyCheak
//
//  Created by feng on 2018/6/28.
//  Copyright © 2018年 zhujunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,privacyCheakType) {
    privacyCheakTypeCalender=0,//日历
    privacyCheakTypeCamera,//相机
    privacyCheakTypeContacts,//通讯录
    privacyCheakTypeLocation,//定位服务
    privacyCheakTypePhotos,//相册
    privacyCheakTypeMicrophone//麦克风
//      privacyCheakTypeSiri,//语音 siri
//    privacyCheakTypeBluetooth = 0,
};
@interface UIViewController (PrivacyCheak)


/**
 判断隐私授权

 @param type 检查的类型
 @return YES则已授权成功
 */
- (BOOL)cheakPrivacyWithType:(privacyCheakType)type;

@end

NS_ASSUME_NONNULL_END


@interface UIAlertController (YFAdd)
/**
 alertController title
 */
@property (nonatomic, strong) UILabel *yf_titleLabel;

/**
 alertController message
 */
@property (nonatomic, strong) UILabel *yf_messageLabel;

@end



