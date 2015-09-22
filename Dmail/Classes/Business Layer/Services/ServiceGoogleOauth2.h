//
//  ServiceGoogleOauth2.h
//  Dmail
//
//  Created by Karen Petrosyan on 9/22/15.
//  Copyright © 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseService.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"


@interface ServiceGoogleOauth2 : BaseService

- (void)authorizeRequestWithAuth:(GTMOAuth2Authentication *)auth completion:(CompletionBlock)completionBlock;

@end
