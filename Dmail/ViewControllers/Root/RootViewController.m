//
//  RootViewController.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "RootViewController.h"

#import "Configurations.h"

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewMenu;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHorizontalSpaceing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMenuWidth;
@property CGFloat screenWidthMenu;
@property BOOL menuOpened;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMenu];
    [self setupNotificationHandlers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMenu {
    [self.view layoutIfNeeded];
    self.constraintMenuWidth.constant = self.view.frame.size.width * 0.6; // 60%
    self.screenWidthMenu = self.constraintMenuWidth.constant;
    
    
    self.constraintHorizontalSpaceing.constant = 0;
    //    self.constraintMain.constant = 0;
    
    //    self.constraintMenuWidth.constant = self.screenWidthContainerView;
    self.menuOpened = NO;
    [self.view layoutIfNeeded];
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    gesture.minimumNumberOfTouches = 1;
    gesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:gesture];
}

- (void)setupNotificationHandlers {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buttonHandlerMenu)
                                                 name:kNotificationMenuButton
                                               object:nil];

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
    //    self.constraintMain.constant = self.screenWidthContainerView;
    
    [self.view layoutIfNeeded];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.menuOpened = YES;
}

- (void)hideMenu {
    self.constraintHorizontalSpaceing.constant = 0;
    //    self.constraintMain.constant = 0;
    
    [self.view layoutIfNeeded];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.menuOpened = NO;
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer*)pan//----------------------------------PAN Gesture Action----------------
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [pan translationInView:self.view];
            NSLog(@"%f",translation.x);
            
            CGFloat check = self.constraintHorizontalSpaceing.constant + translation.x;
            if (check > self.screenWidthMenu || check < 0) {
                break;
            }
            
            
//            if (self.menuOpened && self.constraintHorizontalSpaceing.constant > self.screenWidthMenu ) {
//                self.constraintHorizontalSpaceing.constant = 0;
//                break;
//            }
//            
//            if (!self.menuOpened && self.constraintHorizontalSpaceing.constant < 0 ) {
//                self.constraintHorizontalSpaceing.constant = 0;
//                break;
//            }
            
            self.constraintHorizontalSpaceing.constant += translation.x;
            //            self.constraintMain.constant += translation.x;
            
            [pan setTranslation:CGPointMake(0, 0) inView:self.view];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
         
            CGFloat velocity = ( self.viewMain.frame.origin.x * 100 ) / self.screenWidthMenu ;
            velocity *= 0.01;
            if (self.menuOpened) {
                if( self.viewMain.frame.origin.x > self.screenWidthMenu - 10) {
//                    [self openMenu];
                    velocity = 1 - velocity;
                } else {
//                    [self hideMenu];
                }
            } else {
                if( self.viewMain.frame.origin.x > 10) {
//                    [self openMenu];
                    velocity = 1 - velocity;
                } else {
//                    [self hideMenu];
                }
            }

            
            [UIView animateWithDuration:velocity * 0.3 animations:^{
                
                if (self.menuOpened) {
                    if( self.viewMain.frame.origin.x > self.screenWidthMenu - 10) {
                        [self openMenu];
                    } else {
                        [self hideMenu];
                    }
                } else {
                    if( self.viewMain.frame.origin.x > 10) {
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

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *cell = [gestureRecognizer view];
    CGPoint translation = [gestureRecognizer translationInView:[cell superview]];
    
    // Check for horizontal gesture
    if (fabs(translation.x) > fabs(translation.y))
    {
        return YES;
    }
    
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
