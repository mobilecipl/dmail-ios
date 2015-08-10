//
//  ModelGmailMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"

#import "ModelGmailPayload.h"

@interface ModelGmailMessage : BaseDataModel

//
@property NSString *gmailId;
@property NSNumber *internalDate;
@property NSArray *labelIds;
@property ModelGmailPayload *payload;
@property NSString *snippet;
@property NSString *publicKey;
@property NSArray *arrayLabels;


//@property NSString *dmailId;
//@property NSString *identifier;
//
//@property NSString *from;
//@property NSString *to;
//@property NSString *cc;
//@property NSString *bcc;
//@property NSString *label;
//@property NSString *subject;
//@property NSString *publicKey;
//
//@property int type;




@end

/*
{
    historyId = 103858;
    id = 14e67d5812abf9a7;
    internalDate = 1436261122000;
    labelIds =     (
                    SENT,
                    INBOX
                    );
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
    sizeEstimate = 557;
    snippet = "DmailId=bffd059f19cfcc42064241e9b7419c7b574ae5c1&amp;PublicKey=1436261123.467963";
    threadId = 14e67d5812abf9a7;
}
*/