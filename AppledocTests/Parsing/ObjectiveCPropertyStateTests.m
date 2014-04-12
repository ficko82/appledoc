//
//  ObjectiveCPropertyStateTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCPropertyState.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.h"

@interface ObjectiveCPropertyStateTests : XCTestCase
@end

@implementation ObjectiveCPropertyStateTests

#pragma mark - Properties without attributes

- (void)testPropertiesWithouthAttributtes_SimpleProperties_ShouldDetectSingleType {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property type name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendPropertyName:@"name"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithouthAttributtes_SimpleProperties_ShouldDetectMutlipleTypes {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property type1 type2 type3 name;"  block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"type1"];
			[verify(store) appendType:@"type2"];
			[verify(store) appendType:@"type3"];
			[verify(store) appendPropertyName:@"name"];
			[verifyCount(store, times(2)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Properties with attributes

- (void)testPropertiesWithAttributtes_ShouldDetectSingleAttribute {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property (attr) type name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyAttributes];
			[verify(store) appendAttribute:@"attr"];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendPropertyName:@"name"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithAttributtes_SshouldDetectMultipleAttributes {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property (attr1, attr2, attr3) type name;"block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyAttributes];
			[verify(store) appendAttribute:@"attr1"];
			[verify(store) appendAttribute:@"attr2"];
			[verify(store) appendAttribute:@"attr3"];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendPropertyName:@"name"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithAttributtes_ShouldDetectMultipleAttributesAndTypes {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property (attr1, attr2, attr3) type1 type2 type3 name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyAttributes];
			[verify(store) appendAttribute:@"attr1"];
			[verify(store) appendAttribute:@"attr2"];
			[verify(store) appendAttribute:@"attr3"];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"type1"];
			[verify(store) appendType:@"type2"];
			[verify(store) appendType:@"type3"];
			[verify(store) appendPropertyName:@"name"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithAttributtes_ShouldDetectCustomGetterAndSetter {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property (getter=isName, setter=setName:) type name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyAttributes];
			[verify(store) appendAttribute:@"getter"];
			[verify(store) appendAttribute:@"isName"];
			[verify(store) appendAttribute:@"setter"];
			[verifyCount(store, times(2)) appendAttribute:@"="];
			[verify(store) appendAttribute:@"setName"];
			[verify(store) appendAttribute:@":"];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendPropertyName:@"name"];
			[verifyCount(store, times(3)) endCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Properties with descriptors

- (void)testPropertiesWithDescriptors_IfDescriptorStartWithDoubleUnderscoreWord_ShouldDetectDescriptorAfterPropertyName {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property BOOL name __something;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"BOOL"];
			[verify(store) appendPropertyName:@"name"];
			[verify(store) beginPropertyDescriptors];
			[verify(store) appendDescriptor:@"__something"];
			[verifyCount(store, times(3)) endCurrentObject]; // property
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithDescriptors_IfDescriptorStartWithDoubleUnderscoreWord_ShouldDetectAllDescriptorTokensAfterPropertyName {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property BOOL name __attribute__((deprecated));" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"BOOL"];
			[verify(store) appendPropertyName:@"name"];
			[verify(store) beginPropertyDescriptors];
			[verify(store) appendDescriptor:@"__attribute__"];
			[verifyCount(store, times(2)) appendDescriptor:@"("];
			[verify(store) appendDescriptor:@"deprecated"];
			[verifyCount(store, times(2)) appendDescriptor:@")"];
			[verifyCount(store, times(3)) endCurrentObject]; // property
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithDescriptors_IfDescriptorStartWithAllUppercaseWord_ShouldDetectDescriptorAfterPropertyName {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property BOOL name THIS_IS_DESCRIPTOR;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"BOOL"];
			[verify(store) appendPropertyName:@"name"];
			[verify(store) beginPropertyDescriptors];
			[verify(store) appendDescriptor:@"THIS_IS_DESCRIPTOR"];
			[verifyCount(store, times(3)) endCurrentObject]; // property
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithDescriptors_IfDescriptorStartWithAllUppercaseWord_ShouldDetectAllDescriptorTokensAfterPropertyName {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property BOOL name THIS_IS_DESCRIPTOR and another;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"BOOL"];
			[verify(store) appendPropertyName:@"name"];
			[verify(store) beginPropertyDescriptors];
			[verify(store) appendDescriptor:@"THIS_IS_DESCRIPTOR"];
			[verify(store) appendDescriptor:@"and"];
			[verify(store) appendDescriptor:@"another"];
			[verifyCount(store, times(3)) endCurrentObject]; // property
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithDescriptors_EdgeCasesLimitationsForSupportingDescriptors_IfPropertyNameHasTheFormOfDescriptorButNotFollowedByOne_ShouldAllowPropertyNameWithDoubleUnderscorePrefix {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property NSString *__name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"NSString"];
			[verify(store) appendType:@"*"];
			[verify(store) appendPropertyName:@"__name"];
			[verifyCount(store, times(2)) endCurrentObject]; // property
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithDescriptors_EdgeCasesLimitationsForSupportingDescriptors_IfPropertyNameHasTheFormOfDescriptorButNotFollowedByOne_ShouldAllowPropertyNameWithUppercaseLetters {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property NSString *NAME;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"NSString"];
			[verify(store) appendType:@"*"];
			[verify(store) appendPropertyName:@"NAME"];
			[verifyCount(store, times(2)) endCurrentObject]; // property
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithDescriptors_EdgeCasesLimitationsForSupportingDescriptors_IfPropertyNameIsPrefixedWithDoubleUnderscoreFollowedByDescriptors_ShouldDetectIfFollowedByDoubleUnderscoreDescriptor {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property BOOL __name __something;"block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"BOOL"];
			[verify(store) appendPropertyName:@"__name"];
			[verify(store) beginPropertyDescriptors];
			[verify(store) appendDescriptor:@"__something"];
			[verifyCount(store, times(3)) endCurrentObject]; // descriptors
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithDescriptors_EdgeCasesLimitationsForSupportingDescriptors_IfPropertyNameIsPrefixedWithDoubleUnderscoreFollowedByDescriptors_ShouldDetectIfTypesEndWithOneOrMoreAsterisks {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property NSString ***__name __something;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"NSString"];
			[verifyCount(store, times(3)) appendType:@"*"];
			[verify(store) appendPropertyName:@"__name"];
			[verify(store) beginPropertyDescriptors];
			[verify(store) appendDescriptor:@"__something"];
			[verifyCount(store, times(3)) endCurrentObject]; // property
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithDescriptors_EdgeCasesLimitationsForSupportingDescriptors_IfPropertyNameIsAllUppercaseLettersFollowedByDescriptors_ShouldAllowIfFollowedByAllUppercaseDescriptor {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property BOOL NAME SOMETHING;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"BOOL"];
			[verify(store) appendPropertyName:@"NAME"];
			[verify(store) beginPropertyDescriptors];
			[verify(store) appendDescriptor:@"SOMETHING"];
			[verifyCount(store, times(3)) endCurrentObject]; // property
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testPropertiesWithDescriptors_EdgeCasesLimitationsForSupportingDescriptors_IfPropertyNameIsAllUppercaseLettersFollowedByDescriptorsShouldDetectIfTypesEndWithOneOrMoreAsterisks {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property NSString ***NAME SOMETHING;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"NSString"];
			[verifyCount(store, times(3)) appendType:@"*"];
			[verify(store) appendPropertyName:@"NAME"];
			[verify(store) beginPropertyDescriptors];
			[verify(store) appendDescriptor:@"SOMETHING"];
			[verifyCount(store, times(3)) endCurrentObject]; // property
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Multiple successive properties

- (void)testMultipleSuccessiveProperties_ShouldDetectSuccessivePropertiesIfInvokedMultipleTimes {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithFile:@"PropertyStateMultipleDefinitions.h" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			[state parseWithData:data];
			// verify
			[verifyCount(store, times(2)) setCurrentSourceInfo:anything()];
			[verifyCount(store, times(2)) beginPropertyDefinition];
			[verifyCount(store, times(2)) beginPropertyAttributes];
			[verifyCount(store, times(2)) appendAttribute:@"nonatomic"];
			[verify(store) appendAttribute:@"strong"];
			[verifyCount(store, times(6)) endCurrentObject]; // attributes
			[verifyCount(store, times(2)) beginPropertyTypes];
			[verify(store) appendType:@"NSString"];
			[verifyCount(store, times(2)) appendType:@"*"];
			[verify(store) appendPropertyName:@"property1"];
			[verify(store) appendAttribute:@"copy"];
			[verify(store) appendAttribute:@"readonly"];
			[verify(store) appendType:@"NSArray"];
			[verifyCount(store, times(2)) appendType:@"*"];
			[verify(store) appendPropertyName:@"property2"];
		}];
	}];
}

#pragma mark - Fail cases

- (void)testFailCases_ShouldCancelIfPropertySemicolonIsMissing {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property type name" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyTypes];
			[verify(store) appendType:@"type"];
			[verify(store) appendType:@"name"];
			[verifyCount(store, times(2)) cancelCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

- (void)testFailCasesShouldCancelIfAttributesClosingParenthesisIsMissing {
	[self runWithState:^(ObjectiveCPropertyState *state) {
		[ObjectiveCStateTestsHelpers runWithString:@"@property (attribute name;" block:^(id parser, id tokens) {
			// setup
			id store = mock([Store class]);
			ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
			// execute
			[state parseWithData:data];
			// verify
			[verify(store) setCurrentSourceInfo:anything()];
			[verify(store) beginPropertyDefinition];
			[verify(store) beginPropertyAttributes];
			[verify(store) appendAttribute:@"attribute"];
			[verify(store) appendAttribute:@"name"];
			[verifyCount(store, times(2)) cancelCurrentObject];
			XCTAssertNil([parser currentState]);
		}];
	}];
}

#pragma mark - Creator method

- (void)runWithState:(void(^)(ObjectiveCPropertyState *state))handler {
	ObjectiveCPropertyState* state = [[ObjectiveCPropertyState alloc] init];
	handler(state);
}

@end