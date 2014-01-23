//
//  AppledocTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "Parser.h"
#import "Processor.h"
#import "Appledoc.h"
#import "TestCaseBase.h"

@interface Appledoc (TestingPrivateAPI)
@property (nonatomic, strong) GBSettings *settings;
@end

@interface AppledocTests : XCTestCase
@end

@implementation AppledocTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithAppledoc:^(Appledoc *appledoc) {
		// execute & verify
		XCTAssertTrue([appledoc.store isKindOfClass:[Store class]]);
		XCTAssertTrue([appledoc.parser isKindOfClass:[Parser class]]);
		XCTAssertTrue([appledoc.processor isKindOfClass:[Processor class]]);
	}];
}

#pragma mark - Run

- (void)testRun_ShouldInvokeParser {
	[self runWithAppledoc:^(Appledoc *appledoc) {
		// setup
		id settings = mock([GBSettings class]);
		id parser = mock([Parser class]);
		id store = mock([Store class]);
		appledoc.processor = mock([Processor class]);
		appledoc.store = store;
		appledoc.parser = parser;
		// execute
		[appledoc runWithSettings:settings];
		// verify
		XCTAssertNoThrow([verify(parser) runWithSettings:settings store:store]);
	}];

}

- (void)testRun_ShouldInvokeProcessor {
	[self runWithAppledoc:^(Appledoc *appledoc) {
		// setup
		id settings = mock([GBSettings class]);
		id store = mock([Store class]);
		id processor = mock([Processor class]);
		appledoc.parser = mock([Parser class]);
		appledoc.store = store;
		appledoc.processor = processor;
		// execute
		[appledoc runWithSettings:settings];
		// verify
		XCTAssertNoThrow([verify(processor) runWithSettings:settings store:store]);
	} ];
}

#pragma mark - Creator methods

- (void)runWithAppledoc:(void(^)(Appledoc *appledoc))handler {
	Appledoc *appledoc = [[Appledoc alloc] init];
	handler(appledoc);
}

@end