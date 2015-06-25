//
//  CommonMethods.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "CommonMethods.h"

@implementation CommonMethods

+ (CommonMethods *)sharedInstance {
    static CommonMethods *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CommonMethods alloc] init];
    });
    
    return sharedInstance;
}

- (CGFloat)textWidthWithText:(NSString *)text height:(CGFloat)height fontName:(NSString *)fontName fontSize:(CGFloat)fontSize {
    
    NSDictionary *headerAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:fontName size:fontSize], NSFontAttributeName, nil];
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,height)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:headerAttributes
                                         context:nil];
    return textSize.size.width;
}

@end
