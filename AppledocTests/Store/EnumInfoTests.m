//
//  EnumInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface EnumInfoTests : XCTestCase
@end

@implementation EnumInfoTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// execute & verify
		XCTAssertNotNil(info.enumItems);
	}];
}

#pragma mark - Enumeration name registration

- (void)testEnumerationNameRegistration_ShouldSetName {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// execute
		[info appendEnumerationName:@"name"];
		// verify
		XCTAssertEqualObjects(info.nameOfEnum, @"name");
	}];
}

- (void)testEnumerationNameRegistration_ShouldUseLastValueIfInvokedMultipleTimes {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// setup
		[info appendEnumerationName:@"first"];
		// execute
		[info appendEnumerationName:@"name"];
		// verify
		XCTAssertEqualObjects(info.nameOfEnum, @"name");
	}];
}

#pragma mark - Enumeration item registration

- (void)testEnumerationItemRegistration_ShouldAddAllItemsToItemsArray {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// execute
		[info appendEnumerationItem:@"item1"];
		[info appendEnumerationItem:@"item2"];
		// verify
		XCTAssertEqual(info.enumItems.count, 2ul);
		XCTAssertTrue([(info.enumItems)[0] isMemberOfClass:([EnumItemInfo class])]);
		XCTAssertTrue([(info.enumItems)[1] isMemberOfClass:([EnumItemInfo class])]);
		XCTAssertEqualObjects([(info.enumItems)[0] itemName], @"item1");
		XCTAssertEqualObjects([(info.enumItems)[1] itemName], @"item2");
	}];
}

#pragma mark - Enumeration value registration

- (void)testEnumerationValueRegistration_ShouldSetValueIfSingleItemIsRegistered {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// setup
		[info appendEnumerationItem:@"item"];
		// execute
		[info appendEnumerationValue:@"value"];
		// verify
		XCTAssertEqual(info.enumItems.count, 1ul);
		XCTAssertEqualObjects([(info.enumItems)[0] itemName], @"item");
		XCTAssertEqualObjects([(info.enumItems)[0] itemValue], @"value");
	}];
}

- (void)testEnumerationValueRegistration_ShouldSetValueToLastItemIfMultipleItemsAreRegistered {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// setup
		[info appendEnumerationItem:@"item1"];
		[info appendEnumerationItem:@"item2"];
		// execute
		[info appendEnumerationValue:@"value"];
		// verify
		XCTAssertEqual(info.enumItems.count, 2ul);
		XCTAssertEqualObjects([(info.enumItems)[0] itemName], @"item1");
		XCTAssertNil([(info.enumItems)[0] itemValue]);
		XCTAssertEqualObjects([(info.enumItems)[1] itemName], @"item2");
		XCTAssertEqualObjects([(info.enumItems)[1] itemValue], @"value");
	}];
}
	
- (void)testEnumerationValueRegistration_ShouldIgnoreIfNoItemIsRegistered {
	[self runWithEnumInfo:^(EnumInfo *info) {
		// execute
		[info appendEnumerationValue:@"value"];
		// verify - we log a warning in such case, but we don't test it here!
		XCTAssertEqual(info.enumItems.count, 0ul);
	}];
}


#pragma mark - Creator method

- (void)runWithEnumInfo:(void(^)(EnumInfo *info))handler {
	EnumInfo *info = [[EnumInfo alloc] init];
	handler(info);
}

@end
