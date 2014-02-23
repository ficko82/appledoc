//
//  MethodArgumentInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface MethodArgumentInfoTests : XCTestCase
@end

@implementation MethodArgumentInfoTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute & verify
		XCTAssertTrue([info.argumentType isMemberOfClass:([TypeInfo class])]);
	}];
}

#pragma mark - Method argument types registration

- (void)testMethodArgumentTypesRegistration_ShouldPushArgumentTypeToRegistrationStack {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginMethodArgumentTypes];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:info.argumentType]);
	}];
}

#pragma mark - Method rgument selector registration

- (void)testMethodArgumentSelectorRegistration_ShouldAssignGivenString {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute
		[info appendMethodArgumentSelector:@"value"];
		// verify
		XCTAssertEqualObjects(info.argumentSelector, @"value");
	}];
}

- (void)testMethodArgumentSelectorRegistration_ShouldUseLastValueIfSentMultipleTimes {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute
		[info appendMethodArgumentSelector:@"value1"];
		[info appendMethodArgumentSelector:@"value2"];
		// verify
		XCTAssertEqualObjects(info.argumentSelector, @"value2");
	}];
}

#pragma mark - Method argument variable registration

- (void)testMethodArgumentVariableRegistration_ShouldAssignGivenString {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute
		[info appendMethodArgumentVariable:@"value"];
		// verify
		XCTAssertEqualObjects(info.argumentVariable, @"value");
	}];
}

- (void)testMethodArgumentVariableRegistration_ShouldUseLastValueIfSentMultipleTimes {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute
		[info appendMethodArgumentVariable:@"value1"];
		[info appendMethodArgumentVariable:@"value2"];
		// verify
		XCTAssertEqualObjects(info.argumentVariable, @"value2");
	}];
}

#pragma mark - Helper methods

- (void)testHelperMethods_IsUsingVariable_ShouldReturnYesIfTypeIsRegistered {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// setup
		[info beginMethodArgumentTypes];
		// execute & verify
		XCTAssertEqual(info.isUsingVariable, YES);
	}];
}

- (void)testHelperMethods_IsUsingVariable_ShouldReturnYesIfVariable {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// setup
		[info appendMethodArgumentVariable:@"var"];
		// execute & verify
		XCTAssertEqual(info.isUsingVariable, YES);
	}];
}

- (void)testHelperMethods_IsUsingVariable_ShouldReturnNoIfTypeAndVariableAreMissing {
	[self runWithMethodArgumentInfo:^(MethodArgumentInfo *info) {
		// execute & verify
		XCTAssertEqual(info.isUsingVariable, NO);
	}];
}

#pragma mark - Creator method

- (void)runWithMethodArgumentInfo:(void(^)(MethodArgumentInfo *info))handler {
	MethodArgumentInfo *info = [[MethodArgumentInfo alloc] init];
	handler(info);
};

@end
