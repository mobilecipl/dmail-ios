//
//  ErrorDataModel.h
//  Core
//
//  Created by Armen on 3/28/14.
//  Copyright (c) 2014 Armen Mkrtchian All rights reserved.
//


#import "BaseDataModel.h"

@interface ErrorDataModel : BaseDataModel

@property(nonatomic, strong) NSNumber *statusCode;
@property(nonatomic, strong) NSString *data;
@property(nonatomic, strong) NSString *message;

-(instancetype)initWithError:(NSError *)error;

@end
