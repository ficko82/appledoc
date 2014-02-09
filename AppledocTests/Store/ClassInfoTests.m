//
//  ClassInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 10/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface ClassInfoTests : XCTestCase
@end

@implementation ClassInfoTests

#pragma mark - Lazy properties

- (void)testLazyProperties_ShouldInitializeObjectsOnFirstAccess {
	[self runWithClassInfo:^(ClassInfo *info) {
		// execute & verify
		XCTAssertTrue([info.classSuperClass isMemberOfClass:([ObjectLinkInfo class])]);
	}];
}

#pragma mark - Convenience properties

- (void)testConvenienceProperties_ShouldReturnNameOfSuperClass {
	[self runWithClassInfo:^(ClassInfo *info) {
		// setup
		info.classSuperClass.nameOfObject = @"SomeClass";
		// execute & verify
		XCTAssertEqualObjects(info.nameOfSuperClass, @"SomeClass");
	}];
}

#pragma mark - Creator method

- (void)runWithClassInfo:(void(^)(ClassInfo *info))handler {
	ClassInfo *info = [[ClassInfo alloc] initWithRegistrar:nil];
	handler(info);
}

@end