//
//  AttributesInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface AttributesInfoTests : XCTestCase
@end

@implementation AttributesInfoTests


#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// execute & verify
		XCTAssertNotNil(info.attributeItems);
	}];
}

#pragma mark - Attribute value

- (void)testAttributeValue_ShouldReturnValueBasedOnEqualToken {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// setup
		info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute", @"=", @"value", @"suffix", nil];
		// execute & verify
		XCTAssertEqualObjects([info valueForAttribute:@"attribute"], @"value");
	}];
}

- (void)testAttributeValue_ShouldReturnCorrectValueIfMultipleAttributesArePresent {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// setup
		info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute1", @"=", @"value1", @"attribute2", @"=", @"value2", @"suffix", nil];
		// execute & verify
		XCTAssertEqualObjects([info valueForAttribute:@"attribute1"], @"value1");
		XCTAssertEqualObjects([info valueForAttribute:@"attribute2"], @"value2");
	} ];
}

- (void)testAttributeValue_ShouldReturnFirstAttributeValueIfMultipleAttributesWithTheSameNameArePresent {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// setup
		info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute", @"=", @"value1", @"attribute", @"=", @"value2", @"suffix", nil];
		// execute & verify
		XCTAssertEqualObjects([info valueForAttribute:@"attribute"], @"value1");
	}];
}

- (void)testAttributeValue_ShouldReturnNilIfAtrributeNameIsNotPresent {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// setup
		info.attributeItems = [NSMutableArray arrayWithObjects:@"prefix", @"attribute", @"=", @"value", @"suffix", nil];
		// execute & verify
		XCTAssertNil([info valueForAttribute:@"prefix"]);
		XCTAssertNil([info valueForAttribute:@"suffix"]);
		XCTAssertNil([info valueForAttribute:@"attr"]);
		XCTAssertNil([info valueForAttribute:@"attribute1"]);
		XCTAssertNil([info valueForAttribute:@"="]);
		XCTAssertNil([info valueForAttribute:@"value"]);
	}];
}

#pragma mark - Appending atrributes

- (void)testAppendingAtrributes_ShouldAddAllStringsToTypeItemsArray {
	[self runWithPropertyAttributesInfo:^(AttributesInfo *info) {
		// execute
		[info appendAttribute:@"type1"];
		[info appendAttribute:@"type2"];
		// verify
		XCTAssertEqual(info.attributeItems.count, 2ul);
		XCTAssertEqualObjects((info.attributeItems)[0], @"type1");
		XCTAssertEqualObjects((info.attributeItems)[1], @"type2");
	}];
}

#pragma mark - Creator method

- (void)runWithPropertyAttributesInfo:(void(^)(AttributesInfo *info))handler {
	AttributesInfo *info = [[AttributesInfo alloc] init];
	handler(info);
}

@end