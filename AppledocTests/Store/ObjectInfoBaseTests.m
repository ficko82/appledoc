//
//  ObjectInfoBaseTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"
#import "TestCaseBase.h"

@implementation ObjectInfoBaseTests

- (void)testPushObjectToRegistrationStack_ShouldForwardRequestToAssignedStoreRegistrar {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id child = @"child";
		id registrar = mockProtocol(@protocol(StoreRegistrar));
		info.objectRegistrar = registrar;
		// execute
		[info pushRegistrationObject:child];
		// verify
		XCTAssertNoThrow([verify(registrar) pushRegistrationObject:child]);
	}];
}

- (void)testPopObjectFromRegistrationstack_ShouldForwardRequestToAssignedStoreRegistrar {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id child = @"child";
		id registrar = mockProtocol(@protocol(StoreRegistrar));
		info.objectRegistrar = registrar;
		// execute
		[info popRegistrationObject];
		// verify
		XCTAssertNoThrow([verify(registrar) popRegistrationObject]);
	}];
}

- (void)testCurrentRegistrationObject_ShouldForwardRequestToAssignedStoreRegistrar {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id child = @"child";
		id registrar = mockProtocol(@protocol(StoreRegistrar));
		info.objectRegistrar = registrar;
		// execute
		[info currentRegistrationObject];
		// verify
		XCTAssertNoThrow([verify(registrar) currentRegistrationObject]);
	}];
}

- (void)testExpectCurrentRegistrationObjectRespondTo_ShouldForwardRequestToAssignedStoreRegistrar {
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id registrar = mockProtocol(@protocol(StoreRegistrar));
		info.objectRegistrar = registrar;
		// execute
		[info expectCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
		// verify
		XCTAssertNoThrow([verify(registrar) expectCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)]);
	}];
}

- (void)testIfCurrentRegistrationObjectDoesRespondTo__ShouldForwardRequestToAssignedStoreRegistrar{
	[self runWithObjectInfoBase:^(ObjectInfoBase *info) {
		// setup
		id registrar = mockProtocol(@protocol(StoreRegistrar));
		info.objectRegistrar = registrar;
		// execute
		[info doesCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)];
		// verify
		XCTAssertNoThrow([verify(registrar) doesCurrentRegistrationObjectRespondTo:@selector(currentRegistrationObject)]);
	}];
}

#pragma mark - Creator method

- (void)runWithObjectInfoBase:(void(^)(ObjectInfoBase *info))handler {
	ObjectInfoBase *info = [[ObjectInfoBase alloc] init];
	handler(info);
}

@end
