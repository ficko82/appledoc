//
//  ObjectiveCMethodStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCMethodState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.h"

@interface ObjectiveCMethodStateTests : XCTestCase
@end

@implementation ObjectiveCMethodStateTests

#pragma mark - No arguments methods

- (void)testNoArgumentMethods_ShouldDetect_ShouldDetectDefinitionWithNoReturnType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verifyCount(store, times(2)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}
	
- (void)testNoArgumentMethods_ShouldDetectDefinitionWithSignleReturnType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- (type)method;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodResults];
			[verify(store) appendType:@"type"];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}
	
- (void)testNoArgumentMethods_ShouldDetectDefinitionWithMultipleReturnTypes {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- (type1 type2 type3)method;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodResults];
			[verify(store) appendType:@"type1"];
			[verify(store) appendType:@"type2"];
			[verify(store) appendType:@"type3"];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Single argument methods

- (void)testSingleArgumentMethods_ShouldDetectDefinitionWithNoType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:var;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) appendMethodArgumentVariable:@"var"];
			[verifyCount(store, times(2)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}
	
- (void)testSingleArgumentMethods_ShouldDetectDefinitionWithSignleType {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:(type1)var;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) beginMethodArgumentTypes];
			[verify(store) appendType:@"type1"];
			[verify(store) appendMethodArgumentVariable:@"var"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}
	
- (void)testSingleArgumentMethods_ShouldDetectDefinitionWithMultipleTypes {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:(type1 type2 type3)var;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) beginMethodArgumentTypes];
			[verify(store) appendType:@"type1"];
			[verify(store) appendType:@"type2"];
			[verify(store) appendType:@"type3"];
			[verify(store) appendMethodArgumentVariable:@"var"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Multiple arguments methods

- (void)testMultipleArgumentsMethods_ShouldDetectDefinitionWithNoTypes {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:var1 that:var2 rocks:var3;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store)  setCurrentSourceInfo:anything()];
			[verify(store)  beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store)  appendMethodArgumentSelector:@"method"];
			[verify(store)  appendMethodArgumentVariable:@"var1"];
			[verify(store)  appendMethodArgumentSelector:@"that"];
			[verify(store)  appendMethodArgumentVariable:@"var2"];
			[verifyCount(store, times(3)) beginMethodArgument];
			[verify(store)  appendMethodArgumentSelector:@"rocks"];
			[verify(store)  appendMethodArgumentVariable:@"var3"];
			[verifyCount(store, times(4)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}
	
- (void)testMultipleArgumentsMethods_ShouldDetectDefinitionsWithSingleAndMultipleTypes {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:(type1)var1 that:(type2 type3)var2 rocks:(type4 type5 type6)var3;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store)  beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store)  appendMethodArgumentSelector:@"method"];
			[verify(store)  appendType:@"type1"];
			[verify(store)  appendMethodArgumentVariable:@"var1"];
			[verifyCount(store, times(3))  beginMethodArgument];
			[verify(store)  appendMethodArgumentSelector:@"that"];
			[verify(store)  appendType:@"type2"];
			[verify(store)  appendType:@"type3"];
			[verify(store)  appendMethodArgumentVariable:@"var2"];
			[verify(store)  appendMethodArgumentSelector:@"rocks"];
			[verifyCount(store, times(3))  beginMethodArgumentTypes];
			[verify(store)  appendType:@"type4"];
			[verify(store)  appendType:@"type5"];
			[verify(store)  appendType:@"type6"];
			[verify(store)  appendMethodArgumentVariable:@"var3"];
			[verifyCount(store, times(7))  endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Methods with descriptors

//describe(@"methods with descriptors:", ^{

- (void)testMethodsWithDescriptors_IfMethodsHaveNoArguments_ShouldTakeDoubleUnderscorePrefixedWordAfterSelectorAsDescriptor {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method __a;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__a"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveNoArguments_ShouldTakeAllWordsAfterDoubleUnderscorePrefixedWordAfterSelectorAsDescriptors {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method __a1 a2 a3;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__a1"];
			[verify(store) appendDescriptor:@"a2"];
			[verify(store) appendDescriptor:@"a3"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveNoArguments_ShouldAllowDoubleUnderscorePrefixedWordAsArgumentSelector {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- __a __b;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"__a"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__b"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}


- (void)testMethodsWithDescriptors_IfMethodsHaveNoArguments_ShouldTakeUppercaseWordAfterSelectorAsDescriptor {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method A;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"A"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveNoArguments_ShouldTakeAllWordsAfterUppercaseWordAfterSelectorAsDescriptors {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method A1 a2 a3;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"A1"];
			[verify(store) appendDescriptor:@"a2"];
			[verify(store) appendDescriptor:@"a3"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveNoArguments_ShouldAllowUppercaseWordAsArgumentSelector {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- A B;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"A"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"B"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveSingleArgument_ShouldTakeDoubleUnderscoredWordAfterVariableNameAsDescriptor {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:var __a;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) appendMethodArgumentVariable:@"var"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__a"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveSingleArgument_ShouldTakeAllWordsAfterDoubleUnderscorePrefixedWordAfterVariableNameAsDescriptors {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:var __a b;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) appendMethodArgumentVariable:@"var"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__a"];
			[verify(store) appendDescriptor:@"b"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveSingleArgument_ShouldAllowDoubleUnderscoredVariableName {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:__a __b;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) appendMethodArgumentVariable:@"__a"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__b"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveSingleArgument_ShouldTakeUppercaseWordAfterVariableNameAsDescriptor {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:var A;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) appendMethodArgumentVariable:@"var"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"A"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}


- (void)testMethodsWithDescriptors_IfMethodsHaveSingleArgument_ShouldTakeAllWordsAfterUppercaseWordAfterVariableNameAsDescriptors {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:var A b;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) appendMethodArgumentVariable:@"var"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"A"];
			[verify(store) appendDescriptor:@"b"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveSingleArgument_ShouldTakeFirstUppercaseWordAfterVariableNameAsDescriptor {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:A B;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) appendMethodArgumentVariable:@"A"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"B"];
			[verifyCount(store, times(3)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveMultipleArguments_ShouldTakeDoubleUnderscorePrefixedWordAfterLastSelectorAsDescriptor {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- sel1:var1 sel2:var2 __a;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) appendMethodArgumentSelector:@"sel1"];
			[verify(store) appendMethodArgumentVariable:@"var1"];
			[verifyCount(store, times(2)) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"sel2"];
			[verify(store) appendMethodArgumentVariable:@"var2"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__a"];
			[verifyCount(store, times(4)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveMultipleArguments_ShouldTakeAllWordsAfterDoubleUnderscorePrefixedWordAfterLastSelectorAsDescriptors {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- sel1:var1 sel2:var2 __a b;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) appendMethodArgumentSelector:@"sel1"];
			[verify(store) appendMethodArgumentVariable:@"var1"];
			[verifyCount(store, times(2)) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"sel2"];
			[verify(store) appendMethodArgumentVariable:@"var2"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__a"];
			[verify(store) appendDescriptor:@"b"];
			[verifyCount(store, times(4)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveMultipleArguments_ShouldAllowDoubleUnderscorePrefixedWordAsArgumentVariableName {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- sel1:var1 sel2:__a __b;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) appendMethodArgumentSelector:@"sel1"];
			[verify(store) appendMethodArgumentVariable:@"var1"];
			[verifyCount(store, times(2)) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"sel2"];
			[verify(store) appendMethodArgumentVariable:@"__a"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__b"];
			[verifyCount(store, times(4)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveMultipleArguments_ShouldTakeUppercaseWordAfterLastSelectorAsDescriptor {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- sel1:var1 sel2:var2 A;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) appendMethodArgumentSelector:@"sel1"];
			[verify(store) appendMethodArgumentVariable:@"var1"];
			[verifyCount(store, times(2)) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"sel2"];
			[verify(store) appendMethodArgumentVariable:@"var2"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"A"];
			[verifyCount(store, times(4)) endCurrentObject]; // method descriptors
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveMultipleArguments_ShouldTakeAllWordsAfterUppercaseWordAfterLastSelectorAsDescriptors {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- sel1:var1 sel2:var2 A b;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) appendMethodArgumentSelector:@"sel1"];
			[verify(store) appendMethodArgumentVariable:@"var1"];
			[verifyCount(store, times(2)) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"sel2"];
			[verify(store) appendMethodArgumentVariable:@"var2"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"A"];
			[verify(store) appendDescriptor:@"b"];
			[verifyCount(store, times(4)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testMethodsWithDescriptors_IfMethodsHaveMultipleArguments_ShouldAllowUppercaseWordAsArgumentVariableName {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- sel1:var1 sel2:A B;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) appendMethodArgumentSelector:@"sel1"];
			[verify(store) appendMethodArgumentVariable:@"var1"];
			[verifyCount(store, times(2)) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"sel2"];
			[verify(store) appendMethodArgumentVariable:@"A"];
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"B"];
			[verifyCount(store, times(4)) endCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Multiple successive methods

- (void)testMultipleSuccessiveMethods_ShuoldDetectAllDefinitions {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithFile:@"MethodStateMultipleDefinitions.h" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			[state parseWithData:data];
			[state parseWithData:data];
			// verify
			[verify(store) appendMethodArgumentSelector:@"method1"];
			[verify(store) appendMethodArgumentSelector:@"method2"];
			[verify(store) appendMethodArgumentVariable:@"arg"];
			
			[verifyCount(store, times(3)) setCurrentSourceInfo:anything()];
			[verifyCount(store, times(3)) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verifyCount(store, times(3)) beginMethodResults];
			[verifyCount(store, times(3)) appendType:@"void"];
			[verify(store) appendMethodArgumentSelector:@"method3"];
			[verifyCount(store, times(2)) appendType:@"int"];
			[verify(store) appendMethodArgumentVariable:@"arg1"];
			[verifyCount(store, times(4)) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"second"];
			[verifyCount(store, times(3)) beginMethodArgumentTypes];
			[verify(store) appendType:@"NSString"];
			[verifyCount(store, times(2)) appendType:@"*"];
			[verify(store) appendMethodArgumentVariable:@"arg2"];
			[verifyCount(store, times(13)) endCurrentObject]; // method definition
		}];
	}];
}

- (void)testMultipleSuccessiveMethods_ShouldDetectDeclarationsIgnoringMethodBodies {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithFile:@"MethodStateMultipleDeclarations.m" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			[state parseWithData:data];
			[state parseWithData:data];
			// verify
			[verify(store) appendMethodArgumentSelector:@"method1"];
			[verify(store) appendMethodArgumentSelector:@"method2"];
			[verify(store) appendMethodArgumentVariable:@"arg"];
			[verifyCount(store, times(3)) setCurrentSourceInfo:anything()];
			[verifyCount(store, times(3)) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verifyCount(store, times(3)) beginMethodResults];
			[verifyCount(store, times(3)) appendType:@"void"];
			[verify(store) appendMethodArgumentSelector:@"method3"];
			[verifyCount(store, times(2)) appendType:@"int"];
			[verify(store) appendMethodArgumentVariable:@"arg1"];
			[verifyCount(store, times(4)) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"second"];
			[verifyCount(store, times(3)) beginMethodArgumentTypes];
			[verify(store) appendType:@"NSString"];
			[verifyCount(store, times(2)) appendType:@"*"];
			[verify(store) appendMethodArgumentVariable:@"arg2"];
			[verifyCount(store,times(13)) endCurrentObject]; // method definition
		}];
	}];
}

#pragma mark - Various fail cases

- (void)testVariousFailCases_ShouldCancelIfClosingResultsParenthesisIsNotFound {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- (type method;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodResults];
			[verify(store) appendType:@"type"];
			[verify(store) appendType:@"method"];
			[verifyCount(store, times(2)) cancelCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testVariousFailCases_ShouldCancelIfClosingArgumentVariableTypeParenthesisIsNotFound {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:(type;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) beginMethodArgumentTypes];
			[verify(store) appendType:@"type"];
			[verifyCount(store, times(3)) cancelCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testVariousFailCases_ShouldCancelIfMethodRequiresArgumentButDoesnNotProvideVariableName {
	// this is otherwise valid Objective C syntax, but appledoc doesn't accept it at this point...
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verifyCount(store, times(2)) cancelCurrentObject]; // method definition
			XCTAssertNil([parser currentState]);
		}];
	}];
}
	
- (void)testVariousFailCases_ShouldCancelIfMethodStartsDescriptorsButDoesnNotEnd {
	// this is otherwise valid Objective C syntax, but appledoc doesn't accept it at this point...
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"- method:var __a" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verify(store) appendMethodArgumentVariable:@"var"];
			[verify(store) endCurrentObject]; // method argument
			[verify(store) beginMethodDescriptors];
			[verify(store) appendDescriptor:@"__a"];
			[verifyCount(store, times(2)) cancelCurrentObject]; // method descriptors
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark Just few quick cases for verifying class methods and declaration parsing support
#pragma mark As we use exactly the same code for all these, we just verify simple cases here

#pragma mark - Class methods

- (void)testClassMethods_ShouldDetectDefinition {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"+ (type)method;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.classMethod];
			[verify(store) beginMethodResults];
			[verify(store) appendType:@"type"];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verifyCount(store, times(3)) endCurrentObject]; // method argument
			XCTAssertNil([parser currentState]);
		}];
	}];
}
	
- (void)testClassMethods_ShouldDetectDeclaration {
	[self runWithState:^(ObjectiveCMethodState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"+ (type)method {" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginMethodDefinitionWithType:GBStoreTypes.classMethod];
			[verify(store) beginMethodResults];
			[verify(store) appendType:@"type"];
			[verify(store) beginMethodArgument];
			[verify(store) appendMethodArgumentSelector:@"method"];
			[verifyCount(store, times(3)) endCurrentObject]; // method argument
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Creator method

- (void)runWithState:(void(^)(ObjectiveCMethodState *state))handler {
	ObjectiveCMethodState* state = [[ObjectiveCMethodState alloc] init];
	handler(state);
}

@end
 
