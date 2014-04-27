//
//  ObjectiveCConstantStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCConstantState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.h"

#define SHOULD_EVALUATE(string, result) \
	[self runWithState:^(ObjectiveCConstantState *state) { \
		[ObjectiveCStateTestsHelpers runWithString:string block:^(id parser, id tokens) { \
			id store = mock([Store class]); \
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store]; \
			XCTAssertEqual([state doesDataContainConstant:data], result); \
		}]; \
	}];

@interface ObjectiveCConstantStateTests : XCTestCase
@end

@implementation ObjectiveCConstantStateTests

#pragma mark - Parsing

- (void)testParsing_SimpleCases_ShouldDetectSingleType {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type item;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"item"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_SimpleCases_ShouldDetectMultipleTypes {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type1 type2 type3 item;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type1"];
			[verify(store) appendType:@"type2"];
			[verify(store) appendType:@"type3"];
			[verify(store) appendConstantName:@"item"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfDescriptorsStartWithDoubleUnderscorePrefixedWord_ShouldDetectSingleDescriptor {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type name __a;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"name"];
			[verify(store) beginConstantDescriptors];
			[verify(store) appendDescriptor:@"__a"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfDescriptorsStartWithDoubleUnderscorePrefixedWord_ShouldDetectAllDescriptors {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type name __a b c;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"name"];
			[verify(store) beginConstantDescriptors];
			[verify(store) appendDescriptor:@"__a"];
			[verify(store) appendDescriptor:@"b"];
			[verify(store) appendDescriptor:@"c"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfDescriptorsStartWithUppercaseWord_ShouldDetectSingleDescriptor {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type name A;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"name"];
			[verify(store) beginConstantDescriptors];
			[verify(store) appendDescriptor:@"A"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfDescriptorsStartWithUppercaseWord_ShouldDetectAllDescriptors {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type name A b c;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"name"];
			[verify(store) beginConstantDescriptors];
			[verify(store) appendDescriptor:@"A"];
			[verify(store) appendDescriptor:@"b"];
			[verify(store) appendDescriptor:@"c"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfConstantNameStartsWithDoubleUnderscore_ShouldDetectName {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type __a;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"__a"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfConstantNameStartsWithDoubleUnderscore_ShouldDetectDoubleUnderscoreDescriptors {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type __a __b;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"__a"];
			[verify(store) beginConstantDescriptors];
			[verify(store) appendDescriptor:@"__b"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfConstantNameStartsWithDoubleUnderscore_ShouldDetectUppercaseDescriptors {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type __a A;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"__a"];
			[verify(store) beginConstantDescriptors];
			[verify(store) appendDescriptor:@"A"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfConstantNameIsUppercaseWord_ShouldDetectName {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type A;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"A"];
			[verifyCount(store, times(2)) endCurrentObject]; // constant
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfConstantNameIsUppercaseWord_ShouldDetectDoubleUnderscoreDescriptors {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type A __a;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"A"];
			[verify(store) beginConstantDescriptors];
			[verify(store) appendDescriptor:@"__a"];
			[verifyCount(store, times(3)) endCurrentObject]; // constant
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_Descriptors_IfConstantNameIsUppercaseWord_ShouldDetectUppercaseDescriptors {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type A B;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendConstantName:@"A"];
			[verify(store) beginConstantDescriptors];
			[verify(store) appendDescriptor:@"B"];
			[verifyCount(store, times(3)) endCurrentObject]; // constant
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_EdgeCasesLimitationsForSupportingDescriptors_RequiresAtLeastOneNonDescriptorLookingTokenBeforeStartingAcceptingDestriptors_ShouldDetectTypesWithDoubleUnderscorePrefix {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"__type1 __type2 __name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"__type1"];
			[verify(store) appendType:@"__type2"];
			[verify(store) appendConstantName:@"__name"];
			[verifyCount(store, times(2)) endCurrentObject]; // constant
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_EdgeCasesLimitationsForSupportingDescriptors_RequiresAtLeastOneNonDescriptorLookingTokenBeforeStartingAcceptingDestriptors_ShouldDetectTypesWithUppercaseLetters {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"TYPE1 TYPE2 NAME;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"TYPE1"];
			[verify(store) appendType:@"TYPE2"];
			[verify(store) appendConstantName:@"NAME"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}


- (void)testParsing_EdgeCasesLimitationsForSupportingDescriptors_RequiresAtLeastOneNonDescriptorLookingTokenBeforeStartingAcceptingDestriptors_ShouldDetecttypesWithDoubleAndNameWithUppercaseLetters {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"__type1 __type2 NAME;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"__type1"];
			[verify(store) appendType:@"__type2"];
			[verify(store) appendConstantName:@"NAME"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_EdgeCasesLimitationsForSupportingDescriptors_RequiresAtLeastOneNonDescriptorLookingTokenBeforeStartingAcceptingDestriptors_ShouldDetectTypesWithUppercaseLettersAndNameWithDoubleUnderscorePrefix {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"TYPE1 TYPE2 __name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"TYPE1"];
			[verify(store) appendType:@"TYPE2"];
			[verify(store) appendConstantName:@"__name"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_EdgeCasesLimitationsForSupportingDescriptors_IfTypesIncludeDoubleUnderscorePrefixedWord_ShouldDetectTypesStartingWithDoubleUnderscorePrefixedWordEndEndingWithAsterisk {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"__type1 type2 *name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"__type1"];
			[verify(store) appendType:@"type2"];
			[verify(store) appendType:@"*"];
			[verify(store) appendConstantName:@"name"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_EdgeCasesLimitationsForSupportingDescriptors_IfTypesIncludeDoubleUnderscorePrefixedWord_ShouldDetectTypesStartingWithUppercaseWordAndEndingWithAsterisk {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"TYPE1 type2 *name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"TYPE1"];
			[verify(store) appendType:@"type2"];
			[verify(store) appendType:@"*"];
			[verify(store) appendConstantName:@"name"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_EdgeCases_ShouldTakeSingleTokenForName {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendConstantName:@"name"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testParsing_FailCases_ShouldCancelIfSemicolonIsMissing {
	[self runWithState:^(ObjectiveCConstantState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type item" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginConstant];
			[verify(store) beginConstantTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendType:@"item"];
			[verifyCount(store, times(2)) cancelCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Detecting

- (void)testDetecting_Allows_ShouldDetectSingleToken {
	SHOULD_EVALUATE(@"item;", YES);
}

- (void)testDetecting_Allows_ShouldDetectTwoToken {
	SHOULD_EVALUATE(@"type name;", YES);
}

- (void)testDetecting_Allows_ShouldDetectMultipleToken {
	SHOULD_EVALUATE(@"type1 type2 type3 name;", YES);
}

- (void)testDetecting_Denies_ShouldPreventIfClosingSemicolonIsMissing {
	SHOULD_EVALUATE(@"item name", NO);
}

- (void)testDetecting_Denies_ShouldPreventIfOpenParenthesisIsFound {
	SHOULD_EVALUATE(@"item (;", NO);
}

- (void)testDetecting_Denies_ShouldPreventIfCloseParenthesisIsFound {
	SHOULD_EVALUATE(@"item );", NO);
}

- (void)testDetecting_Denies_ShouldPreventIfOpenSquareIsFound {
	SHOULD_EVALUATE(@"item [;", NO);
}

- (void)testDetecting_Denies_ShouldPreventIfCloseSquareIsFound {
	SHOULD_EVALUATE(@"item ];", NO);
}

- (void)testDetecting_Denies_ShouldPreventIfOpenBraceIsFound {
	SHOULD_EVALUATE(@"item {;", NO);
}

- (void)testDetecting_Denies_ShouldPreventIfCloseBraceIsFound {
	SHOULD_EVALUATE(@"item };", NO);
}

- (void)testDetecting_Denies_ShouldPreventIfSignIsFound { // ^
	SHOULD_EVALUATE(@"item ^;", NO);
}

- (void)testDetecting_Denies_ShouldPreventIfHashIsFound {
	SHOULD_EVALUATE(@"item #;", NO);
}

- (void)testDetecting_Descriptors_ShouldAllowAnyTokenAfterDoubleUnderscoreDescriptor {
	SHOULD_EVALUATE(@"item name __a ()[]{}^#;", YES);
}

- (void)testDetecting_Descriptors_ShouldAllowAnyTokenAfterUppercaseDescriptor {
	SHOULD_EVALUATE(@"item name A ()[]{}^#;", YES);
}

#pragma mark - Creator method

- (void)runWithState:(void(^)(ObjectiveCConstantState *state))handler {
	ObjectiveCConstantState* state = [[ObjectiveCConstantState alloc] init];
	handler(state);
}

@end