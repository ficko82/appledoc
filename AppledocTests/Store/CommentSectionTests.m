//
//  CommentNamedSectionInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 11/1/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface CommentNamedSectionInfoTests : XCTestCase
@end

@implementation CommentNamedSectionInfoTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithCommentNamedSectionInfo:^(CommentSectionInfo *info) {
		// execute & verify
		XCTAssertNotNil(info.sectionComponents);
	}];
}

#pragma mark - Creator method

-(void)runWithCommentNamedSectionInfo:(void(^)(CommentSectionInfo *info))handler {
	CommentSectionInfo *info = [[CommentSectionInfo alloc] init];
	handler(info);
}

@end