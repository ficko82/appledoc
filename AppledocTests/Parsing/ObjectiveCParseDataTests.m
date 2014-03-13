//
//  ParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 5/04/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCParseData.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.h"

@interface ObjectiveCParseDataTests : XCTestCase
@end

@implementation ObjectiveCParseDataTests

#pragma mark - Descriptors handling

- (void)testDescriptorsHandling_ShouldMatchDoubleUnderscoreTokens {
	[self runWithData:^(ObjectiveCParseData *data) {
		// execute & verify
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"__a"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"__a_"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"__a__"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"__a_and_b"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"__a_and_b_"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"__a_and_b__"], YES);
	}];
}

- (void)testDescriptorsHandling_ShouldMatchUppercaseWords {
	[self runWithData:^(ObjectiveCParseData *data) {
		// execute & verify
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"A"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"A_AND_B"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"__A_AND_B"], YES);
	}];
}

- (void)testDescriptorsHandling_ShouldMatchUppercaseWordsDigitsAndUnderscores {
	[self runWithData:^(ObjectiveCParseData *data) {
		// execute & verify
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"A1234567890"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"A_1"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"A_B_"], YES);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"A__"], YES);
	}];
}

- (void)testDescriptorsHandling_ShouldRejectWordsStartingWithDigit {
	[self runWithData:^(ObjectiveCParseData *data) {
		// execute & verify
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"1234567890"], NO);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"1_A"], NO);
	}];
}

- (void)testDescriptorsHandling_ShouldRejectOtherWords {
	[self runWithData:^(ObjectiveCParseData *data) {
		// execute & verify
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"a"], NO);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"ab"], NO);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"aB"], NO);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"Ab"], NO);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"_a__"], NO);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"_aB__"], NO);
	    XCTAssertEqual([data doesStringLookLikeDescriptor:@"_A_AND_b__"], NO);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"1234567890"], NO);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"1_A"], NO);
		XCTAssertEqual([data doesStringLookLikeDescriptor:@"*"], NO);
	}];
}

#pragma mark - Creator method

- (void)runWithData:(void(^)(ObjectiveCParseData *data))handler {
	[ObjectiveCStateTestsHelpers runWithString:@"" block:^(id parser, id tokens) {
		id store = mock([Store class]);
		ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
		handler(data);
	}];
}

@end