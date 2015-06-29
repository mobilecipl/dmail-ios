//
//  SuccessDataModel.h
//  Core
//
//  Created by Armen on 5/27/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "BaseDataModel.h"

@interface SuccessDataModel : BaseDataModel

@property(nonatomic, strong) NSString *data;
@property(nonatomic, strong) NSString *message;

@end
