//
//  ParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "Extensions.h"
#import "ObjectiveCParser.h"
#import "Parser.h"
#import "TestCaseBase.h"

@interface ParserTests : XCTestCase
@end

@implementation ParserTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithParser:^(Parser *parser) {
		// execute & verify
		XCTAssertTrue([parser.objectiveCParser isMemberOfClass:([ObjectiveCParser class])]);
	}];
}

#pragma mark - Running

- (void)testRunning_ShouldEnumerateArgumentsOnTheGivenSettings {
	[self runWithParser:^(Parser *parser) {
		// setup
		id arguments = mock([NSArray class]);
		id settings = mock([GBSettings class]);
		[given([settings arguments]) willReturn:arguments];
		// execute
		[parser runWithSettings:settings store:nil];
		// verify
		XCTAssertNoThrow([verify(settings) arguments]);
	    XCTAssertNoThrow([verify(arguments) enumerateObjectsUsingBlock:anything()]);
	}];
}

- (void)testRunning_ShouldInvokeObjectiveCParserOnSourceFiles {
	[self runWithParser:^(Parser *parser) {
		// setup
		id settings = mock([GBSettings class]);
		[given([settings arguments]) willReturn:@[@"file.m"]];
		id objcParser = mock([ObjectiveCParser class]);
		id manager = mock([NSFileManager class]);
		[given([manager fileExistsAtPath:anything()]) willReturnBool:YES];
		[given([manager gb_fileExistsAndIsDirectoryAtPath:anything()]) willReturnBool:NO];
		parser.fileManager = manager;
		parser.objectiveCParser = objcParser;
		// execute
		[parser runWithSettings:settings store:nil];
		// verify
		XCTAssertNoThrow([verify(objcParser) parseFile:@"file.m" withSettings:settings store:anything()]);
	}];
}

#pragma mark - Creator method

- (void)runWithParser:(void(^)(Parser *parser))handler {
	Parser *parser = [[Parser alloc] init];
	handler(parser);
}

@end