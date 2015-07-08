//
//  ModelGmailPayload.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"

@protocol ModelGmailPayload <NSObject>
@end

@interface ModelGmailPayload : BaseDataModel

@property NSDictionary *body;
@property NSString *filename;
@property NSArray <ModelGmailHeader>*headers;
@property NSString *mimeType;
@property NSString *partId;

@end

/*
payload =     {
    body =         {
        data = "RG1haWxJZD1iZmZkMDU5ZjE5Y2ZjYzQyMDY0MjQxZTliNzQxOWM3YjU3NGFlNWMxJlB1YmxpY0tleT0xNDM2MjYxMTIzLjQ2Nzk2Mw==";
        size = 76;
    };
    filename = "";
    headers =         (
                       {
                           name = Received;
                           value = "from 979289221522-lcmi7bj6qcqsp09hsrsrv8l5in49e7qi.apps.googleusercontent.com named Dmail by gmailapi.google.com with HTTPREST; Tue, 7 Jul 2015 05:25:22 -0400";
                       },
                       {
                           name = From;
                           value = "Armen Mkrtchian <amkrtchian@science-inc.com>";
                       },
                       {
                           name = To;
                           value = "<amkrtchian@science-inc.com>";
                       },
                       {
                           name = Subject;
                           value = Hey;
                       },
                       {
                           name = PublicKey;
                           value = "1436261123.467963";
                       },
                       {
                           name = DmailId;
                           value = bffd059f19cfcc42064241e9b7419c7b574ae5c1;
                       },
                       {
                           name = Date;
                           value = "Tue, 7 Jul 2015 05:25:22 -0400";
                       },
                       {
                           name = "Message-Id";
                           value = "<CAO3+t9f0nAsRdb=b2WqPShYqgqM=He1rxKUZnjKs-SQPB2rSLA@mail.gmail.com>";
                       }
                       );
    mimeType = "text/plain";
    partId = "";
};
*/