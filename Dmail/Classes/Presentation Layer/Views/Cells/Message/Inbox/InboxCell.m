//
//  InboxCell.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxCell.h"

#import "UIImageView+WebCache.h"

#import "VMInboxMessageItem.h"

#import "UIImageView+WebCache.h"

#import "ServiceProfile.h"

NSString *const InboxCellIdentifier = @"InboxCellIdentifier";
NSInteger const panelLeftSlightLimit = 250;
NSInteger const panelRightSlightLimit = 100;

@interface InboxCell ()

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIView *viewBorder;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelSenderName;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelMessageSubject;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat cellLeftOriginX;

@end

@implementation InboxCell


#pragma mark - Publioc Methods
- (void)configureCell:(VMInboxMessageItem *)messageItem {
    
    self.centerY = self.viewMain.center.y;
    self.cellLeftOriginX = [UIScreen mainScreen].bounds.size.width - 25;
    self.imageViewProfile.layer.masksToBounds = YES;
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    self.labelSenderName.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelMessageSubject.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.labelSenderName.text = messageItem.senderName;
    self.labelDate.text = messageItem.messageDate;
    self.labelMessageSubject.text = messageItem.messageSubject;
    if (messageItem.read) {
        self.viewBorder.hidden = YES;
    } else {
        
        self.viewBorder.hidden = NO;
    }
    
    [self.imageViewProfile sd_setImageWithURL:[NSURL URLWithString:messageItem.imageUrl]];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    pan.delegate = self;
    [self.viewMain addGestureRecognizer:pan];
}

- (void)panCell:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint translation = [panGesture translationInView:self];
    if (translation.x < 0 && self.constraintLeadingMainView.constant > -self.cellLeftOriginX) {
        self.constraintLeadingMainView.constant = self.constraintLeadingMainView.constant + translation.x;
    }
    else if (translation.x > 0 && self.constraintLeadingMainView.constant + translation.x >= 0) {
        self.constraintLeadingMainView.constant = 0;
    }
    else if (translation.x > 0 && self.constraintLeadingMainView.constant < 0) {
        self.constraintLeadingMainView.constant = self.constraintLeadingMainView.constant + translation.x;
    }
    [panGesture setTranslation:CGPointMake(0, 0) inView:self];
    
    if (translation.x < 0 && self.constraintLeadingMainView.constant < -panelRightSlightLimit) {
        [self movePanelToRight];
    }
    
    if (translation.x > 0 && self.constraintLeadingMainView.constant > -panelLeftSlightLimit) {
        [self movePanelToLeft];
    }
}

- (IBAction)buttonDeleteClicked:(id)sender {
    
    [self movePanelToLeft];
    if([self.delegate respondsToSelector:@selector(messageDelete:)]) {
        [self.delegate messageDelete:self];
    }
}

- (IBAction)buttonArchiveClicked:(id)sender {
    
    [self movePanelToLeft];
    if([self.delegate respondsToSelector:@selector(messageArchive:)]) {
        [self.delegate messageArchive:self];
    }
}

- (IBAction)buttonUnreadlicked:(id)sender {
    
    [self movePanelToLeft];
    self.viewBorder.hidden = NO;
    if([self.delegate respondsToSelector:@selector(messageUnread:)]) {
        [self.delegate messageUnread:self];
    }
}

- (void)movePanelToLeft {
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.constraintLeadingMainView.constant = 0;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [UIView animateWithDuration:0.5
                                              animations:^{
                                                  self.viewMain.layer.shadowColor = [[UIColor grayColor] CGColor];
                                                  self.viewMain.layer.shadowOpacity = 0;
                                                  self.viewMain.layer.shadowRadius = 0;
                                                  self.viewMain.layer.shadowOffset = CGSizeMake(0, 0);
                                              }
                                              completion:nil];
                         }
                     }];
}

- (void)movePanelToRight {
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.constraintLeadingMainView.constant = -self.cellLeftOriginX;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [UIView animateWithDuration:0.5
                                              animations:^{
                                                  self.viewMain.layer.shadowColor = [[UIColor grayColor] CGColor];
                                                  self.viewMain.layer.shadowOpacity = 0.6;
                                                  self.viewMain.layer.shadowRadius = 2;
                                                  self.viewMain.layer.shadowOffset = CGSizeMake(1, 0);
                                              }
                                              completion:nil];
                         }
                     }];
    
    if([self.delegate respondsToSelector:@selector(panelMovedOnRight:)]) {
        [self.delegate panelMovedOnRight:self];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    // Check for horizontal gesture
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIView *cell = [gestureRecognizer view];
        CGPoint translation = [gestureRecognizer translationInView:[cell superview]];
        
        if (fabs(translation.x) > fabs(translation.y)) {
            return YES;
        }
        return NO;
    }
    return NO;
}


@end
