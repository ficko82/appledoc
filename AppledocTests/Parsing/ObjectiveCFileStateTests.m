//
//  ObjectiveCFileStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/27/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCFileState.h"
#import "ObjectiveCConstantState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.h"

@interface ObjectiveCFileStateTests : XCTestCase
@end

@implementation ObjectiveCFileStateTests

#pragma mark - Classes parsing

- (void)testClassesParsing_ShouldRegisterRootClassToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@interface MyClass" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginClassWithName:@"MyClass" derivedFromClassWithName:nil];
			XCTAssertEqual([parser currentState], [parser interfaceState]);
		}];
	}];
}

- (void)testClassesParsing_ShouldRegisterSubclassToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@interface MyClass : SuperClass" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginClassWithName:@"MyClass" derivedFromClassWithName:@"SuperClass"];
			XCTAssertEqual([parser currentState], [parser interfaceState]);
		}];
	}];
}


#pragma mark - Categories parsing

- (void)testCategoriesParsing_ShouldRegisterClassExtensionToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@interface MyClass ()" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginExtensionForClassWithName:@"MyClass"];
			XCTAssertEqual([parser currentState], [parser interfaceState]);
		}];
	}];
}

- (void)testCategoriesParsing_ShouldRegisterClassCategoryToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@interface MyClass (CategoryName)" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginCategoryWithName:@"CategoryName" forClassWithName:@"MyClass"];
			XCTAssertEqual([parser currentState], [parser interfaceState]);
		}];
	}];
}

#pragma mark - Protocols parsing

- (void)testProtocolsParsing_ShouldRegisterProtocolToStore {
	[self runWithState:^(ObjectiveCFileState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@protocol MyProtocol" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginProtocolWithName:@"MyProtocol"];
			XCTAssertEqual([parser currentState], [parser interfaceState]);
		}];
	}];
}

#pragma mark - Enums parsing

- (void)testEnumsParsing_ShouldDetectPossibleEnum {
	[self runWithState:^(ObjectiveCFileState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"enum" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertEqual([parser currentState], [parser enumState]);
		}];
	}];
}

#pragma mark - Structs parsing

- (void)testStructsParsing_ShouldDetectPossibleStruct {
	[self runWithState:^(ObjectiveCFileState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"struct" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertEqual([parser currentState], [parser structState]);
		}];
	}];
}

#pragma mark - Constants parsing

- (void)testConstantsParsing_ShouldAskConstantStateForPossibleConstantDefinition {
	[self runWithState:^(ObjectiveCFileState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"some unknown tokens" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			id constantState = mock([ObjectiveCConstantState class]);
			[parser setConstantState:constantState];
			// execute
			[state parseWithData:data];
			// verify
			[verify(constantState) doesDataContainConstant:data];
		}];
	}];
}

#pragma mark - Creator method

- (void)runWithState:(void(^)(ObjectiveCFileState *state))handler {
	ObjectiveCFileState* state = [[ObjectiveCFileState alloc] init];
	handler(state);
}

@end