//
//  CategoryInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/25/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//


#import "Store.h"
#import "TestCaseBase.h"

@interface CategoryInfoTests : XCTestCase
@end

@implementation CategoryInfoTests

#pragma mark - Lazy properties

- (void)testLazyProperties_ShouldInitializeObjectsOnFirstAccess {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// execute & verify
		XCTAssertTrue([info.categoryClass isMemberOfClass:([ObjectLinkInfo class])]);
	}];
}

#pragma mark - Convenience properties

- (void)testConvenienceProperties_ShouldReturnNameOfSuperClass {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// setup
		info.categoryClass.nameOfObject = @"SomeClass";
		// execute & verify
		XCTAssertEqualObjects(info.nameOfClass, @"SomeClass");
	}];
}

#pragma mark - Category or extension helper

- (void)testCategoryOrExtensionHelper_ShouldWorkIfNameOfCategoryIsNil {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// setup
		info.nameOfCategory = nil;
		// execute & verify
		XCTAssertEqual(info.isExtension, YES);
		XCTAssertEqual(info.isCategory, NO);
	}];
}

- (void)testCategoryOrExtensionHelper_ShouldWorkIfNameOfCategoryIsEmptyString {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// setup
		info.nameOfCategory = @"";
		// execute & verify
		XCTAssertEqual(info.isExtension, YES);
		XCTAssertEqual(info.isCategory, NO);
	}];
}

- (void)testCategoryOrExtensionHelper_ShouldWorkIfNameOfCategoryIsNotNilAndNotEmptyString {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// setup
		info.nameOfCategory = @"a";
		// execute & verify
		XCTAssertEqual(info.isExtension, NO);
		XCTAssertEqual(info.isCategory, YES);
	}];
}

#pragma mark - Descriptions

- (void)testDescriptions_ShouldHandleExtensions {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// setup
		info.categoryClass.nameOfObject = @"MyClass";
		// execute & verify
		XCTAssertEqualObjects(info.uniqueObjectID, @"MyClass()");
		XCTAssertEqualObjects(info.objectCrossRefPathTemplate, @"$CATEGORIES/MyClass.$EXT");
	}];
}

- (void)testDescriptions_ShouldHandleCategory {
	[self runWithCategoryInfo:^(CategoryInfo *info) {
		// setup
		info.categoryClass.nameOfObject = @"MyClass";
		info.nameOfCategory = @"MyCategory";
		// execute & verify
		XCTAssertEqualObjects(info.uniqueObjectID, @"MyClass(MyCategory)");
		XCTAssertEqualObjects(info.objectCrossRefPathTemplate, @"$CATEGORIES/MyClass(MyCategory).$EXT");
	}];
}

#pragma mark - Creator method

- (void)runWithCategoryInfo:(void(^)(CategoryInfo *info))handler {
	CategoryInfo *info = [[CategoryInfo alloc] initWithRegistrar:nil];
	handler(info);
}

@end