//
//  StoreTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface Store (UnitTestingPrivateAPI)
@property (nonatomic, strong) NSMutableArray *registrationStack;
@end

@interface SharedExamplesClass : NSObject

@property (nonatomic, strong) MethodInfo *classMethod;
@property (nonatomic, strong) MethodInfo *instanceMethod;
@property (nonatomic, strong) PropertyInfo *property;
@property (nonatomic, strong) PropertyInfo *customProperty;

@end

@implementation SharedExamplesClass

#define GBStore ((Store *)info[@"store"])
#define GBReplace(t) [t gb_stringByReplacing:@{ @"$$":info[@"name"] }]

- (void)setUpTestObjects:(NSDictionary *)info {
	// initialize method "+method:"
	_classMethod = mock([MethodInfo class]);
	[given([_classMethod uniqueObjectID]) willReturn:@"method:"];

	// initialize method "-method:"
	_instanceMethod = mock([MethodInfo class]);
	[given([_instanceMethod uniqueObjectID]) willReturn:@"method:"];

	// initialize property "property"
	_property = mock([PropertyInfo class]);
	[given([_property uniqueObjectID]) willReturn:@"property"];
	[given([_property propertyGetterSelector]) willReturn:@"property"];
	[given([_property propertySetterSelector]) willReturn:@"setProperty:"];

	// initialize property "value"
	_customProperty = mock([PropertyInfo class]);
	[given([_customProperty uniqueObjectID]) willReturn:@"value"];
	[given([_customProperty propertyGetterSelector]) willReturn:@"isValue"];
	[given([_customProperty propertySetterSelector]) willReturn:@"doSomething:"];

	// register method & property to interface
	InterfaceInfoBase *interfaceInfo = info[@"object"];
	[interfaceInfo.interfaceClassMethods addObject:_classMethod];
	[interfaceInfo.interfaceInstanceMethods addObject:_instanceMethod];
	[interfaceInfo.interfaceProperties addObject:_property];
	[interfaceInfo.interfaceProperties addObject:_customProperty];

	// register interface to store
	NSMutableArray *interfacesArray = info[@"interfaces"];
	[interfacesArray addObject:interfaceInfo];
}

@end

@interface StoreTests : XCTestCase
@end

@implementation StoreTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldIntializeObjects {
	[ self runWithStore:^(Store *store) {
		// execute & verify
		XCTAssertNotNil(store.storeClasses);
		XCTAssertNotNil(store.storeExtensions);
		XCTAssertNotNil(store.storeCategories);
		XCTAssertNotNil(store.storeProtocols);
		XCTAssertNotNil(store.storeEnumerations);
		XCTAssertNotNil(store.storeStructs);
		XCTAssertNotNil(store.storeConstants);
		XCTAssertNotNil(store.registrationStack);
	}];
}

#pragma mark - Current source info

- (void)testCurrentSourceInfo_ShouldStoreInfoToProperty {
	[self runWithStore:^(Store *store) {
		// execute
		store.currentSourceInfo = (PKToken *)@"dummy-source-token";
		// verify
		XCTAssertEqualObjects(store.currentSourceInfo, @"dummy-source-token");
	}];
}

- (void)testCurrentSourceInfo_ShouldPassInfoToCurrentObjectOnRegistrationStackIfItSupportsIt {
	[self runWithStore:^(Store *store) {
		// setup
		id object = mock([ObjectInfoBase class]);
		[store pushRegistrationObject:object];
		// execute
		[store setCurrentSourceInfo:(PKToken *)@"dummy-source-token"];
		// verify
		[verify(object) setCurrentSourceInfo:(PKToken *)@"dummy-source-token"];
	}];
}

- (void)testCurrentSourceInfo_ShouldRememberObjectEvenIfPassedToCurrentObjectOnRegistrationStack {
	[self runWithStore:^(Store *store) {
		// setup
		id object = mock([ObjectInfoBase class]);
		[store pushRegistrationObject:object];
		// execute
		[store setCurrentSourceInfo:(PKToken *)@"dummy-source-token"];
		// verify
		XCTAssertEqualObjects(store.currentSourceInfo, @"dummy-source-token");
	}];
}

- (void)testCurrentSourceInfo_ShouldNotPassInfoToCurrentObjectOnRegistrationStackIfItDoesNotSupportIt {
	[self runWithStore:^(Store *store) {
		// setup - note that this will raise exception if any message is sent to object.
		id object = mock([NSObject class]);
		[store pushRegistrationObject:object];
		// execute
		[store setCurrentSourceInfo:(PKToken *)@"dummy-source-token"];
	}];
}

#pragma mark - Class registration

- (void)testClassRegistration_ShouldAddClassInfoToRegistrationStack {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginClassWithName:@"name" derivedFromClassWithName:@"derived"];
		// verify
		XCTAssertTrue([store.currentRegistrationObject isKindOfClass:[ClassInfo class]]);
		XCTAssertEqualObjects([[store.currentRegistrationObject classSuperClass] nameOfObject], @"derived");
		XCTAssertEqual([store.currentRegistrationObject objectRegistrar], store);
		
	}];
}

- (void)testClassRegistration_ShouldAddClassInfoToClassesArray {
	[self runWithStore:^(Store *store) {
		//execute
		[store beginClassWithName:@"name" derivedFromClassWithName:@"derived"];
		// verify
		XCTAssertEqual(store.storeClasses.count, 1ul);
		XCTAssertTrue([store.storeClasses containsObject:(store.currentRegistrationObject)]);
	}];
}

- (void)testClassRegistration_ShouldSetCurrentSourceInfoToClass {
	[self runWithStore:^(Store *store) {
		// setup
		store.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[store beginClassWithName:@"name" derivedFromClassWithName:@"derived"];
		// verify
		XCTAssertEqualObjects([store.currentRegistrationObject sourceToken], store.currentSourceInfo);
	}];
}

#pragma mark - Class extension registration

- (void)testClassExtensionRegistration_ShouldAddCategoryInfoToRegistrationStack {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginExtensionForClassWithName:@"name"];
		// verify
		XCTAssertTrue([store.currentRegistrationObject isKindOfClass:[CategoryInfo class]]);
		XCTAssertEqualObjects([store.currentRegistrationObject nameOfClass], @"name");
		XCTAssertNil([store.currentRegistrationObject nameOfCategory]);
		XCTAssertEqual([store.currentRegistrationObject objectRegistrar], store);
	}];
}

- (void)testClassExtensionRegistration_ShouldAddCategoryInfoToExtensionsArray {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginExtensionForClassWithName:@"name"];
		// verify
		XCTAssertEqual(store.storeExtensions.count, 1ul);
		XCTAssertTrue([store.storeExtensions containsObject:(store.currentRegistrationObject)]);
	}];
}

- (void)testClassExtensionRegistration_ShouldSetCurrentSourceInfoToCategory {
	[self runWithStore:^(Store *store) {
		// setup
		store.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[store beginExtensionForClassWithName:@"name"];
		// verify
		XCTAssertEqual([store.currentRegistrationObject sourceToken], store.currentSourceInfo);
	}];
}

#pragma mark - Class category registration

- (void)testClassCategoryRegistration_shouldAddCategoryInfoToRegistrationStack {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginCategoryWithName:@"category" forClassWithName:@"name"];
		// verify
		XCTAssertTrue([store.currentRegistrationObject isKindOfClass:[CategoryInfo class]]);
		XCTAssertEqualObjects([store.currentRegistrationObject nameOfClass], @"name");
		XCTAssertEqualObjects([store.currentRegistrationObject nameOfCategory], @"category");
		XCTAssertEqual([store.currentRegistrationObject objectRegistrar], store);
	}];
}

- (void)testClassCategoryRegistration_ShouldAddCategoryInfoToCategoriesArray {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginCategoryWithName:@"category" forClassWithName:@"name"];
		// verify
		XCTAssertEqual(store.storeCategories.count, 1ul);
		XCTAssertTrue([store.storeCategories containsObject:(store.currentRegistrationObject)]);
	}];
}

- (void)testClassCategoryRegistration_ShouldSetCurrentSourceInfoToClass {
	[self runWithStore:^(Store *store) {
		// setup
		store.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[store beginCategoryWithName:@"category" forClassWithName:@"class"];
		// verify
		XCTAssertEqual([store.currentRegistrationObject sourceToken], store.currentSourceInfo);
	}];
}

#pragma mark - Protocol registration

- (void)testProtocolRegistration_ShouldAddProtocolInfoToRegistrationStack {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginProtocolWithName:@"name"];
		// verify
		XCTAssertTrue([store.currentRegistrationObject isKindOfClass:[ProtocolInfo class]]);
		XCTAssertEqualObjects([store.currentRegistrationObject nameOfProtocol], @"name");
		XCTAssertEqual([store.currentRegistrationObject objectRegistrar], store);
	}];
}

- (void)testProtocolRegistration_ShouldAddProtocolInfoToProtocolArray {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginProtocolWithName:@"name"];
		// verify
		XCTAssertEqual(store.storeProtocols.count, 1ul);
		XCTAssertTrue([store.storeProtocols containsObject:(store.currentRegistrationObject)]);
	}];
}

- (void)testProtocolRegistration_ShouldSetCurrentSourceInfoToClass {
	[self runWithStore:^(Store *store) {
		// setup
		store.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[store beginProtocolWithName:@"name"];
		// verify
		XCTAssertEqual([store.currentRegistrationObject sourceToken], store.currentSourceInfo);
	}];
}

#pragma mark - Interface related methods

- (void)testInterfaceRelatedMethods_ShouldForwardAppnedProtocolToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendAdoptedProtocolWithName:@"name"];
		// verify
		[verify(mock) appendAdoptedProtocolWithName:@"name"];
	}];
}

#pragma mark - Method group related methods

- (void)testMethodGroupRelatedMethods_ShouldForwardAppendMethodGroupDescriptionToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendMethodGroupWithDescription:@"description"];
		// verify
		[verify(mock) appendMethodGroupWithDescription:@"description"];
	}];
}

#pragma mark - Property related methods

- (void)testPropertyRelatedMethods_ShouldForwardBeginPropertyDefinitionToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginPropertyDefinition];
		// verify
		[verify(mock) beginPropertyDefinition];
	}];
}

- (void)testPropertyRelatedMethods_ShouldForwardBeginPropertyAttributesToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginPropertyAttributes];
		// verify
		[verify(mock) beginPropertyAttributes];
	}];
}

- (void)testPropertyRelatedMethods_ShouldForwardBeginPropertyTypesToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginPropertyTypes];
		// verify
		[verify(mock) beginPropertyTypes];
	}];
}

- (void)testPropertyRelatedMethods_ShouldForwardBeginPropertyDescriptorsToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginPropertyDescriptors];
		// verify
		[verify(mock) beginPropertyDescriptors];
	} ];
}

- (void)testPropertyRelatedMethods_ShouldForwardAppendPropertyNameToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendPropertyName:@"name"];
		// verify
		[verify(mock) appendPropertyName:@"name"];
	}];
}

#pragma mark - Method related registration

- (void)testMethodRelatedRegistration_ShouldForwardBeginMethodToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginMethodDefinitionWithType:@"type"];
		// verify
		[verify(mock) beginMethodDefinitionWithType:@"type"];
	}];
}

- (void)testMethodRelatedRegistration_ShouldForwardBeginMethodResultsToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginMethodResults];
		// verify
		[verify(mock) beginMethodResults];
	}];
}

- (void)testMethodRelatedRegistration_ShouldForwardBeginMethodArgumentToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginMethodArgument];
		// verify
		[verify(mock) beginMethodArgument];
	}];
}

- (void)testMethodRelatedRegistration_ShouldForwardBeginMethodArgumentTypesToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginMethodArgumentTypes];
		// verify
		[verify(mock) beginMethodArgumentTypes];
	}];
}

- (void)testMethodRelatedRegistration_ShouldForwardBeginMethodDescriptorsToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginMethodDescriptors];
		// verify
		[verify(mock) beginMethodDescriptors];
	}];
}

- (void)testMethodRelatedRegistartion_ShouldForwardAppendMethodArgumentSelectorToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendMethodArgumentSelector:@"selector"];
		// verify
		[verify(mock) appendMethodArgumentSelector:@"selector"];
	}];
}

- (void)testMethodRelatedRegistration_ShouldForwardAppendMethodArgumentVariableToCurrentRegistrationObject {
	[ self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendMethodArgumentVariable:@"variable"];
		// verify
		[verify(mock) appendMethodArgumentVariable:@"variable"];
	}];
}

#pragma mark - Enum related registration

- (void)testEnumRelatedRegistration_ShouldAddEnumerationInfoToRegistrationStack {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginEnumeration];
		// verify
		XCTAssertTrue([store.currentRegistrationObject isMemberOfClass:([EnumInfo class])]);
		XCTAssertEqual([store.currentRegistrationObject objectRegistrar], store);
	}];
}

- (void)testEnumRelatedRegistration_ShouldAddEnumerationInfoToEnumerationsArray {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginEnumeration];
		// verify
		XCTAssertEqual(store.storeEnumerations.count, 1ul);
		XCTAssertTrue([store.storeEnumerations containsObject:(store.currentRegistrationObject)]);
	}];
}

- (void)testEnumRelatedRegistration_ShouldSetCurrentSourceInfoToClass {
	[self runWithStore:^(Store *store) {
		// setup
		store.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[store beginEnumeration];
		// verify
		XCTAssertEqual([store.currentRegistrationObject sourceToken], store.currentSourceInfo);
	}];
}

- (void)testEnumRelatedRegistration_ShouldForwardAppendEnumerationNameToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendEnumerationName:@"value"];
		// verify
		[verify(mock) appendEnumerationName:@"value"];
	}];
}

- (void)testEnumRelatedRegistration_ShouldForwardAppendEnumerationItemToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendEnumerationItem:@"value"];
		// verify
		[verify(mock) appendEnumerationItem:@"value"];
	}];
}

- (void)testEnumRelatedRegistration_ShouldForwardAppendEnumerationValueToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendEnumerationValue:@"value"];
		// verify
		[verify(mock) appendEnumerationValue:@"value"];
	}];
}


#pragma mark - Struct related registration

- (void)teststructRelatedRegistration_ShouldAddStructInfoToRegistrationStack {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginStruct];
		// verify
		XCTAssertTrue([store.currentRegistrationObject isMemberOfClass:([StructInfo class])]);
		XCTAssertEqual([store.currentRegistrationObject objectRegistrar], store);
	}];
}

- (void)teststructRelatedRegistration_ShouldAddStructInfoToStructArray {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginStruct];
		// verify
		XCTAssertEqual(store.storeStructs.count, 1ul);
		XCTAssertTrue([store.storeStructs containsObject:(store.currentRegistrationObject)]);
	}];
}

- (void)teststructRelatedRegistration_ShouldSetCurrentSourceInfoToClass {
	[self runWithStore:^(Store *store) {
		// setup
		store.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[store beginStruct];
		// verify
		XCTAssertEqual([store.currentRegistrationObject sourceToken], store.currentSourceInfo);
	}];
}

- (void)teststructRelatedRegistration_ShouldForwardAppendStructNameToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendStructName:@"value"];
		// verify
		[verify(mock) appendStructName:@"value"];
	}];
}

#pragma mark - Constant related registration

- (void)testConstantRelatedRegistration_IfRegistrationStackIsEmpty_ShouldAddConstantInfoToRegistartionStack {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginConstant];
		// verify
		XCTAssertTrue([store.currentRegistrationObject isMemberOfClass:([ConstantInfo class])]);
		XCTAssertEqual([store.currentRegistrationObject objectRegistrar], store);
	}];
}

- (void)testConstantRelatedRegistration_IfRegistrationStackIsEmpty_ShouldAddConstantInfoToConstantsArray {
	[self runWithStore:^(Store *store) {
		// execute
		[store beginConstant];
		// verify
		XCTAssertEqual(store.storeConstants.count, 1ul);
		XCTAssertTrue([store.storeConstants containsObject:(store.currentRegistrationObject)]);
	}];
}

- (void)testConstantRelatedRegistration_IfRegistrationStackIsEmpty_ShouldSetCurrentSourceInfoToClass {
	[self runWithStore:^(Store *store) {
		// setup
		store.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[store beginConstant];
		// verify
		XCTAssertEqual([store.currentRegistrationObject sourceToken], store.currentSourceInfo);
	}];
}

- (void)testConstantRelatedRegistration_IfRegistrationStackIsEmptyButCurrentObjectDoesNotHandleConstants_ShouldAddConstantinfoToRegistrationStack {
	[self runWithStore:^(Store *store) {
		// setup
		[store pushRegistrationObject:[NSObject new]];
		// execute
		[store beginConstant];
		// verify
		XCTAssertTrue([store.currentRegistrationObject isMemberOfClass:([ConstantInfo class])]);
		XCTAssertEqual([store.currentRegistrationObject objectRegistrar], store);
	}];
}

- (void)testConstantRelatedRegistration_IfRegistrationStackIsEmptyButCurrentObjectDoesNotHandleConstants_ShouldAddConstantInfoToConstantsArray {
	[self runWithStore:^(Store *store) {
		// setup
		[store pushRegistrationObject:[NSObject new]];
		// execute
		[store beginConstant];
		// verify
		XCTAssertEqual(store.storeConstants.count, 1ul);
		XCTAssertTrue([store.storeConstants containsObject:(store.currentRegistrationObject)]);
	}];
}

- (void)testConstantRelatedRegistration_IfCurrentRegistrationObjectHandlesConstants_ShouldForwardBeginConstantToCurrentRegistrationobject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginConstant];
		// verify
		[verify(mock) beginConstant];
		XCTAssertEqual(store.storeConstants.count, 0ul);
	}];
}

- (void)testConstantRelatedRegistration_IfCurrentRegistrationObjectHandlesConstants_ShouldForwardBeginConstantTypesToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginConstantTypes];
		// verify
		[verify(mock) beginConstantTypes];
	}];
}

- (void)testConstantRelatedRegistration_IfCurrentRegistrationObjectHandlesConstants_ShouldForwardBeginConstantDescriptorsToCurrentRegistartionObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store beginConstantDescriptors];
		// verify
		[verify(mock) beginConstantDescriptors];
	}];
}

- (void)testConstantRelatedRegistration_IfCurrentRegistrationObjectHandlesConstants_ShouldForwardAppendConstantNameToCurrentRegistartionObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendConstantName:@"value"];
		// verify
		[verify(mock) appendConstantName:@"value"];
	}];
}

#pragma mark - Common registrations

- (void)testCommonRegistrations_ShouldForwardAppendTypeToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendType:@"value"];
		// verify
		[verify(mock) appendType:@"value"];
	}];
}

- (void)testCommonRegistrations_ShouldForwardAppendAttributeToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendAttribute:@"value"];
		// verify
		[verify(mock) appendAttribute:@"value"];
	}];
}

- (void)testCommonRegistrations_ShouldForwardAppendDescriptionToCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id mock = mock([Store class]);
		[store pushRegistrationObject:mock];
		// execute
		[store appendDescriptor:@"value"];
		// verify
		[verify(mock) appendDescriptor:@"value"];
	}];
}

#pragma mark - Comments registration

- (void)testCommentsRegistration_PreviousObject_ShouldCreateCommentAndAddItToLastPoppedObject {
	[self runWithStore:^(Store *store) {
		// setup
		id object = mock([ObjectInfoBase class]);
		[store pushRegistrationObject:object];
		[store popRegistrationObject];
		// execute
		[store appendCommentToPreviousObject:@"text"];
		// verify
		XCTAssertThrows([verify(object) appendCommentToPreviousObject:@"text"]);
#warning check verify phase
	}];
}

- (void)testCommentsRegistration_PreviousObject_ShouldAppendCurrentSourceInfoToToken {
	[self runWithStore:^(Store *store) {
		// setup
		PKToken *token = [PKToken tokenWithTokenType:PKTokenTypeComment stringValue:@"text" floatValue:0.0];
		id object = mock([ObjectInfoBase class]);
		[store pushRegistrationObject:object];
		[store popRegistrationObject];
		// execute
		[store setCurrentSourceInfo:token];
		[store appendCommentToPreviousObject:@"text"];
		// verify
		XCTAssertThrows([verify(object) appendCommentToPreviousObject:@"text"]);
#warning check verify phase
	}];
}


- (void)testCommentsRegistration_NextObject_ShouldNotAddCommentToCurrentObject {
	[self runWithStore:^(Store *store) {
		// setup - no expectations needed; strong mock will fail if any unexpected message is received
		id object = mock([ObjectInfoBase class]);
		[store pushRegistrationObject:object];
		// execute
		[store appendCommentToNextObject:@"text"];
		// verify
		XCTAssertNil([store.currentRegistrationObject comment]);
	}];
}

- (void)testCommentsRegistration_NextObject_ShouldAddCommentToFirstObjectRegisteredAfterAppendingComment {
	[self runWithStore:^(Store *store) {
		// setup
		id object = mock([ObjectInfoBase class]);
		// execute
		[store appendCommentToNextObject:@"text"];
		[store pushRegistrationObject:object];
		// verify
		XCTAssertThrows([verify(object) appendCommentToNextObject:@"text"]);
#warning check verify phase
	}];
}

- (void)testCommentsRegistration_NextObject_ShouldClearCommentAfterAppendingToNewObject {
	[self runWithStore:^(Store *store) {
		// setup - no expectations required for second mock; strong mocks fail if any unexpected message is received
		id object1 = mock([ObjectInfoBase class]);
		id object2 = mock([ObjectInfoBase class]);
		[store appendCommentToNextObject:@"text"];
		[store pushRegistrationObject:object1];
		// execute
		[store pushRegistrationObject:object2];
		// verify
		XCTAssertEqualObjects([store.currentRegistrationObject comment], nil);
	}];
}

#pragma mark - End current object

- (void)testEndCurrentObject_ShouldRemoveLastObjectFromRegistrationStack {
	[self runWithStore:^(Store *store) {
		// setup
		[store pushRegistrationObject:mock([Store class])];
		// execute
		[store endCurrentObject];
		// verify
		XCTAssertEqual(store.registrationStack.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

- (void)testEndCurrentObject_ShouldForwardToSemilastObjectOnRegistrationStackIfItHandlesEndMessageAndThenRemoveLastObjectFromRegistrationStack {
	[self runWithStore:^(Store *store) {
		// setup
		id first = mockClass([Store class]);
		[store pushRegistrationObject:first];
		id second = mockClass([Store class]);
		[store pushRegistrationObject:second];
		// execute
		[store endCurrentObject];
		// verify
		XCTAssertThrows([verify(first) endCurrentObject]);
		XCTAssertThrows([verify(second) endCurrentObject]);
		XCTAssertEqual(store.registrationStack.count, 1ul);
		XCTAssertTrue([store.registrationStack containsObject:(first)]);
		XCTAssertEqualObjects(store.currentRegistrationObject, first);
	}];
}

- (void)testEndCurrentObject_ShouldNotForwardToSemilastObjectOnRegistrationStackIfItDoesNotRespondToEndMessageButShouldRemoveLastObjectFromRegistrationStack {
	[self runWithStore:^(Store *store) {
		// setup
		id first = mockClass([Store class]);
		[store pushRegistrationObject:first];
		id second = mockClass([Store class]);
		[store pushRegistrationObject:second];
		// execute
		[store endCurrentObject];
		// verify
		XCTAssertEqual(store.registrationStack.count, 1ul);
		XCTAssertTrue([store.registrationStack containsObject:(first)]);
		XCTAssertEqualObjects(store.currentRegistrationObject, first);
	}];
}

- (void)testEndCurrentObject_ShouldIgnoreIfRegistrationStackIsEmpty {
	[self runWithStore:^(Store *store) {
		// execute
		[store endCurrentObject];
		// verify - real code logs a warning, but we don't test that here
		XCTAssertEqual(store.registrationStack.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

#pragma mark - Cancel current object

- (void)testCancelCurrentObject_IfRegistrationStackContainsAtLeastTwoObjects_ShouldForwardToSemilastObjectIfItRespondsToMessageAndThenRemoveLastObjectFromRegistrationStack  {
	[self runWithStore:^(Store *store) {
		// setup
		id first = mock([Store class]);
		[store pushRegistrationObject:first];
		id second = mock([Store class]);
		[store pushRegistrationObject:second];
		// execute
		[store cancelCurrentObject];
		// verify
		[verify(first) cancelCurrentObject];
		[verifyCount(second, never()) cancelCurrentObject];
		XCTAssertEqual(store.registrationStack.count, 1ul);
		XCTAssertTrue([store.registrationStack containsObject:(first)]);
		XCTAssertEqualObjects(store.currentRegistrationObject, first);
	}];
}

- (void)testCancelCurrentObject_IfRegistrationStackContainsAtLeastTwoObjects_ShouldNotForwardToSemilastObjectIfItRespondsToMessageButShouldRemoveLastObjectFromRegistrationStack {
	[self runWithStore:^(Store *store) {
		// setup
		id first = mock([NSObject class]);
		[store pushRegistrationObject:first];
		id second = mock([Store class]);
		[store pushRegistrationObject:second];
		// execute
		[store cancelCurrentObject];
		// verify
		//[verifyCount(first, never()) cancelCurrentObject]; // doesn't work because OCMockito strictly checks that mocked class implements given method
		[verifyCount(second, never()) cancelCurrentObject];
		XCTAssertEqual(store.registrationStack.count, 1ul);
		XCTAssertTrue([store.registrationStack containsObject:(first)]);
		XCTAssertEqualObjects(store.currentRegistrationObject, first);
	}];
}

- (void)testCancelCurrentObject_IfRegistrationStackContainsOneObject_ShouldRemoveLastObjectFromRegistrationStack {
	[self runWithStore:^(Store *store) {
		// setup
		[store pushRegistrationObject:mockClass([Store class])];
		// execute
		[store cancelCurrentObject];
		// verify
		XCTAssertEqual(store.registrationStack.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

- (void)testCancelCurrentObject_IfRegistrationStackIsEmpty_ShouldIgnore {
	[self runWithStore:^(Store *store) {
		// execute
		[store cancelCurrentObject];
		// verify - real code logs a warning, but we don't test that here, just verify no exception is thrown
		XCTAssertEqual(store.registrationStack.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

- (void)testCancelCurrentObject_RegisteredDataHandling_ShouldRemoveLastClass {
	[self runWithStore:^(Store *store) {
		// setup
		[store beginClassWithName:@"name" derivedFromClassWithName:@"derived"];
		// execute
		[store cancelCurrentObject];
		// verify
		XCTAssertEqual(store.storeClasses.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

- (void)testCancelCurrentObject_RegisteredDataHandling_ShouldRemoveLastClassCategory {
	[self runWithStore:^(Store *store) {
		// setup
		[store beginCategoryWithName:@"category" forClassWithName:@"name"];
		// execute
		[store cancelCurrentObject];
		// verify
		XCTAssertEqual(store.storeCategories.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

- (void)testCancelCurrentObject_RegisteredDataHandling_ShouldRemoveLastProtocol {
	[self runWithStore:^(Store *store) {
		// setup
		[store beginProtocolWithName:@"name"];
		// execute
		[store cancelCurrentObject];
		// verify
		XCTAssertEqual(store.storeProtocols.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

- (void)testCancelCurrentObject_RegisteredDataHandling_ShouldRemoveLastEnum {
	[self runWithStore:^(Store *store) {
		// setup
		[store beginEnumeration];
		// execute
		[store cancelCurrentObject];
		// verify
		XCTAssertEqual(store.storeEnumerations.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

- (void)testCancelCurrentObject_RegisteredDataHandling_ShouldRemoveLastStruct {
	[self runWithStore:^(Store *store) {
		// setup
		[store beginStruct];
		// execute
		[store cancelCurrentObject];
		// verify
		XCTAssertEqual(store.storeStructs.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

- (void)testCancelCurrentObject_RegisteredDataHandling_ShouldRemoveLastConstant {
	[self runWithStore:^(Store *store) {
		// setup
		[store beginConstant];
		// execute
		[store cancelCurrentObject];
		// verify
		XCTAssertEqual(store.storeConstants.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
	}];
}

#pragma mark - Registration stack handling

- (void)testRegistrationStackHandling_PushingObjects_ShouldPushRegistrationObjectAndUpdateCurrentRegistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id child = @"child";
		// execute
		[store pushRegistrationObject:child];
		// verify
		XCTAssertEqual(store.registrationStack.count, 1ul);
		XCTAssertTrue([store.registrationStack containsObject:(child)]);
		XCTAssertEqualObjects(store.currentRegistrationObject, child);
	}];
}

- (void)testRegistrationStackHandling_PushingObjects_ShouldPushMultipleObjectsAndUpdateCurrentregistrationObject {
	[self runWithStore:^(Store *store) {
		// setup
		id child1 = @"child1";
		id child2 = @"child2";
		// execute
		[store pushRegistrationObject:child1];
		[store pushRegistrationObject:child2];
		// verify
		XCTAssertEqual(store.registrationStack.count, 2ul);
		XCTAssertEqualObjects((store.registrationStack)[0], child1);
		XCTAssertEqualObjects((store.registrationStack)[1], child2);
		XCTAssertEqualObjects(store.currentRegistrationObject, child2);
	}];
}

- (void)testRegistrationStackHandling_PoppingObjects_ShouldRemoveLastObjectFromStackWithMultipleObjects {
	[self runWithStore:^(Store *store) {
		// setup
		id child1 = @"child1";
		id child2 = @"child2";
		[store pushRegistrationObject:child1];
		[store pushRegistrationObject:child2];
		// execute
		id poppedObject = [store popRegistrationObject];
		// verify
		XCTAssertEqual(store.registrationStack.count, 1ul);
		XCTAssertEqualObjects((store.registrationStack)[0], child1);
		XCTAssertEqualObjects(store.currentRegistrationObject, child1);
		XCTAssertEqualObjects(poppedObject, child2);
	}];
}

- (void)testRegistrationStackHandling_PoppingObjects_ShouldRemoveLastObjectFromStack {
	[self runWithStore:^(Store *store) {
		// setup
		id child = @"child1";
		[store pushRegistrationObject:child];
		// execute
		id poppedObject = [store popRegistrationObject];
		// verify
		XCTAssertEqual(store.registrationStack.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
		XCTAssertEqualObjects(poppedObject, child);
	}];
}

- (void)testRegistrationStackHandling_PoppingObjects_ShouldIgnoreIfStackIsEmpty {
	[self runWithStore:^(Store *store) {
		// execute
		id poppedObject = [store popRegistrationObject];
		// verify - note that in this case we log a warning, but we don't test that...
		XCTAssertEqual(store.registrationStack.count, 0ul);
		XCTAssertNil(store.currentRegistrationObject);
		XCTAssertNil(poppedObject);
	}];
}

#pragma mark - Cache handling

- (void)testCacheHandling_TopLevelObjects_ShouldReturnClass {
	[self runWithStore:^(Store *store) {
		// setup
		[store beginClassWithName:@"name" derivedFromClassWithName:@"super"];
		// execute
		ClassInfo *object = store.topLevelObjectsCache[@"name"];
		// verify
		XCTAssertTrue([object isMemberOfClass:([ClassInfo class])]);
		XCTAssertEqual(object.nameOfClass, @"name");
		XCTAssertEqual(object.classSuperClass.nameOfObject, @"super");
	}];
}

- (void)testCacheHandling_TopLevelObjects_ShouldReturnExtension {
	[self runWithStore:^(Store *store) {
		// setup
		[store beginExtensionForClassWithName:@"name"];
		// execute
		CategoryInfo *object = store.topLevelObjectsCache[@"name()"];
		// verify
		XCTAssertTrue([object isMemberOfClass:([CategoryInfo class])]);
		XCTAssertEqual(object.nameOfClass, @"name");
		XCTAssertNil(object.nameOfCategory);
	}];
}

- (void)testCacheHandling_TopLevelObjects_ShouldReturnCategory {
	[self runWithStore:^(Store *store) {
		// setup
		[store beginCategoryWithName:@"category" forClassWithName:@"name"];
		// execute
		CategoryInfo *object = store.topLevelObjectsCache[@"name(category)"];
		// verify
		XCTAssertTrue([object isMemberOfClass:([CategoryInfo class])]);
		XCTAssertEqual(object.nameOfClass, @"name");
		XCTAssertEqual(object.nameOfCategory, @"category");
	}];
}

- (void)testCachehandling_Classes {
	[self runWithStore:^(Store *store) {
		// setup
		ClassInfo *classInfo = [[ClassInfo alloc] init];
		classInfo.nameOfClass = @"MyClass";
		NSDictionary *info = [NSDictionary dictionaryWithObjects:@[store, classInfo, store.storeClasses, classInfo.uniqueObjectID]
														 forKeys:@[@"store", @"object", @"interfaces", @"name"]];
		SharedExamplesClass *sharedData = [[SharedExamplesClass alloc] init];
		[sharedData setUpTestObjects:info];

		// should handle class method
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"+[$$ method:]")], sharedData.classMethod);
		// should handle instance method
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ method:]")], sharedData.instanceMethod);
		
		// should handle property
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"[$$ property]")], sharedData.property);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ property]")], sharedData.property);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ setProperty:]")], sharedData.property);
		
		// should handle custom property getters and setters
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"[$$ value]")], sharedData.customProperty);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ isValue]")], sharedData.customProperty);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ doSomething:]")], sharedData.customProperty);
	}];
}

- (void)testCachehandling_Extensions {
	[self runWithStore:^(Store *store) {
		// setup
		CategoryInfo *categoryInfo = [[CategoryInfo alloc] init];
		categoryInfo.categoryClass.nameOfObject = @"MyClass";
		categoryInfo.nameOfCategory = @"";
		NSDictionary *info = [NSDictionary dictionaryWithObjects:@[store, categoryInfo, store.storeExtensions, categoryInfo.uniqueObjectID]
														 forKeys:@[@"store", @"object", @"interfaces", @"name"]];
		SharedExamplesClass *sharedData = [[SharedExamplesClass alloc] init];
		[sharedData setUpTestObjects:info];

		// should handle class method
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"+[$$ method:]")], sharedData.classMethod);
		// should handle instance method
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ method:]")], sharedData.instanceMethod);
		
		// should handle property
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"[$$ property]")], sharedData.property);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ property]")], sharedData.property);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ setProperty:]")], sharedData.property);
		
		// should handle custom property getters and setters
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"[$$ value]")], sharedData.customProperty);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ isValue]")], sharedData.customProperty);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ doSomething:]")], sharedData.customProperty);
	}];
}

- (void)testCachehandling_Categories {
	[self runWithStore:^(Store *store) {
		// setup
		CategoryInfo *categoryInfo = [[CategoryInfo alloc] init];
		categoryInfo.categoryClass.nameOfObject = @"MyClass";
		categoryInfo.nameOfCategory = @"MyCategory";
		NSDictionary *info = [NSDictionary dictionaryWithObjects:@[store, categoryInfo, store.storeCategories, categoryInfo.uniqueObjectID]
														 forKeys:@[@"store", @"object", @"interfaces", @"name"]];
		SharedExamplesClass *sharedData = [[SharedExamplesClass alloc] init];
		[sharedData setUpTestObjects:info];

		// should handle class method
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"+[$$ method:]")], sharedData.classMethod);
		// should handle instance method
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ method:]")], sharedData.instanceMethod);
		
		// should handle property
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"[$$ property]")], sharedData.property);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ property]")], sharedData.property);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ setProperty:]")], sharedData.property);
		
		// should handle custom property getters and setters
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"[$$ value]")], sharedData.customProperty);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ isValue]")], sharedData.customProperty);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ doSomething:]")], sharedData.customProperty);
	}];
}
- (void)testCachehandling_Protocols {
	[self runWithStore:^(Store *store) {
		// setup
		ProtocolInfo *protocolInfo = [[ProtocolInfo alloc] init];
		protocolInfo.nameOfProtocol = @"MyProtocol";
		NSDictionary *info = [NSDictionary dictionaryWithObjects:@[store, protocolInfo, store.storeProtocols, protocolInfo.uniqueObjectID]
														 forKeys:@[@"store", @"object", @"interfaces", @"name"]];
		SharedExamplesClass *sharedData = [[SharedExamplesClass alloc] init];
		[sharedData setUpTestObjects:info];

		// should handle class method
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"+[$$ method:]")], sharedData.classMethod);
		// should handle instance method
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ method:]")], sharedData.instanceMethod);
		
		// should handle property
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"[$$ property]")], sharedData.property);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ property]")], sharedData.property);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ setProperty:]")], sharedData.property);
		
		// should handle custom property getters and setters
		// execute & verify
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"[$$ value]")], sharedData.customProperty);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ isValue]")], sharedData.customProperty);
		XCTAssertEqualObjects(GBStore.memberObjectsCache[GBReplace(@"-[$$ doSomething:]")], sharedData.customProperty);

	}];
}

#pragma mark - Creator method

- (void)runWithStore:(void(^)(Store *store))handler {
	Store *store = [[Store alloc] init];
	handler(store);
}

@end