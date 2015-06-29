//
//  ParticipantsCell.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ParticipantsCellDelegate <NSObject>

- (void)onCCBCCClickedd;
- (void)onArrowUpClicked;
- (void)participantEmail:(NSString *)email;
- (void)changeCellHeightWith:(CGFloat)height cellRow:(NSInteger)row;
- (void)addParticipantsEmail:(NSString *)email row:(NSInteger)row;

@end


@interface ParticipantsCell : UITableViewCell

@property (nonatomic, assign) id<ParticipantsCellDelegate> delegate;

- (void)configureCell:(NSInteger)row hideCcBcc:(BOOL)hideCcBcc;
- (void)configureCellForSentWithRow:(NSInteger)row withParticipants:(NSArray *)arrayParticipants;

@end
