//
//  BaseDataModel.m
//  Core
//
//  Created by Armen on 4/7/14.
//  Copyright (c) 2014 Armen Mkrtchian All rights reserved.
//

#import "BaseDataModel.h"

@implementation BaseDataModel
-(instancetype)initWithDictionary:(NSDictionary*)dict
{
    NSError *error;
    self = [super initWithDictionary:dict error:&error];
    if (error) {
        NSLog(@"Jsonmodel error: %@", [error description]);
    }
    
    if (self)
    {
//        _rowid = nilOrJSONObjectForKey(dict, kRowId);
    }
    
    return self;
}

//+(JSONKeyMapper*)keyMapper
//{
//    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
//}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end
