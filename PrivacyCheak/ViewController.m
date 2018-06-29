//
//  ViewController.m
//  PrivacyCheak
//
//  Created by feng on 2018/6/28.
//  Copyright © 2018年 zhujunyu. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+PrivacyCheak.h"
#import <CoreTelephony/CTCellularData.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   
    
    [self performSelector:@selector(cheak) withObject:nil afterDelay:0.5];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)cheak{
    if ([self cheakPrivacyWithType:privacyCheakTypeContacts]) {
        NSLog(@"授权");
    }else{
         NSLog(@"未授权");
    }

}
@end
