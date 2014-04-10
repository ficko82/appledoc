//
//  ObjectiveCInterfaceStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCInterfaceState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.h"

@interface ObjectiveCInterfaceStateTests : XCTestCase
@end

@implementation ObjectiveCInterfaceStateTests

#pragma mark - Adopted protocols parsing

- (void)testAdoptedProtocolsParsing_ShouldRegisterSingleAdoptedProtocolToStore {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"<MyProtocol>" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) appendAdoptedProtocolWithName:@"MyProtocol"];
		}];
	}];
}

- (void)testAdoptedProtocolsParsing_ShouldRegisterMultipleAdoptedProtocolsToStore {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"<MyProtocol1, MyProtocol2, MyProtocol3>" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verifyCount(store, times(3)) setCurrentSourceInfo:anything()];
			[verify(store) appendAdoptedProtocolWithName:@"MyProtocol1"];
			[verify(store) appendAdoptedProtocolWithName:@"MyProtocol2"];
			[verify(store) appendAdoptedProtocolWithName:@"MyProtocol3"];
		}];
	}];
}
	
- (void)testAdoptedProtocolsParsing_SshouldIgnoreEmptyAdoptedProtocolsList {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"<>" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertNil([store currentSourceInfo]);
		}];
	}];
}

#pragma mark - @End parsing

- (void)testEndParsing_ShouldRegisterInterfaceEndToStore {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@end" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) endCurrentObject];
		}];
	}];
}

#pragma mark - Methods and properties parsing

- (void)testMethodsAndPropertiesParsing_ShouldDetectPossibleIinstanceMethod {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"-"block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertEqual([parser currentState], [parser methodState]);
		}];
	}];
}

- (void)testMethodsAndPropertiesParsing_ShouldDetectPossibleClassMethod {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"+" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertEqual([parser currentState], [parser methodState]);
		}];
	}];
}

- (void)testMethodsAndPropertiesParsing_ShouldDetectPossibleProperty {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertEqual([parser currentState], [parser propertyState]);
		}];
	}];
}

#pragma mark - Pragma mark parsing

- (void)testPragmaMarkParsing_ShouldDetectPossiblePragmaMark {
	[self runWithState:^(ObjectiveCInterfaceState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"#pragma mark" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			XCTAssertEqual([parser currentState], [parser pragmaMarkState]);
		}];
	}];
}

#pragma mark - Creator method

- (void)runWithState:(void(^)(ObjectiveCInterfaceState *state))handler {
	ObjectiveCInterfaceState* state = [[ObjectiveCInterfaceState alloc] init];
	handler(state);
}

@end
