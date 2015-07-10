//
//  BaseDataModel.h
//  Core
//
//  Created by Armen on 4/7/14.
//  Copyright (c) 2014 Armen Mkrtchian All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSONModel.h"

@interface BaseDataModel : JSONModel
//@property (nonatomic, strong) NSNumber <Optional>* rowid;
- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithRealm:(id)realm;
@end
