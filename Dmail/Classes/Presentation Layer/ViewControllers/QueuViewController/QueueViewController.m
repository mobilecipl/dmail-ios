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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private Methods
- (void)setupController {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:InQueue];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)appWillEnterForeground:(NSNotification *)notification {
    
    if (!self.timer) {
        [self getQueue];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getQueue) userInfo:nil repeats:YES];
    }
}

- (void)appDidEnterBackground:(NSNotification *)notification {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)getQueue {
    
    [self showLoadingView];
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"deviceId ====== %@", deviceId);
    if (!self.startRequest) {
        self.startRequest = YES;
        [self.serviceQueue getQueueWithUserId:deviceId completionBlock:^(id data, ErrorDataModel *error) {
            self.startRequest = NO;
            [self hideLoadingView];
            [self.timer invalidate];
            self.timer = nil;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:InQueue];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSegueWithIdentifier:@"fromQueuToGetStarted" sender:self];
            
//            if (data && [data isKindOfClass:[NSDictionary class]]) {
//                if ([[data allKeys] containsObject:@"access"]) {
//                    if ([data[@"access"] isEqualToString:@"GRANTED"]) {
//                        [self.timer invalidate];
//                        self.timer = nil;
//                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:InQueue];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
//                        [self performSegueWithIdentifier:@"fromQueuToGetStarted" sender:self];
//                    }
//                }
//                else {
//                    NSInteger position = [data[@"position"] integerValue];
//                    NSInteger queueSize = [data[@"queueSize"] integerValue];
//                    self.labelCurrentPlace.text = [NSString stringWithFormat:@"%ld", (long)position];
//                    self.labelTotalInLine.text = [NSString stringWithFormat:@"%ld", (long)queueSize];
//                }
//            }
//            else {
//                if (self.timer) {
//                    [self.timer invalidate];
//                    self.timer = nil;
//                    [self showErrorAlertWithTitle:@"Error" message:@"Unable to connect with server. Please try again."];
//                }
//            }
        }];
    }
}


#pragma mark - Action Methods
- (IBAction)setupSecurityPinClicked:(id)sender {
    
    BOOL setupPin = [[NSUserDefaults standardUserDefaults] boolForKey:SetupPin];
    if (!setupPin) {
        [self.buttonSetupPin setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SetupPin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)getNotifiedClicked:(id)sender {
    
    BOOL getNotified = [[NSUserDefaults standardUserDefaults] boolForKey:ActivatePushNotification];
    if (!getNotified) {
        [self.buttonGetNotified setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ActivatePushNotification];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[AppDelegate sharedDelegate] registerNotifications];
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
