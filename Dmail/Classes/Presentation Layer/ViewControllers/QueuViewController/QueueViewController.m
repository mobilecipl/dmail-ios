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
@property (nonatomic, assign) NSInteger queu;

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
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getToken:) name:NotificationToken object:nil];
}


#pragma mark - Private Methods
- (void)setupController {
    
    self.buttonShare.layer.masksToBounds = YES;
    self.buttonShare.layer.cornerRadius = 5;
    
    self.queu = 5;
    self.labelCurrentPlace.text = [NSString stringWithFormat:@"%ld", (long)self.queu];
}

- (void)getQueue {
    
    [self showLoadingView];
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [self.serviceQueue getQueueWithUserId:deviceId completionBlock:^(id data, ErrorDataModel *error) {
        [self hideLoadingView];
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            if (YES) {
                [self performSegueWithIdentifier:@"fromQueuToGetStarted" sender:self];
            }
            else {
                
            }
            self.labelCurrentPlace.text = data[@""];
            self.labelTotalInLine.text = data[@""];
        }
        else {
            // TODO - error message
        }
    }];
}

- (void)sendDeviceToken {
    
    [self showLoadingView];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication];
    [appDelegate registerNotifications];
}

- (void)getToken:(NSNotification *)notification {
    
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *token = [[notification userInfo] valueForKey:Token];
    if (token && token.length > 0) {
        [self.serviceQueue sendTokenWithDeviceId:deviceId token:token completionBlock:^(id data, ErrorDataModel *error) {
            [self hideLoadingView];
        }];
    }
    else {
        [self hideLoadingView];
        // TODO - error message
    }
}


#pragma mark - Action Methods
- (IBAction)setupSecurityPinClicked:(id)sender {
    
    BOOL setupPin = [[NSUserDefaults standardUserDefaults] boolForKey:@"setupPin"];
    if (setupPin) {
        [self.buttonSetupPin setImage:[UIImage imageNamed:@"iconSetupSecurityPin"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonSetupPin setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
    }
    setupPin = !setupPin;
    [[NSUserDefaults standardUserDefaults] setBool:setupPin forKey:@"setupPin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)getNotifiedClicked:(id)sender {
    
    BOOL getNotified = [[NSUserDefaults standardUserDefaults] boolForKey:@"getNotified"];
    if (getNotified) {
        [self.buttonGetNotified setImage:[UIImage imageNamed:@"iconGetNotified"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonGetNotified setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
    }
    
    getNotified = !getNotified;
    [[NSUserDefaults standardUserDefaults] setBool:getNotified forKey:@"getNotified"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
