//
//  ObjectiveCEnumStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCEnumState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.h"

@interface ObjectiveCEnumStateTests : XCTestCase
@end

@implementation ObjectiveCEnumStateTests

#pragma mark - Simple cases

- (void)testSimpleCases_ShouldDetect {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum {};" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}
	
- (void)testSimpleCases_ShouldDetectName {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum name {};" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationName:@"name"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testSimpleCases_ShouldUseLastTokenBeforeEnumBodyAsName {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum word1 word2 word3 {};" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationName:@"word3"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Single item enums

- (void)testSingleItemEnums_ShouldDetectItem {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum { item };" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationItem:@"item"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testSingleItemEnums_ShouldDetectItemEvenIfDelimitedByComma {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum { item, };" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationItem:@"item"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}
	
- (void)testSingleItemEnums_ShouldDetectItemWithValue {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum { item = value };" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationItem:@"item"];
			[verify(store) appendEnumerationValue:@"value"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testSingleItemEnums_ShouldDetectItemWithValueEvenIfDelimitedByComma {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum { item = value, };" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationItem:@"item"];
			[verify(store) appendEnumerationValue:@"value"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Enums with multiple items

- (void)testEnumsWithMultipleItems_ShuoldDetectAllItems {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum { item1, item2, item3 };" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationItem:@"item1"];
			[verify(store) appendEnumerationItem:@"item2"];
			[verify(store) appendEnumerationItem:@"item3"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testEnumsWithMultipleItems_ShouldDetectItemsWithValues {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum { item1 = value1, item2 = value2, item3 = value3 };" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationItem:@"item1"];
			[verify(store) appendEnumerationValue:@"value1"];
			[verify(store) appendEnumerationItem:@"item2"];
			[verify(store) appendEnumerationValue:@"value2"];
			[verify(store) appendEnumerationItem:@"item3"];
			[verify(store) appendEnumerationValue:@"value3"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testEnumsWithMultipleItems_ShouldDetectItemsWithMixedValues {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum { item1 = value1, item2, item3 = value3, };" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationItem:@"item1"];
			[verify(store) appendEnumerationValue:@"value1"];
			[verify(store) appendEnumerationItem:@"item2"];
			[verify(store) appendEnumerationItem:@"item3"];
			[verify(store) appendEnumerationValue:@"value3"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Few more complex cases

- (void)testFewMoreComplexCases_ShouldDetectEnumWithComplexValues {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum { item1 = (1 << 0), item2 = (item2 + 30 * (1 << 4)) };" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationItem:@"item1"];
			[verify(store) appendEnumerationValue:@"(1 << 0)"];
			[verify(store) appendEnumerationItem:@"item2"];
			[verify(store) appendEnumerationValue:@"(item2 + 30 * (1 << 4))"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Enums with names

- (void)testEnumsWithNames_IfNameIsPartOfEnum_ShouldDetectSingleItem {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum name {};" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationName:@"name"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testEnumsWithNames_ShouldDetectSuccesiveEnums {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum name1 {}; enum name2 {};" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			[state parseWithData:data];
			// verify
			[verifyCount(store, times(2)) setCurrentSourceInfo:anything()];
			[verifyCount(store, times(2)) beginEnumeration];
			[verify(store) appendEnumerationName:@"name1"];
			[verify(store) appendEnumerationName:@"name2"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testEnumsWithNames_IfNameIsPartOfFollowingTypedef_ShouldDetectIfTypedefIsComposedOfSingleTypeAndName {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum {}; typedef type name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationName:@"name"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testEnumsWithNames_IfNameIsPartOfFollowingTypedef_ShouldIgnoreIfTypedefUsesMultipleTokens {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum {}; typedef word1 word2 word3;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Fail cases

- (void)testFailCases_ShouldCancelIfStartOfEnumBodyIsMissing {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum word1 word2 word3 };" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) cancelCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testFailCases_ShouldCancelIfEndOfEnumBodyIsMissing {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum { item ;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) appendEnumerationItem:@"item"];
			[verify(store) cancelCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testFailCases_ShouldCancelIfEndingSemicolonIsMissing {
	[self runWithState:^(ObjectiveCEnumState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum {}" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginEnumeration];
			[verify(store) cancelCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Creator method

- (void)runWithState:(void(^)(ObjectiveCEnumState *state))handler {
	ObjectiveCEnumState* state = [[ObjectiveCEnumState alloc] init];
	handler(state);

}

@end
