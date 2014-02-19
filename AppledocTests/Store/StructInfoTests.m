//
//  StructInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//


#import "Store.h"
#import "TestCaseBase.h"

@interface StructInfoTests : XCTestCase
@end

@implementation StructInfoTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithStructInfo:^(StructInfo *info) {
		// execute & verify
		XCTAssertNotNil(info.structItems);
	}];
}

#pragma mark - Struct data registration

- (void)testStructDataRegistration_ShouldAssignStructName {
	[self runWithStructInfo:^(StructInfo *info) {
		// execute
		[info appendStructName:@"name"];
		// verify
		XCTAssertEqualObjects(info.nameOfStruct, @"name");
	}];
}

#pragma mark - Constant registration

- (void)testConstantRegistration_ShouldCreateNewConstantInfoAndAddItToStructItems {
	[self runWithStructInfo:^(StructInfo *info) {
		// setup
		info.objectRegistrar = mock([Store class]);
		// execute
		[info beginConstant];
		// verify
		XCTAssertEqual(info.structItems.count, 1ul);
		XCTAssertTrue([info.structItems.lastObject isMemberOfClass:([ConstantInfo class])]);
		XCTAssertEqualObjects([info.structItems.lastObject objectRegistrar], info.objectRegistrar);
	}];
}

- (void)testConstantRegistration_ShouldPushConstantInfoToRegistrationStack {
	[self runWithStructInfo:^(StructInfo *info) {
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginConstant];
		// verify
		MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
		[verify(mock) pushRegistrationObject:[argument capture]];
		XCTAssertTrue([[argument value] isKindOfClass:([ConstantInfo class])]);
	}];
}

- (void)testConstantRegistration_ShouldSetCurrentSourceInfoToClass {
	[self runWithStructInfoWithRegistrar:^(StructInfo *info, Store *store) {
		// setup
		info.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[info beginConstant];
		// verify
		XCTAssertEqualObjects([info.currentRegistrationObject sourceToken], info.currentSourceInfo);
	}];
}

#pragma mark - Object cancellation

- (void)testObjectCancellation_ShouldRemoveConstantInfo {
	[self runWithStructInfo:^(StructInfo *info) {
		// setup
		[info beginConstant];
		id mock = mock([Store class]);
		[given([mock currentRegistrationObject]) willReturn:info.structItems.lastObject];
		info.objectRegistrar = mock;
		// execute
		[info cancelCurrentObject];
		// verify
		XCTAssertEqual(info.structItems.count, 0ul);
	}];
}

#pragma mark - Creator methods

- (void)runWithStructInfo:(void(^)(StructInfo *info))handler {
	StructInfo *info = [[StructInfo alloc] init];
	handler(info);
}

- (void)runWithStructInfoWithRegistrar:(void(^)(StructInfo *info, Store *store))handler {
	[self runWithStructInfo:^(StructInfo *info) {
		Store *store = [[Store alloc] init];
		info.objectRegistrar = store;
		handler(info, store);
	}];
}

@end