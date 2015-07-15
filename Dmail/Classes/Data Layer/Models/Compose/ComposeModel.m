//
//  ComposeModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ComposeModel.h"
#import "ComposeModelItem.h"
#import "ServiceProfile.h"
#import "DmailMessage.h"
#import "DmailEntityItem.h"
#import "ServiceProfile.h"
#import "ProfileItem.h"
#import "CommonMethods.h"

@interface ComposeModel ()

@property (nonatomic, strong) NSString *dmailId;
@property (nonatomic, strong) NSArray *arrayAllParticipants;
@property (nonatomic, assign) NSInteger index;

@end

@implementation ComposeModel

#pragma mark - Private Methods
- (NSDictionary *)createRecipientsDictWithArrayTo:(NSArray *)arrayTO arrayCC:(NSArray *)arrayCC arrayBCC:(NSArray *)arrayBCC {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *to in arrayTO) {
        [dict setObject:@"TO" forKey:@"recipient_type"];
        [dict setObject:to forKey:@"recipient_email"];
    }
//    for (NSString *cc in arrayCC) {
//        [dict setObject:@"CC" forKey:@"recipient_type"];
//        [dict setObject:cc forKey:@"recipient_email"];
//    }
//    for (NSString *bcc in arrayBCC) {
//        [dict setObject:@"BCC" forKey:@"recipient_type"];
//        [dict setObject:bcc forKey:@"recipient_email"];
//    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)createMessageBodyForGmailWithArrayTo:(NSArray *)arrayTO arrayCC:(NSArray *)arrayCC arrayBCC:(NSArray *)arrayBCC subject:(NSString *)subject body:(NSString *)body{
    
    NSString *from = [NSString stringWithFormat:@"From: %@ <%@>\n",[[ServiceProfile sharedInstance] fullName],[[ServiceProfile sharedInstance] email]];
    for (NSString *to in arrayTO) {
        NSString *stringTo = [NSString stringWithFormat:@"To: <%@>\n", to];
        from = [from stringByAppendingString:stringTo];
    }
//    for (NSString *cc in arrayCC) {
//        NSString *stringCC = [NSString stringWithFormat:@"Cc: <%@>\n", cc];
//        from = [from stringByAppendingString:stringCC];
//    }
//    for (NSString *bcc in arrayBCC) {
//        NSString *stringBCC = [NSString stringWithFormat:@"Bcc: <%@>\n", bcc];
//        from = [from stringByAppendingString:stringBCC];
//    }
    
    NSString *stringSubject = [NSString stringWithFormat:@"Subject: %@\n\n",subject];
    from = [from stringByAppendingString:stringSubject];
    
    from = [from stringByAppendingString:body];
    
    return from;
}


#pragma mark - Public Methods

- (NSArray *)createParticipantsArray:(NSArray *)arrayTo arrayCc:(NSArray *)arrayCc arrayBcc:(NSArray *)arrayBcc {
    
    NSMutableArray *arrayParticipants = [[NSMutableArray alloc] init];
    for (NSString *str in arrayTo) {
        NSDictionary *dict = @{@"recipient_type" : @"TO",
                               @"recipient_email" : str
                               };
        [arrayParticipants addObject:dict];
    }
    for (NSString *str in arrayCc) {
        NSDictionary *dict = @{@"recipient_type" : @"CC",
                               @"recipient_email" : str
                               };
        [arrayParticipants addObject:dict];
    }
    for (NSString *str in arrayBcc) {
        NSDictionary *dict = @{@"recipient_type" : @"BCC",
                               @"recipient_email" : str
                               };
        [arrayParticipants addObject:dict];
    }
    
    return [NSArray arrayWithArray:arrayParticipants];
}

@end
