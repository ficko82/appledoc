//
//  CommentInfoTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 8/22/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCaseBase.h"

@interface CommentInfoTests : XCTestCase
@end

@implementation CommentInfoTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithCommentInfo:^(CommentInfo *info) {
		// execute & verify
		XCTAssertNotNil(info.commentParameters);
		XCTAssertNotNil(info.commentExceptions);
	}];
}

#pragma mark - Helper methods

- (void)testHelperMethods_CommentAbstract_ShouldDetectThatAbstractIsNotRegistered {
	[self runWithCommentInfo:^(CommentInfo *info) {
		// execute & verify
		XCTAssertEqual(info.isCommentAbstractRegistered, NO);
	}];
}

- (void)testHelperMethods_CommentAbstract_ShouldDetectThatAbstractIsRegistered {
	[self runWithCommentInfo:^(CommentInfo *info) {
		// setup
		info.commentAbstract = [[CommentComponentInfo alloc] init];
		// execute & verify
		XCTAssertEqual(info.isCommentAbstractRegistered, YES);
	}];
}

#pragma mark - Creator method

- (void)runWithCommentInfo:(void(^)(CommentInfo *info))handler {
	CommentInfo *info = [[CommentInfo alloc] init];
	handler(info);
}

@end