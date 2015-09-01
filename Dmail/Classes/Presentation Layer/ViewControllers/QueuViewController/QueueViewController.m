//
//  QueueViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "QueueViewController.h"
#import "ServiceQueue.h"
#import "AppDelegate.h"

@interface QueueViewController ()

@property (nonatomic, weak) IBOutlet UIButton *buttonSetupPin;
@property (nonatomic, weak) IBOutlet UIButton *buttonGetNotified;
@property (nonatomic, weak) IBOutlet UIButton *buttonShare;
@property (nonatomic, weak) IBOutlet UILabel *labelCurrentPlace;
@property (nonatomic, weak) IBOutlet UILabel *labelTotalInLine;
@property (nonatomic, strong) ServiceQueue *serviceQueue;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL startRequest;

@end

@implementation QueueViewController


#pragma mark - Class Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _serviceQueue = [[ServiceQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
    [self getQueue];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getQueue) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getToken:) name:NotificationToken object:nil];
}


#pragma mark - Private Methods
- (void)setupController {
    
    self.buttonShare.layer.masksToBounds = YES;
    self.buttonShare.layer.cornerRadius = 5;
    
    BOOL getNotified = [[NSUserDefaults standardUserDefaults] boolForKey:ActivatePushNotification];
    if (getNotified) {
        [self.buttonGetNotified setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
        self.buttonGetNotified.userInteractionEnabled = NO;
    }
    
    BOOL setupPin = [[NSUserDefaults standardUserDefaults] boolForKey:SetupPin];
    if (setupPin) {
        [self.buttonSetupPin setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
        self.buttonSetupPin.userInteractionEnabled = NO;
    }
}

- (void)getQueue {
    
    [self showLoadingView];
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (!self.startRequest) {
        self.startRequest = YES;
        [self.serviceQueue getQueueWithUserId:deviceId completionBlock:^(id data, ErrorDataModel *error) {
            self.startRequest = NO;
            [self hideLoadingView];
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                if ([[data allKeys] containsObject:@"access"]) {
                    if ([data[@"access"] isEqualToString:@"GRANTED"]) {
                        [self.timer invalidate];
                        [self performSegueWithIdentifier:@"fromQueuToGetStarted" sender:self];
                    }
                }
                else {
                    self.labelCurrentPlace.text = data[@"position"];
                    self.labelTotalInLine.text = data[@"queueSize"];
                    [self checkQueueStatusWithPosition:[data[@"position"] integerValue] total:[data[@"queueSize"] integerValue]];
                }
            }
            else {
                [self showErrorAlertWithTitle:@"Error" message:@"Unable to connect with server. Please try again."];
            }
        }];
    }
}

- (void)sendDeviceToken {
    
    [self showLoadingView];
    [[AppDelegate sharedDelegate] registerNotifications];
}

- (void)checkQueueStatusWithPosition:(NSInteger)position total:(NSInteger)total {
    
    if (position == total) {
        [self.timer invalidate];
        [self performSegueWithIdentifier:@"fromQueuToGetStarted" sender:self];
    }
}

- (void)getToken:(NSNotification *)notification {
    
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *token = [[notification userInfo] valueForKey:Token];
    if (token && token.length > 0) {
        [self.serviceQueue sendTokenWithDeviceId:deviceId token:token completionBlock:^(id data, ErrorDataModel *error) {
            [self hideLoadingView];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ActivatePushNotification];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    else {
        [self hideLoadingView];
    }
}


#pragma mark - Action Methods
- (IBAction)setupSecurityPinClicked:(id)sender {
    
    BOOL setupPin = [[NSUserDefaults standardUserDefaults] boolForKey:SetupPin];
    if (!setupPin) {
        [self.buttonSetupPin setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SetupPin];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)getNotifiedClicked:(id)sender {
    
    BOOL getNotified = [[NSUserDefaults standardUserDefaults] boolForKey:ActivatePushNotification];
    if (!getNotified) {
        [self.buttonGetNotified setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
    }
    
    [self sendDeviceToken];
}

- (IBAction)shareClicked:(id)sender {
    
    NSString *textToShare = @"your text";
//    UIImage *imageToShare = [UIImage imageNamed:@"yourImage.png"];
    NSArray *itemsToShare = @[textToShare];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypeMessage, UIActivityTypeMail];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
