//
//  MethodInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//


#import "Store.h"
#import "TestCaseBase.h"

@interface MethodInfoTests : XCTestCase
@end


@implementation MethodInfoTests

#pragma mark - Lazy accessories

- (void)testLazyAccessories_ShouldInitializeObjects {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// execute & verify
		XCTAssertTrue([info.methodResult isMemberOfClass:([TypeInfo class])]);
		XCTAssertNotNil(info.methodDescriptors);
		XCTAssertNotNil(info.methodArguments);
	}];
}

#pragma mark - Selector, unique ID and cross reference template

- (void)testSelectorUniqueIdAndCrossReferenceTemplate_ShouldHandleClassMethod {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		MethodArgumentInfo *argument = [[MethodArgumentInfo alloc] init];
		argument.argumentSelector = @"method";
		[info.methodArguments addObject:argument];
		info.methodType = GBStoreTypes.classMethod;
		// execute & verify
		XCTAssertEqualObjects(info.uniqueObjectID, @"+method");
		XCTAssertEqualObjects(info.objectCrossRefPathTemplate, @"#+method");
	}];
}

- (void)testSelectorUniqueIdAndCrossReferenceTemplate_ShouldHandleSingleArgument {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		MethodArgumentInfo *argument = [[MethodArgumentInfo alloc] init];
		argument.argumentSelector = @"method";
		[info.methodArguments addObject:argument];
		// execute & verify
		XCTAssertEqualObjects(info.uniqueObjectID, @"-method");
		XCTAssertEqualObjects(info.objectCrossRefPathTemplate, @"#-method");
	}];
}

- (void)testSelectorUniqueIdAndCrossReferenceTemplate_ShouldHandleSingleArgumentWithVariable {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		MethodArgumentInfo *argument = [[MethodArgumentInfo alloc] init];
		argument.argumentSelector = @"method";
		argument.argumentVariable = @"var";
		[info.methodArguments addObject:argument];
		// execute & verify
		XCTAssertEqualObjects(info.uniqueObjectID, @"-method:");
		XCTAssertEqualObjects(info.objectCrossRefPathTemplate, @"#-method:");
	}];
}

- (void)testSelectorUniqueIdAndCrossReferenceTemplate_ShouldHandleMultipleArguments {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		MethodArgumentInfo *argument1 = [[MethodArgumentInfo alloc] init];
		argument1.argumentSelector = @"method";
		argument1.argumentVariable = @"var";
		[info.methodArguments addObject:argument1];
		MethodArgumentInfo *argument2 = [[MethodArgumentInfo alloc] init];
		argument2.argumentSelector = @"withArg";
		argument2.argumentVariable = @"var";
		[info.methodArguments addObject:argument2];
		// execute & verify
		XCTAssertEqualObjects(info.uniqueObjectID, @"-method:withArg:");
		XCTAssertEqualObjects(info.objectCrossRefPathTemplate, @"#-method:withArg:");
	}];
}

#pragma mark - Class or interface method helpers 

- (void)testClassOrInterfaceMethodHelpers_ShouldWorkForClassMethod {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		info.methodType = GBStoreTypes.classMethod;
		// execute & verify
		XCTAssertEqual(info.isClassMethod, YES);
		XCTAssertEqual(info.isInstanceMethod, NO);
		XCTAssertEqual(info.isProperty, NO);
	}];
}

- (void)testClassOrInterfaceMethodHelpers_ShouldWorkForInstanceMethod {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		info.methodType = GBStoreTypes.instanceMethod;
		// execute & verify
		XCTAssertEqual(info.isClassMethod, NO);
		XCTAssertEqual(info.isInstanceMethod, YES);
		XCTAssertEqual(info.isProperty, NO);
	}];
}

#pragma mark - Method results registration

- (void)testMethodResultsRegistration_ShouldChangeCurrentRegistrationObjectToResults {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginMethodResults];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:instanceOf([TypeInfo class])]);
	}];
}

#pragma mark - Method argument registration

- (void)testMethodArgumentRegistration_ShouldCreateNewMethodArgument {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		info.objectRegistrar = mock([Store class]);
		// execute
		[info beginMethodArgument];
		// verify
		XCTAssertEqual(info.methodArguments.count, 1ul);
		XCTAssertTrue([info.methodArguments.lastObject isMemberOfClass:([MethodArgumentInfo class])]);
		XCTAssertEqualObjects([info.methodArguments.lastObject objectRegistrar], info.objectRegistrar);
	}];
}

- (void)testMethodArgumentRegistration_ShouldPushArgumentToRegistrationStack {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginMethodArgument];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:instanceOf([MethodArgumentInfo class])]);
	}];
}

#pragma mark - Method descriptors registration

- (void)testMethodDescriptorsRegistration_ShouldChangeCurrentRegistrationObjectToDescriptorsInfo {
	[self runWithMethodInfo:^(MethodInfo *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginMethodDescriptors];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:instanceOf([DescriptorsInfo class])]);
	}];
}

#pragma mark - Object cancellation

- (void)testObjectCancellation_ShouldRemoveMethodArgumentIfCurrentRegistrationObjectIsDifferent {
	[self runWithMethodInfoWithRegistrar:^(MethodInfo *info, Store *store) {
		// setup
		[info beginMethodArgument];
		// execute
		[info cancelCurrentObject];
		// verify
		XCTAssertEqual(info.methodArguments.count, 0ul);
	}];
}

- (void)testObjectCancellation_ShouldNOTRemoveMethodArgumentIfCurrentRegistrationObjectIsDifferent {
	[self runWithMethodInfoWithRegistrar:^(MethodInfo *info, Store *store) {
		// setup
		[info beginMethodArgument];
		[info beginMethodResults];
		// execute
		[info cancelCurrentObject];
		// verify
		XCTAssertEqual(info.methodArguments.count, 1ul);
	}];
}

#pragma mark - Creator methods

- (void)runWithMethodInfo:(void(^)(MethodInfo *info))handler {
	MethodInfo *info = [[MethodInfo alloc] init];
	handler(info);
}

- (void)runWithMethodInfoWithRegistrar:(void(^)(MethodInfo *info, Store *store))handler {
	[self runWithMethodInfo:^(MethodInfo *info) {
		Store *store = [[Store alloc] init];
		info.objectRegistrar = store;
		handler(info, store);
	}];
}

@end