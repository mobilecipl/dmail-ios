//
//  RootViewController.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "RootViewController.h"

#import "Configurations.h"


//test
#import "NetworkGmailMessage.h"

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewMenu;// not used
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHorizontalSpaceing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMenuWidth;
@property CGFloat screenWidthMenu;
@property BOOL menuOpened;

@end

@implementation RootViewController

#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupMenu];
    [self setupNotificationHandlers];
}

- (void)viewDidAppear:(BOOL)animated {
    
//    NetworkGmailContacts *gmailContacts = [[NetworkGmailContacts alloc] init];
//    [gmailContacts getGoogleContactsForEmail:@"ghukasyangevorg1@gmail.com" completionBlock:^(id data, ErrorDataModel *error) {
//        
//    }];
    
//    NetworkGmailMessage *gmailMessages = [[NetworkGmailMessage alloc] init];
//    [gmailMessages getMessageWithMessageId:@"14e6496baff81611" userId:@"me" completionBlock:^(id data, ErrorDataModel *error) {
//        
//    }];
    
//    [gmailMessages getMessageIdWithUniqueId:@"<CALnt6JsyRfqDD1VNQ2m2-Tp-K8bW5Z8LOzTS+xhvjA1X9fro9Q@mail.gmail.com>" userId:@"me" completionBlock:^(id data, ErrorDataModel *error) {
//        
//    }];
    
//    [gmailMessages sendWithEncodedBody:@"RnJvbTogS2FyZW4gUGV0cm9zeWFuIDxnaHVrYXN5YW5nZXZvcmcxQGdtYWlsLmNvbT4gDQpUbzogRGF2aWQgWmFraGFyeWFuIDxnZ2h1a2FzeWFuQHNjaWVuY2UtaW5jLmNvbT4gDQpTdWJqZWN0OiBTYXlpbmcgSGVsbG8gDQoNClRoaXMgaXMgYSBtZXNzYWdlIGp1c3QgdG8gc2F5IGhlbGxvLiBTbywgIkhlbGxvIi4="
//                                userId:@"me"
//                       completionBlock:^(id data, ErrorDataModel *error) {
//                                    
//                                }];
    
//    [gmailMessages deleteWithGmailId:@"14e6496baff81611" userId:@"me" completionBlock:^(id data, ErrorDataModel *error) {
//        
//    }];
    
    
    
}

#pragma mark - Private Methods
- (void)setupMenu {

    self.constraintMenuWidth.constant = self.view.frame.size.width * 0.6; // 60%
    self.screenWidthMenu = self.constraintMenuWidth.constant;
    
    self.constraintHorizontalSpaceing.constant = 0;
    self.menuOpened = NO;
    [self.view layoutIfNeeded];
    
//    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizerAction:)];
//    gesture.minimumNumberOfTouches = 1;
//    gesture.maximumNumberOfTouches = 1;
//    [self.viewMain addGestureRecognizer:gesture];
}

- (void)setupNotificationHandlers {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buttonHandlerMenu)
                                                 name:NotificationMenuButton
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inboxClicked)
                                                 name:NotificationInbox
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sentClicked)
                                                 name:NotificationSent
                                               object:nil];
}

- (void)inboxClicked {
    
    [self hideMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationMessageInbox object:nil];
}

- (void)sentClicked {
    
    [self hideMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationMessageSent object:nil];
}

- (void)buttonHandlerMenu {
    
    [UIView animateWithDuration:0.3 animations:^{
        if (!self.menuOpened) {
            [self openMenu];
        } else {
            [self hideMenu];
        }
    }];
}

- (void)openMenu {
    
    self.constraintHorizontalSpaceing.constant = self.screenWidthMenu;
    [self.view layoutIfNeeded];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.menuOpened = YES;
}

- (void)hideMenu {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.constraintHorizontalSpaceing.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.menuOpened = NO;
}


#pragma mark - UIGestureRecognizer
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer*)pan {
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            CGPoint translation = [pan translationInView:self.viewMain];
            
            CGFloat check = self.constraintHorizontalSpaceing.constant + translation.x;
            if (check > self.screenWidthMenu || check < 0) {
                break;
            }
            
            self.constraintHorizontalSpaceing.constant += translation.x;
            
            [pan setTranslation:CGPointMake(0, 0) inView:self.viewMain];
            break;
        }
        case UIGestureRecognizerStateEnded: {
         
            // find animation velocity
            CGFloat velocity = self.viewMain.frame.origin.x / self.screenWidthMenu ;
            if (self.menuOpened) {
                if( self.viewMain.frame.origin.x > self.screenWidthMenu - 20) {
                    velocity = 1 - velocity;
                }
            } else {
                if( self.viewMain.frame.origin.x > 20) {
                    velocity = 1 - velocity;
                }
            }
            
            NSLog(@"VELOCITY %f ", velocity);
            
            [UIView animateWithDuration:velocity*1 animations:^{
                
                if (self.menuOpened) {
                    if( self.viewMain.frame.origin.x > self.screenWidthMenu - 20) {
                        [self openMenu];
                    } else {
                        [self hideMenu];
                    }
                } else {
                    if( self.viewMain.frame.origin.x > 20) {
                        [self openMenu];
                    } else {
                        [self hideMenu];
                    }
                }
            } completion:nil];
            break;
        }
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer { // Check for horizontal gesture
    
    UIView *cell = [gestureRecognizer view];
    CGPoint translation = [gestureRecognizer translationInView:[cell superview]];
    
    if (fabs(translation.x) > fabs(translation.y)) {
        return YES;
    }
    
    return NO;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
