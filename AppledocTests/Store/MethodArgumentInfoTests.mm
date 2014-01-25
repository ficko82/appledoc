//
//  MethodArgumentInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/*
#import "Store.h"
#import "TestCaseBase.hh"

static void runWithMethodArgumentInfo(void(^handler)(MethodArgumentInfo *info)) {
	MethodArgumentInfo *info = [[MethodArgumentInfo alloc] init];
	handler(info);
	[info release];
}

#pragma mark - 

TEST_BEGIN(MethodArgumentInfoTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithMethodArgumentInfo(^(MethodArgumentInfo *info) {
			// execute & verify
			info.argumentType should be_instance_of([TypeInfo class]);
		});
	});
});

describe(@"method argument types registration:", ^{
	it(@"should push argument type to registration stack", ^{
		runWithMethodArgumentInfo(^(MethodArgumentInfo *info) {
			// setup
			id mock = mock([Store class]);
			info.objectRegistrar = mock;
			// execute
			[info beginMethodArgumentTypes];
			// verify
			gbcatch([verify(mock) pushRegistrationObject:info.argumentType]);
		});
	});
});

describe(@"method argument selector registration:", ^{
	it(@"should assign given string", ^{
		runWithMethodArgumentInfo(^(MethodArgumentInfo *info) {
			// execute
			[info appendMethodArgumentSelector:@"value"];
			// verify
			info.argumentSelector should equal(@"value");
		});
	});
	
	it(@"should use last value if sent multiple times", ^{
		runWithMethodArgumentInfo(^(MethodArgumentInfo *info) {
			// execute
			[info appendMethodArgumentSelector:@"value1"];
			[info appendMethodArgumentSelector:@"value2"];
			// verify
			info.argumentSelector should equal(@"value2");
		});
	});
});

describe(@"method argument variable registration:", ^{
	it(@"should assign given string", ^{
		runWithMethodArgumentInfo(^(MethodArgumentInfo *info) {
			// execute
			[info appendMethodArgumentVariable:@"value"];
			// verify
			info.argumentVariable should equal(@"value");
		});
	});
	
	it(@"should use last value if sent multiple times", ^{
		runWithMethodArgumentInfo(^(MethodArgumentInfo *info) {
			// execute
			[info appendMethodArgumentVariable:@"value1"];
			[info appendMethodArgumentVariable:@"value2"];
			// verify
			info.argumentVariable should equal(@"value2");
		});
	});
});

describe(@"helper methods:", ^{
	describe(@"is using variable:", ^{
		it(@"should return yes if type is registered", ^{
			runWithMethodArgumentInfo(^(MethodArgumentInfo *info) {
				// setup
				[info beginMethodArgumentTypes];
				// execute & verify
				info.isUsingVariable should be_truthy();
			});
		});

		it(@"should return yes if variable", ^{
			runWithMethodArgumentInfo(^(MethodArgumentInfo *info) {
				// setup
				[info appendMethodArgumentVariable:@"var"];
				// execute & verify
				info.isUsingVariable should be_truthy();
			});
		});

		it(@"should return no if type and variable are missing", ^{
			runWithMethodArgumentInfo(^(MethodArgumentInfo *info) {
				// execute & verify
				info.isUsingVariable should_not be_truthy();;
			});
		});
	});
});

TEST_END
*/