//
//  CommonMethods.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "CommonMethods.h"
#import "DmailEntityItem.h"
#import "ProfileItem.h"

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

- (NSString *)getPublicKeyFromSnippet:(NSString *)snippet {
    
    NSString *publicKey = @"";
    
    NSArray *array = [snippet componentsSeparatedByString:@"PublicKey="];
    if([array count] > 1) {
        publicKey = [array objectAtIndex:1];
    }
    
    return publicKey;
}

- (NSString *)getEmailFromValue:(NSString *)value {
    
    NSString *email;
    NSArray *arraySubStrings = [value componentsSeparatedByString:@"<"];
    if ([arraySubStrings count] > 1) {
        NSLog(@"arraySubStrings ==== %@", arraySubStrings);
        email = [[arraySubStrings objectAtIndex:1] substringToIndex:[[arraySubStrings objectAtIndex:1] length]-1];
    }
    else {
        email = value;
    }
    
    return email;
}

- (NSString *)getNameFromvalue:(NSString *)value {
    
    NSString *name;
    
    NSArray *arraySubStrings = [value componentsSeparatedByString:@"<"];
    if ([arraySubStrings count] > 1) {
        NSLog(@"arraySubStrings ==== %@", arraySubStrings);
        name = [arraySubStrings firstObject];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    return name;
}


@end
