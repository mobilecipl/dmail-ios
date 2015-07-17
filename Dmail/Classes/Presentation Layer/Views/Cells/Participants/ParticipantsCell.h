//
//  ParticipantsCell.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactModel;

@protocol ParticipantsCellDelegate <NSObject>

@optional
- (void)onCCBCCClickedd;
- (void)onArrowUpClicked;
- (void)participantEmail:(NSString *)email;
- (void)startEditparticipantName:(NSInteger)cellRow;
- (void)changeCellHeightWith:(CGFloat)height cellRow:(NSInteger)row;
- (void)addParticipantsEmail:(NSString *)email row:(NSInteger)row;
- (void)removeParticipantsEmail:(NSString *)email row:(NSInteger)row;
- (void)changeTableOffsetY;
- (void)revokeParticipantWithEmail:(NSString *)email name:(NSString *)name;

@end


@interface ParticipantsCell : UITableViewCell

@property (nonatomic, assign) id<ParticipantsCellDelegate> delegate;
@property (nonatomic, assign) BOOL participantSet;


- (void)configureCell:(NSInteger)row hideCcBcc:(BOOL)hideCcBcc;
- (void)configureCellForSentWithRow:(NSInteger)row withParticipants:(NSArray *)arrayParticipants messageId:(NSString *)messageId;
- (void)addParticipantWithContactModel:(ContactModel *)contactModel;

@end
