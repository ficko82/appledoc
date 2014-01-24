//
//  DescriptorsInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface DescriptorsInfoTests : XCTestCase
@end

@implementation DescriptorsInfoTests


#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithPropertyDescriptorsInfo:^(DescriptorsInfo *info) {
		// execute & verify
		XCTAssertNotNil(info.descriptorItems);
	}];
}

#pragma mark - Appending descriptors

- (void)testAppendingDescriptors_ShouldAddAllStringsToDescriptorItemsArray {
	[self runWithPropertyDescriptorsInfo:^(DescriptorsInfo *info) {
		// execute
		[info appendDescriptor:@"type1"];
		[info appendDescriptor:@"type2"];
		// verify
		XCTAssertEqual(info.descriptorItems.count, 2ul);
		XCTAssertEqualObjects((info.descriptorItems)[0], @"type1");
		XCTAssertEqualObjects((info.descriptorItems)[1], @"type2");
	}];
}

#pragma mark - Creator method

- (void)runWithPropertyDescriptorsInfo:(void(^)(DescriptorsInfo *info))handler {
	DescriptorsInfo *info = [[DescriptorsInfo alloc] init];
	handler(info);
}

@end
