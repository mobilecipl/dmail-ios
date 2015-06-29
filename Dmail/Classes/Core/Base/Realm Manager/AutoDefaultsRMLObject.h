//
//  AutoDefaultsRMLObject.h
//  pium
//
//  Created by Armen Mkrtchian on 28/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "BaseRealmModel.h"

@interface AutoDefaultsRMLObject : BaseRealmModel
@end

//Categories for easier default value handling
@interface NSString (Defaults)

+ (NSString *)defaultString;
- (BOOL)isDefault;

@end

@interface NSDate (Defaults)

+ (NSDate *)defaultDate;
- (BOOL)isDefault;

@end

@interface NSData (Defaults)

+ (NSData *)defaultData;
- (BOOL)isDefault;

@end
