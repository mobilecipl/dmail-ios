//
//  ComposeModelItem.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComposeModelItem : NSObject

@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSArray *arrayTo;
@property (nonatomic, strong) NSArray *arrayCc;
@property (nonatomic, strong) NSArray *arrayBcc;


- (instancetype)initWithSubject:(NSString *)subject body:(NSString *)body arrayTo:(NSArray *)to arrayCC:(NSArray *)CC arrayBCC:(NSArray *)BCC;

@end
