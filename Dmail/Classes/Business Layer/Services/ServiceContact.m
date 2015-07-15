//
//  ServiceContact.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceContact.h"
#import "DAOContact.h"
#import "ContactModel.h"

@interface ServiceContact ()

@property (nonatomic, strong) DAOContact *daoContact;

@end

@implementation ServiceContact

- (instancetype)init {
    
    if (self) {
        _daoContact = [[DAOContact alloc] init];
    }
    
    return self;
}

- (NSMutableArray *)getContactsWithName:(NSString *)name {
    
    return [self.daoContact getContactsWithName:name];
}

- (void)getContactsWithPagingForEmail:(NSString *)email
                            maxResult:(NSString *)maxResult
                      completionBlock:(CompletionBlock)completionBlock {
    
    [self getContactsWithPagingForEmail:email
                             startIndex:@"1"
                              maxResult:maxResult
                        completionBlock:^(id data, ErrorDataModel *error) {
                            
                            completionBlock(data, error);
                        }];
}

- (void)getContactsWithPagingForEmail:(NSString *)email
                           startIndex:(NSString *)startIndex
                            maxResult:(NSString *)maxResult
                      completionBlock:(CompletionBlock)completionBlock {
    
    
    __block NSString *startIndexBlock = startIndex;
    [self.daoContact getContactsForEmail:email
                              startIndex:startIndexBlock
                               maxResult:maxResult
                         completionBlock:^(NSArray *contacts, ErrorDataModel *error) {
                             
                             if (error) {
                                 
                                 completionBlock(nil, error);
                             } else if (contacts == nil || (contacts.count < [maxResult integerValue]) ) {
                                 
                                 completionBlock(nil, error);
                             } else {
                                 
                                 startIndexBlock = [NSString stringWithFormat:@"%i", startIndexBlock.intValue + maxResult.intValue];
                                 [self getContactsWithPagingForEmail:email
                                                          startIndex:startIndexBlock
                                                           maxResult:maxResult
                                                     completionBlock:^(id data, ErrorDataModel *error) {
                                                         
                                                         completionBlock(data, error);
                                                     }];
                             }
                         }];
}


@end
