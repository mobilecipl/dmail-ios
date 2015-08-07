//
//  ParticipantView.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//


// NEED TO REMOVE !!!!


#import <UIKit/UIKit.h>


@protocol ParticipantViewDelegate <NSObject>

- (void)onCloseClicked:(id)participantView;
- (void)onRevokeClicked:(id)participantView;

@end

@interface ParticipantView : UIView

@property (nonatomic, assign) id<ParticipantViewDelegate> delegate;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *access;

- (instancetype)initWithEmail:(NSString *)email withName:(NSString *)name;
- (void)createForSent:(BOOL)forSent withAccess:(NSString *)access;

@end
