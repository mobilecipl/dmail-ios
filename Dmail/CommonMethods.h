//
//  CommonMethods.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CommonMethods : NSObject

+ (CommonMethods *)sharedInstance;
- (CGFloat)textWidthWithText:(NSString *)text height:(CGFloat)height fontName:(NSString *)fontName fontSize:(CGFloat)fontSize;

@end
