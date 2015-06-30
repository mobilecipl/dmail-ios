//
//  ParticipantView.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ParticipantViewDelegate <NSObject>

- (void)onCloseClicked:(id)participantView;

@end

@interface ParticipantView : UIView

@property (nonatomic, assign) id<ParticipantViewDelegate> delegate;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *name;

- (instancetype)initWithEmail:(NSString *)email;
- (void)create;

@end