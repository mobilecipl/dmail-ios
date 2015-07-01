//
//  CommonMethods.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "CommonMethods.h"
#import "DmailEntityItem.h"
#import "CoreDataManager.h"
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

- (DmailEntityItem *)parseGmailMessageContent:(NSDictionary *)requestReply {
    
    DmailEntityItem *dmailEntityItem = [[DmailEntityItem alloc] initWithClearObjects];
    dmailEntityItem.publicKey = [self getPublicKeyFromSnippet:requestReply[Snippet]];
    dmailEntityItem.gmailId = requestReply[@"id"];
    NSLog(@"dmailEntityItem.gmailId === %@", requestReply);
    if ([[requestReply allKeys] containsObject:Payload]) {
        dmailEntityItem.internalDate = [requestReply[InternalDate] doubleValue];
        NSDictionary *payload = requestReply[Payload];
        if ([[payload allKeys] containsObject:Headers]) {
            NSArray *headers = payload[Headers];
            for (NSDictionary *dict in headers) {
                if ([dict[Name] isEqualToString:From]) {
                    dmailEntityItem.fromEmail = [self getEmailFromValue:dict[Value]];
                    dmailEntityItem.fromName = [self getNameFromvalue:dict[Value]];
                    ProfileItem *profileItem = [[ProfileItem alloc] initWithEmail:dmailEntityItem.fromEmail name:dmailEntityItem.fromName];
                    [[CoreDataManager sharedCoreDataManager] writeOrUpdateParticipantWith:profileItem];
                }
                if ([dict[Name] isEqualToString:To]) {
                    NSArray *array = [dict[Value] componentsSeparatedByString:@","];
                    for (NSString *string in array) {
                        NSString *toEmail = [self getEmailFromValue:string];
                        if (toEmail) {
                            [dmailEntityItem.arrayTo addObject:toEmail];
                        }
                        NSString *toName = [self getNameFromvalue:string];
                        ProfileItem *profileItem = [[ProfileItem alloc] initWithEmail:toEmail name:toName];
                        [[CoreDataManager sharedCoreDataManager] writeOrUpdateParticipantWith:profileItem];
                    }
                }
                //                if ([dict[Name] isEqualToString:Cc]) {
                //                    NSArray *arrayCc = [dict[Value] componentsSeparatedByString:@","];
                //                    dmailEntityItem.fromEmail = [self getEmailFromValue:dict[Value]];
                //                    dmailEntityItem.fromName = [self getNameFromvalue:dict[Value]];
                //                }
                //                if ([dict[Name] isEqualToString:Bcc]) {
                //                    NSArray *arrayCc = [dict[Value] componentsSeparatedByString:@","];
                //                    dmailEntityItem.fromEmail = [self getEmailFromValue:dict[Value]];
                //                    dmailEntityItem.fromName = [self getNameFromvalue:dict[Value]];
                //                }
                if ([dict[Name] isEqualToString:Subject]) {
                    dmailEntityItem.subject = dict[Value];
                }
                if ([dict[Name] isEqualToString:Message_Id]) {
                    dmailEntityItem.identifier = dict[Value];
                }
//                if ([dict[Name] isEqualToString:PublicKey]) {
//                    dmailEntityItem.publicKey = dict[Value];
//                }
                dmailEntityItem.status = MessageFetchedFull;
            }
        }
    }
    
    return dmailEntityItem;
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
