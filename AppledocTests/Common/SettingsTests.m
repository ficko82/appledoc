//
//  SettingsTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "TestCaseBase.h"

@interface SettingsTests : XCTestCase
@end

@implementation SettingsTests

- (void)testInitializer_ShouldInitializeAllArrayKeys {
	// setup & execute
	GBSettings *settings = [GBSettings appledocSettingsWithName:@"name" parent:nil];
	// verify
	XCTAssertTrue([settings isKeyArray:GBOptions.inputPaths]);
	XCTAssertTrue([settings isKeyArray:GBOptions.ignoredPaths]);
}

#pragma mark - Cmd line switches

- (void)testCmdLineSwitches_ShouldWorkForProjectRelatedSettings {
	[self runWithSettings:^(GBSettings *settings) {
		// execute
		[settings setObject:@"1" forKey:GBOptions.projectName];
		[settings setObject:@"2" forKey:GBOptions.projectVersion];
		[settings setObject:@"3" forKey:GBOptions.companyName];
		[settings setObject:@"4" forKey:GBOptions.companyIdentifier];
		// verify
		XCTAssertEqualObjects(settings.projectName, @"1");
		XCTAssertEqualObjects(settings.projectVersion, @"2");
		XCTAssertEqualObjects(settings.companyName, @"3");
		XCTAssertEqualObjects(settings.companyIdentifier, @"4");
	}];
}

- (void)testCmdLineSwitches_ShouldWorkForPathRelatedSettings {
	[self runWithSettings:^(GBSettings *settings) {
		// execute
		[settings setObject:@"input" forKey:GBOptions.inputPaths];
		[settings setObject:@"ignore" forKey:GBOptions.ignoredPaths];
		[settings setObject:@"template" forKey:GBOptions.templatesPath];
		// verify
		XCTAssertTrue(settings.inputPaths.count == 1);
		XCTAssertEqualObjects(settings.inputPaths[0], @"input");
		XCTAssertTrue(settings.ignoredPaths.count == 1);
		XCTAssertEqualObjects(settings.ignoredPaths[0], @"ignore");
		XCTAssertEqualObjects(settings.templatesPath, @"template");
	}];
}

- (void)testCmdLineSwitches_ShouldWorkForCommentRelatedSettings {
	[self runWithSettings:^(GBSettings *settings) {
		// execute
		[settings setBool:YES forKey:GBOptions.searchMissingComments];
		[settings setObject:@"crossrefs" forKey:GBOptions.crossRefsFormat];
		// verify
		XCTAssertEqual(settings.searchForMissingComments, YES);
		XCTAssertEqualObjects(settings.crossRefsFormat, @"crossrefs");
	}] ;
}

- (void)testCmdLineSwitches_ShouldWorkForLoggingRelatedProperties {
	[self runWithSettings:^(GBSettings *settings) {
		// execute
		[settings setInteger:2 forKey:GBOptions.loggingFormat];
		[settings setInteger:3 forKey:GBOptions.loggingLevel];
		// verify
		XCTAssertTrue(settings.loggingFormat == 2);
		XCTAssertTrue(settings.loggingLevel == 3);
	}];
}

- (void)testCmdLineSwitches_ShouldWorkForDebuggingAidRelatedProperties {
	[self runWithSettings:^(GBSettings *settings) {
		// execute
		[settings setBool:YES forKey:GBOptions.printSettings];
		[settings setBool:YES forKey:GBOptions.printVersion];
		[settings setBool:YES forKey:GBOptions.printHelp];
		// verify
		XCTAssertEqual(settings.printSettings, YES);
		XCTAssertEqual(settings.printVersion, YES);
		XCTAssertEqual(settings.printHelp, YES);
	}];
}

#pragma mark - Creator methods

- (void)runWithSettings:(void(^)(GBSettings *settings))handler {
	GBSettings *settings = [GBSettings appledocSettingsWithName:@"name" parent:nil];
	handler(settings);
}

@end