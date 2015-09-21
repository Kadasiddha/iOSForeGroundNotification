//
//  SNotificationView.m
//  SNotificationView
//
//  Created by Kadasiddha on 19/09/15.
//  Copyright (c) 2015 Kadasiddha. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface SNotificationView : UIToolbar
{
    void (^ onTouch)();
    
    UIImageView *imgNotificationIcon;
    UILabel *lblNotificationTitle;
    UILabel *lblNotificationMessage;
    
    NSTimer *autoHidetimer;
}

+ (instancetype)sharedInstance;

+ (void)displayNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message;
+ (void)displayNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message autoHide:(BOOL)autoHide;
+ (void)displayNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message autoHide:(BOOL)autoHide didTouch:(void (^)())didTouch;

+ (void)hideNotificationView;
+ (void)hideNotificationViewOnComplete:(void (^)())onComplete;

@end
