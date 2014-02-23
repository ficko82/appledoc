//
//  PropertyInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface PropertyInfoTests : XCTestCase
@end

@implementation PropertyInfoTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// execute & verify
		XCTAssertTrue([info.propertyType isMemberOfClass:([TypeInfo class])]);
		XCTAssertTrue([info.propertyAttributes isMemberOfClass:([AttributesInfo class])]);
		XCTAssertTrue([info.propertyDescriptors isMemberOfClass:([DescriptorsInfo class])]);
	}];
}

#pragma mark - Method and property info

- (void)testMethodAndPropertyInfo_ShouldReturnYesForPropertyAndNoForMethod {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// execute & verify
		XCTAssertEqual(info.isProperty, YES);
		XCTAssertEqual(info.isClassMethod, NO);
		XCTAssertEqual(info.isInstanceMethod, NO);
	}];
}

#pragma mark - Getter and setter selectors
							  
- (void)testGetterAndSetterSelectors_ShouldReturnDefaultNameIfNoAttributeIsGiven {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		info.propertyName = @"name";
		// execute & verify
		XCTAssertEqualObjects(info.propertyGetterSelector, @"name");
		XCTAssertEqualObjects(info.propertySetterSelector, @"setName:");
	}];
}
							  
- (void)testGetterAndSetterSelectors_ShouldReturnValueFromAttributesIfBothAreGiven {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		info.propertyName = @"name";
		info.propertyAttributes.attributeItems = [NSMutableArray arrayWithObjects:@"getter", @"=", @"isName", @"setter", @"=", @"setNewName", nil];
		// execute & verify
		XCTAssertEqualObjects(info.propertyGetterSelector, @"isName");
		XCTAssertEqualObjects(info.propertySetterSelector, @"setNewName:");
	}];
}
	
- (void)testGetterAndSetterSelectors_ShouldReturnCustomGetterValueAndRevertToDefaultSetterIfOnlyGetterIsSpecified {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		info.propertyName = @"name";
		info.propertyAttributes.attributeItems = [NSMutableArray arrayWithObjects:@"getter", @"=", @"isName", nil];
		// execute & verify
		XCTAssertEqualObjects(info.propertyGetterSelector, @"isName");
		XCTAssertEqualObjects(info.propertySetterSelector, @"setName:");
	}];
}
							  
- (void)testGetterAndSetterSelectors_ShouldReturnCustomSetterValueAndRevertToDefaultGetterIfOnlySetterIsSpecified {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		info.propertyName = @"name";
		info.propertyAttributes.attributeItems = [NSMutableArray arrayWithObjects:@"setter", @"=", @"setNewName", nil];
		// execute & verify
		XCTAssertEqualObjects(info.propertyGetterSelector, @"name");
		XCTAssertEqualObjects(info.propertySetterSelector, @"setNewName:");
	}];
}
							  
#pragma mark - UniqueIdAndCrossReferenceTemplate
							  
- (void)testUniqueIdAndCrossReferenceTemplate_ShouldReturnPropertyName {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		info.propertyName = @"name";
		// execute & verify
		XCTAssertEqualObjects(info.uniqueObjectID, @"name");
		XCTAssertEqualObjects(info.objectCrossRefPathTemplate, @"#name");
	}];
}

#pragma mark - Property descriptors registration
							  
- (void)testPropertyDescriptorsRegistration_ShouldPushDescriptorsInfoToRegistrationStack {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginPropertyDescriptors];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:info.propertyDescriptors]);
	}];
}

#pragma mark - Property attributes registration
	 
- (void)testPropertyAttributesRegistration_ShouldPushAttributesInfoToRegistrationStack {
	 [self runWithPropertyInfo:^(PropertyInfo *info) {
		 // setup
		 id mock = mock([Store class]);
		 info.objectRegistrar = mock;
		 // execute
		 [info beginPropertyAttributes];
		 // verify
		 XCTAssertNoThrow([verify(mock) pushRegistrationObject:info.propertyAttributes]);
	 }];
}
	 
#pragma mark - Property types registration
	 
- (void)testPropertyTypesRegistration_ShouldPushPropertyTypeInfoToRegistrationStack {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// setup
		id mock = mock([Store class]);
		info.objectRegistrar = mock;
		// execute
		[info beginPropertyTypes];
		// verify
		XCTAssertNoThrow([verify(mock) pushRegistrationObject:info.propertyType]);
	 }];
}

#pragma mark - Property name registration
	 
- (void)testPropertyNameRegistration_ShouldAssignGivenString {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		// execute
		[info appendPropertyName:@"value"];
		// verify
		XCTAssertEqualObjects(info.propertyName, @"value");
	}];
}
	 
- (void)testPropertyNameRegistration_ShouldUseLastValueIfSentMultipleTimes {
	[self runWithPropertyInfo:^(PropertyInfo *info) {
		 // execute
		 [info appendPropertyName:@"value1"];
		 [info appendPropertyName:@"value2"];
		 // verify
		 XCTAssertEqualObjects(info.propertyName, @"value2");
	}];
}

#pragma mark - Creator method
	 
- (void)runWithPropertyInfo:(void(^)(PropertyInfo *info))handler {
	PropertyInfo *info = [[PropertyInfo alloc] init];
	handler(info);
}

@end