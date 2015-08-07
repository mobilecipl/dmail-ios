//
//  MessageComposeCell.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

// NEED TO REMOVE !!!!

#import <UIKit/UIKit.h>

@protocol MessageComposeCellDelegate <NSObject>

@optional
- (void)messageSubject:(NSString *)subject;
- (void)messageBody:(NSString *)body;

@end

@interface MessageComposeCell : UITableViewCell

@property (nonatomic, assign) id<MessageComposeCellDelegate> delegate;

- (void)configureCell;
- (void)configureCellWithBody:(NSString *)body subject:(NSString *)subject internalDate:(double)internalDate;

@end

