//
//  ObjectiveCPragmaMarkStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCPragmaMarkState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.h"

@interface ObjectiveCPragmaMarkStateTests : XCTestCase
@end

@implementation ObjectiveCPragmaMarkStateTests



#pragma mark - Simple cases

- (void)testSimpleCases_ShouldDetectSingleWord {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"#pragma mark word" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) appendMethodGroupWithDescription:@"word"];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testSimpleCases_ShouldDetectMultipleWords {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"#pragma mark word1 word2 word3" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) appendMethodGroupWithDescription:@"word1 word2 word3"];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Using minus

- (void)testUsingMinus_ShouldIgnoreMinusPrefix {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"#pragma mark - word1 word2 word3" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) appendMethodGroupWithDescription:@"word1 word2 word3"];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testUsingMinus_ShouldIgnoreMinusPrefixAndTakeMinusSuffixAsPartOfDescription {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"#pragma mark - word1 word2 word3 -" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) appendMethodGroupWithDescription:@"word1 word2 word3 -"];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Various edge cases

- (void)testVariousEdgeCases_ShouldIgnoreIfDescriptionOnlyContainsWhitespace {
	[self runWithState:^(ObjectiveCPragmaMarkState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"#pragma mark - \t  \t \n" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Creator method

- (void)runWithState:(void(^)(ObjectiveCPragmaMarkState *state))handler {
	ObjectiveCPragmaMarkState* state = [[ObjectiveCPragmaMarkState alloc] init];
	handler(state);
}

@end
