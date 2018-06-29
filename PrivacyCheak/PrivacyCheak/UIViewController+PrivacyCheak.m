//
//  UIViewController+PrivacyCheak.m
//  PrivacyCheak
//
//  Created by feng on 2018/6/28.
//  Copyright © 2018年 zhujunyu. All rights reserved.
//
#import "UIViewController+PrivacyCheak.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>

@implementation UIViewController (PrivacyCheak)

- (BOOL)cheakPrivacyWithType:(privacyCheakType)type{
    switch (type) {
        case privacyCheakTypeCamera: return [self cheakCamera];break;
        case privacyCheakTypePhotos: return [self cheakPhotos];break;
        case privacyCheakTypeLocation: return [self cheakLocation];break;
        case privacyCheakTypeCalender: return [self cheakCalender];break;
        case privacyCheakTypeContacts: return [self cheakContacts];break;
        case privacyCheakTypeMicrophone:return [self cheakMicrophone];break;
//        case privacyCheakTypeBluetooth: return[self cheakBluetooth];break;
//        case privacyCheakTypeSiri: return [self cheakSiri];break;
        default:
            break;
    }
    return NO;
}
- (BOOL)cheakMicrophone{
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        [self alertWithTyp:privacyCheakTypeMicrophone];
        return NO;
    }
    if (authStatus == AVAuthorizationStatusNotDetermined){
        __block BOOL authorized = NO;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            authorized = granted ;
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return authorized;
    }
    if (authStatus == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}


- (BOOL)cheakCamera{
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        [self alertWithTyp:privacyCheakTypePhotos];
        return NO;
    }
    if (authStatus == AVAuthorizationStatusNotDetermined){
        __block BOOL authorized = NO;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            authorized = granted ;
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return authorized;
    }
    if (authStatus == AVAuthorizationStatusAuthorized) {
        return  YES;
    }
    return NO;
}

- (BOOL)cheakPhotos{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        __block BOOL authorized = NO;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
           authorized = (status == PHAuthorizationStatusAuthorized);
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return authorized;
    }
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted ) {
        [self alertWithTyp:privacyCheakTypeCamera];
        return NO;
    }
    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

- (BOOL)cheakContacts{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        __block BOOL authorized = NO;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            authorized = granted;
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return authorized;
    }
    if (status !=CNAuthorizationStatusAuthorized ) {
        [self alertWithTyp:privacyCheakTypeContacts];
        return NO;
    }
    if (status ==CNAuthorizationStatusAuthorized ) {
        return YES;
    }
    return NO;
}

- (BOOL)cheakLocation{
   CLAuthorizationStatus status =  [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            CLLocationManager *manager = [CLLocationManager new];
            [manager   requestWhenInUseAuthorization];
            [manager requestAlwaysAuthorization];
            return NO;
        }break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        {
            [self alertWithTyp:privacyCheakTypeLocation];
            return NO;
        }break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            break;
        default:
            break;
    }
    return NO;
}

- (BOOL)cheakCalender{
    EKAuthorizationStatus status =   [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status) {
        case EKAuthorizationStatusNotDetermined:{
            EKEventStore *manager = [EKEventStore new];
            __block BOOL authorized = NO;
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            [manager requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                authorized = granted;
                dispatch_semaphore_signal(sema);
            }];
            return authorized;
        }break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:{
            [self alertWithTyp:privacyCheakTypeCalender];
        }break;
        case EKAuthorizationStatusAuthorized:return YES;break;
            break;
            
        default:
            break;
    }
    return NO;
}
- (BOOL)cheakBluetooth{
    
    return NO;
}

- (BOOL)cheakSiri{
    
    return NO;
}
- (void)alertWithTyp:(privacyCheakType)type{
    NSString *typName = [self getMessageWithType:type];
    NSString *title = [NSString stringWithFormat:@"%@被禁用",typName];
    NSString *message = [NSString stringWithFormat:@"请在iPhone的“设置->隐私->%@”\n中允许应用访问您的%@",typName,typName];
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    alertCtr.yf_messageLabel.textAlignment = NSTextAlignmentLeft;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtr addAction:cancelAction];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    [alertCtr addAction:confirmAction];
    [self presentViewController:alertCtr animated:YES completion:nil];
}
- (NSString *)getMessageWithType:(privacyCheakType)type{
    switch (type) {
        case privacyCheakTypeCamera: return @"相机";break;
        case privacyCheakTypePhotos: return @"相册";break;
        case privacyCheakTypeLocation: return @"定位服务";break;
        case privacyCheakTypeCalender: return @"日历";break;
        case privacyCheakTypeContacts: return @"通讯录";break;
        case privacyCheakTypeMicrophone:return @"麦克风";break;
//        case privacyCheakTypeSiri: return @"语音识别（Siri）";break;
//        case privacyCheakTypeBluetooth: return @"蓝牙";break;
        default:
            break;
    }
    return @"";
}
@end

@implementation UIAlertController (YFAdd)
@dynamic yf_titleLabel;
@dynamic yf_messageLabel;

- (NSArray *)yf_viewArray:(UIView *)root {
    static NSArray *_subviews = nil;
    _subviews = nil;
    for (UIView *v in root.subviews) {
        if (_subviews) {
            break;
        }
        if ([v isKindOfClass:[UILabel class]]) {
            NSMutableArray *arr = [NSMutableArray new];
            for (UIView *label in  root.subviews) {
                if ([label isKindOfClass:[UILabel class]]) {
                    [arr addObject:label];
                }
            }
            _subviews = [NSArray arrayWithArray:arr];
            return _subviews;
        }
        [self yf_viewArray:v];
    }
    return _subviews;
}

- (UILabel *)yf_titleLabel {
    
    return [self yf_viewArray:self.view][0];
}

- (UILabel *)yf_messageLabel {
    return [self yf_viewArray:self.view][1];
}
@end


