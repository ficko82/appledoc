//
//  InterfaceInfoBaseTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface InterfaceInfoBaseTests : XCTestCase
@end

@implementation InterfaceInfoBaseTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute & verify
		XCTAssertNotNil(info.interfaceAdoptedProtocols);
		XCTAssertNotNil(info.interfaceMethodGroups);
		XCTAssertNotNil(info.interfaceProperties);
		XCTAssertNotNil(info.interfaceInstanceMethods);
		XCTAssertNotNil(info.interfaceClassMethods);
	}];
}

#pragma mark - Adopted protocols registration

- (void)testAdoptedProtocolsRegistration_ShouldAddAllProtocolsToArray {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info appendAdoptedProtocolWithName:@"name1"];
		[info appendAdoptedProtocolWithName:@"name2"];
		// verify
		XCTAssertEqual(info.interfaceAdoptedProtocols.count, 2ul);
		XCTAssertEqualObjects([(info.interfaceAdoptedProtocols)[0] nameOfObject], @"name1");
		XCTAssertEqualObjects([(info.interfaceAdoptedProtocols)[1] nameOfObject], @"name2");
	}];
}

- (void)testAdoptedProtocolsRegistration_ShouldIgnoreExistingNames {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info appendAdoptedProtocolWithName:@"name"];
		[info appendAdoptedProtocolWithName:@"name"];
		// verify
		XCTAssertEqual(info.interfaceAdoptedProtocols.count, 1ul);
		XCTAssertEqualObjects([(info.interfaceAdoptedProtocols)[0] nameOfObject], @"name");
	}];
}

#pragma mark - Method group registration

- (void)testMethodGroupRegistration_ShouldCreateNewMethodGroupInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info appendMethodGroupWithDescription:@"description"];
		// verify
		XCTAssertEqual(info.interfaceMethodGroups.count, 1ul);
		XCTAssertTrue([info.interfaceMethodGroups.lastObject isMemberOfClass:([MethodGroupInfo class])]);
		XCTAssertEqualObjects([info.interfaceMethodGroups.lastObject nameOfMethodGroup], @"description");
	}];
}

- (void)testMethodGroupRegistration_ShouldNotAddNewObjectToStackInterfaceNeedstoBeAbleToCatchMethodAndPropertiesRegistration {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info appendMethodGroupWithDescription:@"description"];
		// verify
		[verifyCount(mock, never()) pushRegistrationObject:instanceOf([MethodGroupInfo class])];
	}];
}

#pragma mark - Properties registration

- (void)testPropertiesRegistration_ShouldCreateNewPropertyInfo {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		info.objectRegistrar = mock([Store class]);
		// execute
		[info beginPropertyDefinition];
		// verify
		XCTAssertEqual(info.interfaceProperties.count, 1ul);
		XCTAssertTrue([info.interfaceProperties.lastObject isMemberOfClass:([PropertyInfo class])]);
		XCTAssertEqualObjects([info.interfaceProperties.lastObject objectRegistrar], info.objectRegistrar);
	 }];
}

- (void)testPropertiesRegistration_ShouldPushPropertyInfoToRegistrationStack {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginPropertyDefinition];
		// verify
		[verify(mock) pushRegistrationObject:instanceOf([PropertyInfo class])];
	}];
}

- (void)testPropertiesRegistration_ShouldSetSelfAsParentOfCreatedProperty {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// exexute
		[info beginPropertyDefinition];
		// verify
		XCTAssertEqualObjects([info.currentRegistrationObject memberParent], info);
	}];
}

- (void)testPropertiesRegistration_ShouldSetCurrentSourceInfoToClass {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// setup
		info.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[info beginPropertyDefinition];
		// verify
		XCTAssertEqualObjects([info.currentRegistrationObject sourceToken], info.currentSourceInfo);
	}];
}

- (void)testPropertiesRegistration_ShouldAddPropertyInfoToLastMethodGroupIfOneExists {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		// execute
		[info beginPropertyDefinition];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		XCTAssertEqual(lastMethodGroupMethods.count, 1ul);
		XCTAssertTrue([lastMethodGroupMethods.lastObject isMemberOfClass:([PropertyInfo class])]);
	}];
}

- (void)testPropertiesRegistration_ShouldNotCreateNewMethodGroupIfNoneExists {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info beginPropertyDefinition];
		// verify
		XCTAssertEqual(info.interfaceMethodGroups.count, 0ul);
	}];
}

#pragma mark - Methods registration

- (void)testMethodsRegistration_ClassMethods_ShouldCreateNewMethodInfoAndAddItToClassMethodsArray {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		info.objectRegistrar = mock([Store class]);
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		XCTAssertEqual(info.interfaceClassMethods.count, 1ul);
		XCTAssertTrue([info.interfaceClassMethods.lastObject isMemberOfClass:([MethodInfo class])]);
		XCTAssertEqualObjects([info.interfaceClassMethods.lastObject methodType], GBStoreTypes.classMethod);
		XCTAssertEqualObjects([info.interfaceClassMethods.lastObject objectRegistrar], info.objectRegistrar);
	}];
}

- (void)testMethodsRegistration_ClassMethods_ShouldPushMethodInfoToRegistrationStack {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:instanceOf([MethodInfo class])]);
	}];
}

- (void)testMethodsRegistration_ClassMethods_ShouldSetSelfAsParentOfCreatedMethod {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// exexute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		XCTAssertEqualObjects([info.currentRegistrationObject memberParent], info);
	}];
}

- (void)testMethodsRegistration_ClassMethods_ShouldSetCurrentSourceInfoToClass {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// setup
		info.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		XCTAssertEqualObjects([info.currentRegistrationObject sourceToken], info.currentSourceInfo);
	}];
}

- (void)testMethodsRegistration_ClassMethods_ShouldAddMethodInfoToLastMethodGroupIfOneExists {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		XCTAssertEqual(lastMethodGroupMethods.count, 1ul);
		XCTAssertTrue([lastMethodGroupMethods.lastObject isMemberOfClass:([MethodInfo class])]);
	}];
}

- (void)testMethodsRegistration_ClassMethods_ShouldNotCreateNewMethodGroupIfNoneExists {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// verify
		XCTAssertEqual(info.interfaceMethodGroups.count, 0ul);
	}];
}

- (void)testMethodsRegistration_InstanceMethods_ShouldCreateNewMethodInfoAndAddItToInstanceMethodsArray {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		info.objectRegistrar = mock([Store class]);
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		XCTAssertEqual(info.interfaceInstanceMethods.count, 1ul);
		XCTAssertTrue([info.interfaceInstanceMethods.lastObject isMemberOfClass:([MethodInfo class])]);
		XCTAssertEqualObjects([info.interfaceInstanceMethods.lastObject methodType], GBStoreTypes.instanceMethod);
		XCTAssertEqualObjects([info.interfaceInstanceMethods.lastObject objectRegistrar], info.objectRegistrar);
	}];
}

- (void)testMethodsRegistration_InstanceMethods_ShouldPushMethodInfoToRegistrationStack {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:instanceOf([MethodInfo class])]);
	}];
}

- (void)testMethodsRegistration_InstanceMethods_ShouldSetSelfAsParentOfCreatedMethod {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// exexute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		XCTAssertEqualObjects([info.currentRegistrationObject memberParent], info);
	}];
}

- (void)testMethodsRegistration_InstanceMethods_ShouldSetCurrentSourceInfoToClass {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// setup
		info.currentSourceInfo = (PKToken *)@"dummy-source-info";
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		XCTAssertEqualObjects([info.currentRegistrationObject sourceToken], info.currentSourceInfo);
	}];
}

- (void)testMethodsRegistration_InstanceMethods_ShouldAddMethodInfoToLastMethodGroupIfNoneExists {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		XCTAssertEqual(lastMethodGroupMethods.count, 1ul);
		XCTAssertTrue([lastMethodGroupMethods.lastObject isMemberOfClass:([MethodInfo class])]);
	}];
}

- (void)testMethodsRegistration_InstanceMethods_ShouldNotCreateNewMethodGroupIfNoneExists {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		// execute
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// verify
		XCTAssertEqual(info.interfaceMethodGroups.count, 0ul);
	}];
}

#pragma mark - Object cancellation

- (void)testObjectCancellation_Properties_ShouldRemovePropertyInfoFromPropertiesArray {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// setup
		[info beginPropertyDefinition];
		// execute
		[info cancelCurrentObject];
		// verify
		XCTAssertEqual(info.interfaceProperties.count, 0ul);
	}];
}

- (void)testObjectCancellation_Properties_ShouldRemovePropertyInfoFromLastMethodGroup {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		[info beginPropertyDefinition];
		// execute
		[info cancelCurrentObject];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		XCTAssertEqual(lastMethodGroupMethods.count, 0ul);
	}];
}

- (void)testObjectCancellation_ClassMethods_ShouldremoveMethodInfoFromMethodsArray {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// setup
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// execute
		[info cancelCurrentObject];
		// verify
		XCTAssertEqual(info.interfaceClassMethods.count, 0ul);
	}];
}

- (void)testObjectCancellation_ClassMethods_ShouldRemoveMethodInfoFromLastMethodGroup {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		[info beginMethodDefinitionWithType:GBStoreTypes.classMethod];
		// execute
		[info cancelCurrentObject];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		XCTAssertEqual(lastMethodGroupMethods.count, 0ul);
	}];
}

- (void)testObjectCancellation_InstanceMethods_ShouldRemoveMethodInfoFromMethodsArray {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// setup
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// execute
		[info cancelCurrentObject];
		// verify
		XCTAssertEqual(info.interfaceInstanceMethods.count, 0ul);
	}];
}

- (void)testObjectCancellation_InstanceMethods_ShouldRemoveMethodInfoFromLastMethodGroup {
	[self runWithInterfaceInfoBaseWithRegistrar:^(InterfaceInfoBase *info, Store *store) {
		// setup
		[info appendMethodGroupWithDescription:@""];
		[info beginMethodDefinitionWithType:GBStoreTypes.instanceMethod];
		// execute
		[info cancelCurrentObject];
		// verify
		NSArray *lastMethodGroupMethods = [info.interfaceMethodGroups.lastObject methodGroupMethods];
		XCTAssertEqual(lastMethodGroupMethods.count, 0ul);
	}];
}

#pragma mark - Creator methods

- (void)runWithInterfaceInfoBase:(void(^)(InterfaceInfoBase *info))handler {
	InterfaceInfoBase *info = [[InterfaceInfoBase alloc] initWithRegistrar:nil];
	handler(info);
}

- (void)runWithInterfaceInfoBaseWithRegistrar:(void(^)(InterfaceInfoBase *info, Store *store))handler {
	[self runWithInterfaceInfoBase:^(InterfaceInfoBase *info) {
		Store *store = [[Store alloc] init];
		info.objectRegistrar = store;
		handler(info, store);
	}];
}

@end