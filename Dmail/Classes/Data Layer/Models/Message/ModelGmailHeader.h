//
//  ModelGmailHeader.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"

@protocol ModelGmailHeader <NSObject>
@end

@interface ModelGmailHeader : BaseDataModel
@property NSString *name;
@property NSString *value;
@end
