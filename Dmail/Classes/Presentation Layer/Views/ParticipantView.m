//
//  ParticipantView.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ParticipantView.h"
#import "CommonMethods.h"
#import "UIColor+AppColors.h"
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
        if (name && name.length > 0) {
            self.name = name;
        }
        else {
            self.name = email;
        }
    }
    
    return self;
}

- (void)createForSent:(BOOL)forSent withAccess:(NSString *)access {
    
    self.forSentScreen = forSent;
    
    //setup Self config
    CGFloat senderNameWidth = [[CommonMethods sharedInstance] textWidthWithText:self.name height:15.0 fontName:@"ProximaNova-Light" fontSize:fontSize];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, senderNameWidth + 8, kViewHeight);
    self.backgroundColor = [UIColor participantsColor];
    self.layer.cornerRadius = 3;
    
    //setup Name label config
    UILabel *labelSenderName = [[UILabel alloc] initWithFrame:CGRectMake(kLabelOriginX, 0, senderNameWidth, kViewHeight)];
    labelSenderName.backgroundColor = [UIColor clearColor];
    labelSenderName.textColor = [UIColor whiteColor];
    labelSenderName.font = [UIFont fontWithName:@"ProximaNova-Light" size:fontSize];
    labelSenderName.text = self.name;
    [self addSubview:labelSenderName];
}

@end
