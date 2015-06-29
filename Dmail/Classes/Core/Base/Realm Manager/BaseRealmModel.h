//
//  BaseRealmModel.h
//  pium
//
//  Created by Armen Mkrtchian on 17/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "RLMObject.h"
#import <RLMArray.h>

@interface BaseRealmModel : RLMObject

- (void)saveInDefaultRealm;
- (void)saveInRealm:(RLMRealm *)realm;

//- (void)createOrUpdateInDefaultRealm;
//- (void)createOrUpdateInRealm:(RLMRealm *)realm;

+ (void)removeAllObjects;

@end
