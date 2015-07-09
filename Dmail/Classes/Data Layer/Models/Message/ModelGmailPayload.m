//
//  ModelGmailPayload.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ModelGmailPayload.h"

@implementation ModelGmailPayload

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    
    self = [super initWithDictionary:dict error:err];
    if (self) {
        
        for (ModelGmailHeader *header in self.headers) {
            if ([header.name isEqualToString:@"From"]) {
                
                self.from = header.value;
                continue;
            }
            
            if ([header.name isEqualToString:@"To"]) {
                
                self.to = header.value;
                continue;
            }
            
            if ([header.name isEqualToString:@"Subject"]) {
               
                self.subject = header.value;
                continue;
            }
            
            if ([header.name isEqualToString:@"Date"]) {
                
                self.messageDate = header.value;
                continue;
            }
            
            if ([header.name isEqualToString:@"Message-Id"]) {
                
                self.messageIdentifier = header.value;
                continue;
            }
        }
    }
    
    return self;
}

@end
