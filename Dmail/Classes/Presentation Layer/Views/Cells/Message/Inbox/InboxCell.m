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

@interface InboxCell () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewCell;
@property (weak, nonatomic) IBOutlet UIView *viewCell;
@property (weak, nonatomic) IBOutlet UIView *viewCellActions;



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
    
    self.scrollViewCell.contentSize = CGSizeMake(self.frame.size.width + self.viewCellActions.frame.size.width, self.scrollViewCell.contentSize.height);
    self.scrollViewCell.delegate = self;
    
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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnCell)];
    [self.viewCell addGestureRecognizer:tapGesture];
}

- (void)tapOnCell {
    
    if([self.delegate respondsToSelector:@selector(tapOnCell:)]) {
        [self.delegate tapOnCell:self];
    }
}

- (void)closeOptions {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.scrollViewCell.contentOffset = CGPointMake(0, self.scrollViewCell.contentOffset.y);
    } completion:^(BOOL finished) {
        //some code
    }];
}

- (IBAction)buttonDeleteClicked:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(messageDelete:)]) {
        [self.delegate messageDelete:self];
    }
}

- (IBAction)buttonArchiveClicked:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(messageArchive:)]) {
        [self.delegate messageArchive:self];
    }
}

- (IBAction)buttonUnreadlicked:(id)sender {
    
    self.viewBorder.hidden = NO;
    if([self.delegate respondsToSelector:@selector(messageUnread:)]) {
        [self.delegate messageUnread:self];
    }
}


#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSLog(@"scrollView.contentOffset.x === %f", scrollView.contentOffset.x);
    if([self.delegate respondsToSelector:@selector(closeEditedCellOptions)]) {
        [self.delegate closeEditedCellOptions];
    }
    if(scrollView.contentOffset.x > scrollView.contentSize.width - self.scrollViewCell.frame.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.contentSize.width - self.scrollViewCell.frame.size.width, 0);
        self.viewCell.layer.masksToBounds = NO;
        self.viewCell.layer.shadowOffset = CGSizeMake(1, 1);
        self.viewCell.layer.shadowRadius = 10;
        self.viewCell.layer.shadowOpacity = 0.5;
    }
    if(scrollView.contentOffset.x == scrollView.contentSize.width - self.scrollViewCell.frame.size.width) {
        if([self.delegate respondsToSelector:@selector(cellOptionsAreOpened:)]) {
            [self.delegate cellOptionsAreOpened:self];
        }
    }
}

@end
