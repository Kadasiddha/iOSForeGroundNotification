//
//  SNotificationView.m
//  SNotificationView
//
//  Created by Kadasiddha on 19/09/15.
//  Copyright (c) 2015 Kadasiddha. All rights reserved.
//

#import "SNotificationView.h"

#define S_NOTIFICATION_VIEW_FRAME_HEIGHT          64.0f

#define S_NOTIFICATION_LABEL_TITLE_FONT_SIZE       14.0f
#define S_NOTIFICATION_LABEL_MESSAGE_FONT_SIZE                 13.0f

#define S_NOTIFICATION_IMAGE_VIEW_ICON_CORNER_RADIUS           3.0f
#define S_NOTIFICATION_IMAGE_VIEW_ICON_FRAME                   CGRectMake(15.0f, 8.0f, 20.0f, 20.0f)
#define S_NOTIFICATION_LABEL_TITLE_FRAME                       CGRectMake(45.0f, 3.0f, [[UIScreen mainScreen] bounds].size.width - 45.0f, 26.0f)
#define S_NOTIFICATION_LABEL_MESSAGE_FRAME_HEIGHT              35.0f
#define S_NOTIFICATION_LABEL_MESSAGE_FRAME                    CGRectMake(45.0f, 25.0f, [[UIScreen mainScreen] bounds].size.width - 45.0f, S_NOTIFICATION_LABEL_MESSAGE_FRAME_HEIGHT)

#define S_NOTIFICATION_VIEW_SHOWING_DURATION                  7.0f    /// second(s)
#define S_NOTIFICATION_VIEW_SHOWING_ANIMATION_TIME            0.5f    /// second(s)

@implementation SNotificationView

/// -------------------------------------------------------------------------------------------
#pragma mark - INIT
/// -------------------------------------------------------------------------------------------
+ (instancetype)sharedInstance
{
    static id _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, S_NOTIFICATION_VIEW_FRAME_HEIGHT)];
    if (self) {
        
        /// Enable orientation tracking
        if (![[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        
        /// Add Orientation notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationStatusDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        /// Set up UI
        [self setUpUI];
    }
    
    return self;
}

/// -------------------------------------------------------------------------------------------
#pragma mark - ACTIONS
/// -------------------------------------------------------------------------------------------
- (void)setUpUI
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        self.barTintColor = nil;
        self.translucent = YES;
        self.barStyle = UIBarStyleBlack;
    }
    else {
        [self setTintColor:[UIColor colorWithRed:5 green:31 blue:75 alpha:1]];
    }
    
    self.layer.zPosition = MAXFLOAT;
    self.backgroundColor = [UIColor clearColor];
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    
    self.frame = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, S_NOTIFICATION_VIEW_FRAME_HEIGHT);
    
    /// Icon
    if (!imgNotificationIcon) {
        imgNotificationIcon = [[UIImageView alloc] init];
    }
    imgNotificationIcon.frame = S_NOTIFICATION_IMAGE_VIEW_ICON_FRAME;
    [imgNotificationIcon setContentMode:UIViewContentModeScaleAspectFill];
    [imgNotificationIcon.layer setCornerRadius:S_NOTIFICATION_IMAGE_VIEW_ICON_CORNER_RADIUS];
    [imgNotificationIcon setClipsToBounds:YES];
    if (![imgNotificationIcon superview]) {
        [self addSubview:imgNotificationIcon];
    }
    
    /// Title
    if (!lblNotificationTitle) {
        lblNotificationTitle = [[UILabel alloc] init];
    }
    lblNotificationTitle.frame = S_NOTIFICATION_LABEL_TITLE_FRAME;
    [lblNotificationTitle setTextColor:[UIColor whiteColor]];
    [lblNotificationTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:S_NOTIFICATION_LABEL_TITLE_FONT_SIZE]];
    [lblNotificationTitle setNumberOfLines:1];
    if (![lblNotificationTitle superview]) {
        [self addSubview:lblNotificationTitle];
    }
    
    /// Message
    if (!lblNotificationMessage) {
        lblNotificationMessage = [[UILabel alloc] init];
    }
    lblNotificationMessage.frame = S_NOTIFICATION_LABEL_MESSAGE_FRAME;
    [lblNotificationMessage setTextColor:[UIColor whiteColor]];
    [lblNotificationMessage setFont:[UIFont fontWithName:@"HelveticaNeue" size:S_NOTIFICATION_LABEL_MESSAGE_FONT_SIZE]];
    [lblNotificationMessage setNumberOfLines:2];
    lblNotificationMessage.lineBreakMode = NSLineBreakByTruncatingTail;
    if (![lblNotificationMessage superview]) {
        [self addSubview:lblNotificationMessage];
    }
    [self fixLabelMessageSize];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notificationViewDidTap:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)displayNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message autoHide:(BOOL)autoHide didTouch:(void (^)())didTouch
{
    /// Invalidate autoHidetimer
    if (autoHidetimer) {
        [autoHidetimer invalidate];
        autoHidetimer = nil;
    }
    
    /// onTouch
    onTouch = didTouch;
    
    /// Image
    if (image) {
        [imgNotificationIcon setImage:image];
    }
    else {
        [imgNotificationIcon setImage:nil];
    }
    
    /// Title
    if (title) {
        [lblNotificationTitle setText:title];
    }
    else {
        [lblNotificationTitle setText:@""];
    }
    
    /// Message
    if (message) {
        [lblNotificationMessage setText:message];
    }
    else {
        [lblNotificationMessage setText:@""];
    }
    [self fixLabelMessageSize];
    
    /// Prepare frame
    CGRect frame = self.frame;
    frame.origin.y = -frame.size.height;
    self.frame = frame;
    
    /// Add to window
    [UIApplication sharedApplication].delegate.window.windowLevel = UIWindowLevelStatusBar;
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    
    /// Showing animation
    [UIView animateWithDuration:S_NOTIFICATION_VIEW_SHOWING_ANIMATION_TIME
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGRect frame = self.frame;
                         frame.origin.y += frame.size.height;
                         self.frame = frame;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
    // Schedule to hide
    if (autoHide) {
        autoHidetimer = [NSTimer scheduledTimerWithTimeInterval:S_NOTIFICATION_VIEW_SHOWING_DURATION
                                                          target:self
                                                        selector:@selector(hideNotificationView)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}
- (void)hideNotificationView
{
    [self hideNotificationViewOnComplete:nil];
}
- (void)hideNotificationViewOnComplete:(void (^)())onComplete
{
    [UIView animateWithDuration:S_NOTIFICATION_VIEW_SHOWING_ANIMATION_TIME
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGRect frame = self.frame;
                         frame.origin.y -= frame.size.height;
                         self.frame = frame;
                         
                     } completion:^(BOOL finished) {
                         
                         [self removeFromSuperview];
                         [UIApplication sharedApplication].delegate.window.windowLevel = UIWindowLevelNormal;
                         
                         // Invalidate autoHidetimer close
                         if (autoHidetimer) {
                             [autoHidetimer invalidate];
                             autoHidetimer = nil;
                         }
                         
                         if (onComplete) {
                             onComplete();
                         }
                     }];
}
- (void)notificationViewDidTap:(UIGestureRecognizer *)gesture
{
    if (onTouch) {
        onTouch();
    }
}

/// -------------------------------------------------------------------------------------------
#pragma mark - HELPER
/// -------------------------------------------------------------------------------------------
- (void)fixLabelMessageSize
{
    CGSize size = [lblNotificationMessage sizeThatFits:CGSizeMake([[UIScreen mainScreen] bounds].size.width - 45.0f, MAXFLOAT)];
    CGRect frame = lblNotificationMessage.frame;
    frame.size.height = (size.height > S_NOTIFICATION_LABEL_MESSAGE_FRAME_HEIGHT ? S_NOTIFICATION_LABEL_MESSAGE_FRAME_HEIGHT : size.height);
    lblNotificationMessage.frame = frame;
}

/// -------------------------------------------------------------------------------------------
#pragma mark - ORIENTATION NOTIFICATION
/// -------------------------------------------------------------------------------------------
- (void)orientationStatusDidChange:(NSNotification *)notification
{
    [self setUpUI];
}

/// -------------------------------------------------------------------------------------------
#pragma mark - UTILITY FUNCS
/// -------------------------------------------------------------------------------------------
+ (void)displayNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message
{
    [SNotificationView displayNotificationViewWithImage:image title:title message:message autoHide:YES didTouch:nil];
}
+ (void)displayNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message autoHide:(BOOL)autoHide
{
    [SNotificationView displayNotificationViewWithImage:image title:title message:message autoHide:autoHide didTouch:nil];
}
+ (void)displayNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message autoHide:(BOOL)autoHide didTouch:(void (^)())didTouch
{
    [[SNotificationView sharedInstance] displayNotificationViewWithImage:image title:title message:message autoHide:autoHide didTouch:didTouch];
}

+ (void)hideNotificationView
{
    [SNotificationView hideNotificationViewOnComplete:nil];
}
+ (void)hideNotificationViewOnComplete:(void (^)())onComplete
{
    [[SNotificationView sharedInstance] hideNotificationViewOnComplete:onComplete];
}





@end
