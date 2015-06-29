//
//  BaseNetwork.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/17/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFOAuth2Manager.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "Constants.h"
#import "Configurations.h"

static NSString * const baseURL = @"http://dmail-dev.elasticbeanstalk.com/";
//static NSString * const baseURL = @"http://192.168.0.100:8080/dmail/";

@interface BaseNetwork : NSObject

@end
