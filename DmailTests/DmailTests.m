//
//  DmailTests.m
//  DmailTests
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NetworkMessage.h"

@interface DmailTests : XCTestCase
@property (nonatomic, strong) NetworkMessage *networkMessage;
@end

@implementation DmailTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _networkMessage = [[NetworkMessage alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSendEncryptedMessage {
    // This is an example of a functional test case.
    
    NSURL *URL = [NSURL URLWithString:@"http://nshipster.com/"];
    NSString *description = [NSString stringWithFormat:@"GET %@", URL];
    XCTestExpectation *expectation = [self expectationWithDescription:description];

    
    NSString *message = @"encrypted message";
    NSString *senderEmail = @"senderEmail";
    
    [self.networkMessage sendEncryptedMessage:message senderEmail:senderEmail completionBlock:^(id data, ErrorDataModel *error) {
        
        NSLog(@"sendEncryptedMessage data : %@, error : %@", data, error);
        XCTAssertNotNil(data, "data should not be nil");
        XCTAssertNil(error, "error should be nil");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
