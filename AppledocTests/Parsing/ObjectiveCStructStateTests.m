	//
//  ObjectiveCStructStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCStructState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.h"

@interface ObjectiveCStructStateTests : XCTestCase
@end

@implementation ObjectiveCStructStateTests

#pragma mark - Struct data parsing

- (void)testStructDataParsing_StructStart_ShouldDetectStruct {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"struct {" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginStruct];
		}];
	}];
}

- (void)testStructDataParsing_StructEnd_ShouldEndStruct {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"}" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testStructDataParsing_StructName_IfNameIsBeforeTheBody_ShouldDetectName {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"struct name {" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginStruct];
			[verify(store) appendStructName:@"name"];
		}];
	}];
}

- (void)testStructDataParsing_StructName_IfNameIsBeforeTheBody_ShouldDetectNameForStructVariableDefinition {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"struct type name = {" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginStruct];
			[verify(store) appendStructName:@"type"];
		}];
	}];
}

- (void)testStructDataParsing_StructName_IfNameIsAfterTheBody_ShouldDetectName {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"} name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) appendStructName:@"name"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testStructDataParsing_StructName_IfNameIsBeforeAndAfterTheBody_ShouldUseNameBeforeBodyIsBothAreGiven {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"struct name1 {} name2;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute - need to do it twice to have state parse all components
			[state parseWithData:data];
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginStruct];
			[verify(store) appendStructName:@"name1"];
			[verify(store) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testStructDataParsing_StructName_IfNameIsBeforeAndAfterTheBody_ShouldDetectSubsequentStructName {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"struct name1 {}; struct name2 {};" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute - need to do it repeatedly to have state parse all components
			[state parseWithData:data];
			[state parseWithData:data];
			[state parseWithData:data];
			[state parseWithData:data];
			// verify
			[verifyCount(store, times(2)) setCurrentSourceInfo:anything()];
			[verifyCount(store, times(2)) beginStruct];
			[verify(store) appendStructName:@"name1"];
			[verifyCount(store, times(2)) endCurrentObject];
			[verify(store) appendStructName:@"name2"];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Struct items parsing

- (void)testStructItemsParsing_ItemsDefinitions_ShouldDetectConstantIfDelimitedBySemicolon {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type name;" block:^(id parser, id tokens) {
			// setup
			id store = mock(anything());
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertEqual([parser currentState], [parser constantState]);
		}];
	}];
}

- (void)testStructItemsParsing_ItemDeclarations_ShouldIgnoreConstantIfDelimitedByComma {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"type name," block:^(id parser, id tokens) {
			// setup
			id store = mock(anything());
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testStructItemsParsing_ItemDeclarations_ShouldIgnoreValueAssignmentIfDelimitedByComma {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@".type = name," block:^(id parser, id tokens) {
			// setup
			id store = mock(anything());
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Fail cases

- (void)testFailCases_ShouldFailIfOpeningBraceIsMissing {
	[self runWithState:^(ObjectiveCStructState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"struct name" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginStruct];
			[verify(store) cancelCurrentObject];
			XCTAssertNotNil([parser currentState]);
		}];
	}];
}

#pragma mark - Creator method

-(void)runWithState:(void(^)(ObjectiveCStructState *state))handler {
	ObjectiveCStructState* state = [[ObjectiveCStructState alloc] init];
	handler(state);
}

@end