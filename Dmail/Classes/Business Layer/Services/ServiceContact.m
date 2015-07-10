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

- (void)getContactsWithPagingForEmail:(NSString *)email
                           startIndex:(NSString *)startIndex
                            maxResult:(NSString *)maxResult
                      completionBlock:(CompletionBlock)completionBlock {
    
    
    __block NSString *startIndexBlock = startIndex;
    [self.daoContact getContactsWithPagingForEmail:email
                                        startIndex:startIndexBlock
                                         maxResult:maxResult
                                   completionBlock:^(NSArray *data, ErrorDataModel *error) {
                                       
                                       if (error) {
                                           completionBlock(nil, error);
                                       }
                                       
                                       if (data == nil || data.count == 0) {
                                           completionBlock(nil, error);
                                       } else {
                                           startIndexBlock = [NSString stringWithFormat:@"%li", startIndexBlock.integerValue + maxResult.integerValue];
                                           completionBlock(data, nil);
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
