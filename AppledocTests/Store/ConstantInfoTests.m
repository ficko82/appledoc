//
//  ConstantInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface ConstantInfoTests : XCTestCase
@end

@implementation ConstantInfoTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithConstantInfo:^(ConstantInfo *info) {
		// execute & verify
		XCTAssertTrue([info.constantTypes isMemberOfClass:([TypeInfo class])]);
		XCTAssertTrue([info.constantDescriptors isMemberOfClass:([DescriptorsInfo class])]);
	}];
}

#pragma mark - Constant types registration

- (void)testConstantTypesRegistration_ShouldChangeCurrentRegistrationObjectToConstantTypesInfo {
	[self runWithConstantInfo:^(ConstantInfo *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginConstantTypes];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:info.constantTypes]);
	}];
}

#pragma mark - Constant name registration

- (void)testConstantNameRegistration_ShouldAssignGivenString {
	[self runWithConstantInfo:^(ConstantInfo *info) {
		// execute
		[info appendConstantName:@"value"];
		// verify
		XCTAssertEqualObjects(info.constantName, @"value");
	}];
}

- (void)testConstantNameRegistration_ShouldUseLastValueIfSentMultipleTimes {
	[self runWithConstantInfo:^(ConstantInfo *info) {
		// execute
		[info appendConstantName:@"value1"];
		[info appendConstantName:@"value2"];
		// verify
		XCTAssertEqualObjects(info.constantName, @"value2");
	}];
}

#pragma mark - Constant descriptors registration

- (void)testConstantDescriptorsRegistration_ShouldPushDecriptorsInfoToRegistrationStack {
	[self runWithConstantInfo:^(ConstantInfo *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginConstantDescriptors];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:info.constantDescriptors]);
	}];
}

#pragma Creator method

- (void)runWithConstantInfo:(void(^)(ConstantInfo *info))handler {
	ConstantInfo *info = [[ConstantInfo alloc] init];
	handler(info);
}

@end
