//
//  ParticipantView.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ParticipantView.h"
#import "CommonMethods.h"
#import "CoreDataManager.h"
#import "UIColor+AppColors.h"
#import "CoreDataManager.h"
#import "Profile.h"


CGFloat kViewHeight = 22.5;
CGFloat kbuttonRevokeHeight = 25.0;
CGFloat kbuttonRevokeWidth = 25.0;
CGFloat kLabelOriginX = 4;
CGFloat fontSize = 12.5;

@interface ParticipantView ()

@property (nonatomic, assign) BOOL forSentScreen;

@end

@implementation ParticipantView

- (instancetype)initWithEmail:(NSString *)email withName:(NSString *)name {
    
    self = [super init];
    if (self) {
        self.email = email;
        if (name) {
            self.name = name;
        }
        else {
            self.name = email;
        }
    }
    
    return self;
}

- (void)createForSent:(BOOL)forSent {
    
    self.forSentScreen = forSent;
    
    UIImage *imageRevokeButton = [UIImage imageNamed:@"buttonRevoke.png"];
    
    //setup Self config
    CGFloat senderNameWidth = [[CommonMethods sharedInstance] textWidthWithText:self.name height:15.0 fontName:@"ProximaNova-Light" fontSize:fontSize];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, senderNameWidth + kbuttonRevokeHeight + 5, kViewHeight);
    self.backgroundColor = [UIColor participantsColor];
    self.layer.cornerRadius = 3;
    
    //setup Name label config
    UILabel *labelSenderName = [[UILabel alloc] initWithFrame:CGRectMake(kLabelOriginX, 0, senderNameWidth, kViewHeight)];
    labelSenderName.backgroundColor = [UIColor clearColor];
    labelSenderName.textColor = [UIColor whiteColor];
    labelSenderName.font = [UIFont fontWithName:@"ProximaNova-Light" size:fontSize];
    labelSenderName.text = self.name;
    [self addSubview:labelSenderName];
    
    //setup Revoke button config
    UIButton *buttonRevoke = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonRevoke setImage:imageRevokeButton forState:UIControlStateNormal];
    buttonRevoke.frame = CGRectMake(self.frame.origin.x + self.frame.size.width - kbuttonRevokeWidth, 0, kbuttonRevokeWidth, kbuttonRevokeHeight);
    buttonRevoke.center = CGPointMake(buttonRevoke.center.x, buttonRevoke.center.y);
    [buttonRevoke addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonRevoke];
}

- (void)closeClicked {
    
    if(self.forSentScreen) {
        if ([self.delegate respondsToSelector:@selector(onCloseClicked:)]) {
            [self.delegate onRevokeClicked:self];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(onCloseClicked:)]) {
            [self.delegate onCloseClicked:self];
        }
    }
}

@end
