//
//  ServiceGoogleOauth2.m
//  Dmail
//
//  Created by Karen Petrosyan on 9/22/15.
//  Copyright © 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceGoogleOauth2.h"
#import "ServiceProfile.h"

@interface ServiceGoogleOauth2 ()

@property (nonatomic, retain) GTMOAuth2Authentication *auth;
@property (nonatomic, strong) ServiceProfile *serviceProfile;

@end


@implementation ServiceGoogleOauth2

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _serviceProfile = [[ServiceProfile alloc] init];
    }
    
    return self;
}

- (void)authorizeRequestWithAuth:(GTMOAuth2Authentication *)auth completion:(CompletionBlock)completionBlock {
    
    self.auth = auth;
    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionaryWithDictionary:self.auth.parameters];
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/plus/v1/people/me/activities/public"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [self.auth authorizeRequest:request completionHandler:^(NSError *error) {
        NSString *output = nil;
        if (error) {
            output = [error description];
        } else {
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (data) {
                output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                NSArray *array = [json objectForKey:@"items"];
                if (array.count > 0) {
                    NSDictionary *dict = [array objectAtIndex:0];
                    NSDictionary *userInfo = dict[@"actor"];
                    [userInfoDict setObject:userInfo[@"displayName"] forKey:@"fullName"];
                    [userInfoDict setObject:userInfo[@"image"][@"url"] forKey:@"imageUrl"];
                    NSString *keychanName = [self.serviceProfile getLastProfileKeychanName];
                    [userInfoDict setObject:keychanName forKey:@"keychainName"];
                    [self.serviceProfile updateUserDetails:userInfoDict];
                    completionBlock(userInfoDict, nil);
                }
            }
        }
    }];
}

@end
