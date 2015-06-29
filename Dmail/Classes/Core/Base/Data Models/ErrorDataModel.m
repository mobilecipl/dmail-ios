//
//  ErrorDataModel.m
//  Core
//
//  Created by Armen on 3/28/14.
//  Copyright (c) 2014 Armen Mkrtchian All rights reserved.
//

#import "ErrorDataModel.h"

@implementation ErrorDataModel

-(instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self)
    {
        _statusCode = dict[@"errorCode"];
        _message = dict[@"errorMessage"] ? dict[@"errorMessage"] : kGlobalAlertMessageBasicFailure;
    }
    
    return self;
}

-(instancetype)initWithError:(NSError *)error {
    self = [super init];
    
    if (self)
    {
        _statusCode = [NSNumber numberWithInteger:error.code];
        _data = @"";
        _message = error.localizedDescription;
    }
    
    return self;
}

@end
