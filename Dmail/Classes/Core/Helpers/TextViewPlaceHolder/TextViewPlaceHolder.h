//
//  TextViewPlaceHolder.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewPlaceHolder : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
