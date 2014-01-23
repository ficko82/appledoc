//
//  TypeInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface TypeInfoTests : XCTestCase
@end

@implementation TypeInfoTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithTypeInfo:^(TypeInfo *info) {
		XCTAssertNotNil(info.typeItems);
	}];
}

#pragma mark - Append type

- (void)testAppendType_ShouldAddAllStringsToTypeItemsArray {
	[self runWithTypeInfo:^(TypeInfo *info) {
		// execute
		[info appendType:@"type1"];
		[info appendType:@"type2"];
		// verify
		XCTAssertEqual(info.typeItems.count, 2ul);
		XCTAssertEqualObjects((info.typeItems)[0], @"type1");
		XCTAssertEqualObjects((info.typeItems)[1], @"type2");
	}];
}

#pragma mark - Creator method

- (void)runWithTypeInfo:(void(^)(TypeInfo *info))handler {
	TypeInfo *info = [[TypeInfo alloc] init];
	handler(info);
}

@end