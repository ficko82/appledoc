//
//  CommentParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 6/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "Extensions.h"
#import "CommentParser.h"
#import "TestCaseBase.h"

@interface ParserRegistratorMock : NSObject
- (id)initWithParser:(CommentParser *)parser;
@property (nonatomic, copy) NSString *groupComment;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, assign) BOOL isCommentInline;
@end

@implementation ParserRegistratorMock
@synthesize groupComment, comment, isCommentInline;
- (id)initWithParser:(CommentParser *)parser {
	self = [super init];
	if (self) {
		__weak ParserRegistratorMock *blockSelf = self;
		parser.groupRegistrator = ^(CommentParser *parser, NSString *group) {
			blockSelf.groupComment = group;
		};
		parser.commentRegistrator = ^(CommentParser *parser, NSString *comment, BOOL isInline) {
			blockSelf.comment = comment;
			blockSelf.isCommentInline = isInline;
		};
	}
	return self;
}
@end

@interface CommentParserTests : XCTestCase
@end

@implementation CommentParserTests

#pragma mark - Detecting appledoc comments

- (void)testDetectingAppledocComments_SingleLine_ShouldAcceptTripleSlashPrefixedString {
	[self runWithParser:^(CommentParser *parser) {
		// execute & verify
		XCTAssertEqual([parser isAppledocComment:@"/// text"], YES);
	}];
}

- (void)testDetectingAppledocComments_SingleLine_ShouldRejectDoubleSlashPrefixedLine {
	[self runWithParser:^(CommentParser *parser) {
		// execute & verify
		XCTAssertEqual([parser isAppledocComment:@"// text"], NO);
	}];
}

- (void)testDetectingAppledocComments_MultiLine_ShouldAcceptSlashDoubleAsterixPrefixedString {
	[self runWithParser:^(CommentParser *parser) {
		// execute & verify
		XCTAssertEqual([parser isAppledocComment:@"/** text"], YES);
	}];
}

- (void)testDetectingAppledocComments_MultiLine_ShouldRejectSlashSingleAsterixPrefixedString {
	[self runWithParser:^(CommentParser *parser) {
		// execute & verify
		XCTAssertEqual([parser isAppledocComment:@"/* text"], NO);
	}];
}

- (void)testDetectingAppledocComments_EdgeCases_ShouldRejectSingleLinePrefixedWithWhitespace {
	[self runWithParser:^(CommentParser *parser) {
		// execute & verify
		XCTAssertEqual([parser isAppledocComment:@" /// text"], NO);
	}];
}

- (void)testDetectingAppledocComments_EdgeCases_ShouldRejectMultiLinePrefixedWithWhitespace {
	[self runWithParser:^(CommentParser *parser) {
		// execute & verify
		XCTAssertEqual([parser isAppledocComment:@" /** text"], NO);
	}];
}

#pragma mark - Parsing method groups

- (void)testParsingMethodGroups_SimpleCases_ShouldDetectGroupInSingleLiner {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/// @name name" line:1];
		// verify
		XCTAssertEqualObjects(registrator.groupComment, @"name");
		XCTAssertNil(registrator.comment);
	}];
}

- (void)testParsingMethodGroups_SimpleCases_ShouldDetectGroupInMultiLiner {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/** @name name */" line:1];
		// verify
		XCTAssertEqualObjects(registrator.groupComment, @"name");
		XCTAssertNil(registrator.comment);
	}];
}

- (void)testParsingMethodGroups_Trimming_ShouldDetectMultiWordGroupName {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/// @name word1 word2" line:1];
		// verify
		XCTAssertEqualObjects(registrator.groupComment, @"word1 word2");
		XCTAssertNil(registrator.comment);
	}];
}

- (void)testParsingMethodGroups_Trimming_ShouldTrimWhitespaceInsideGroupName {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/// @name word1  word2 \t word3" line:1];
		// verify
		XCTAssertEqualObjects(registrator.groupComment, @"word1 word2 word3");
		XCTAssertNil(registrator.comment);
	}];
}

#pragma mark - Mixing group with comment

- (void)testMixingGroupWithComment_ShouldTakeAnyTextAfterGroupLineAsComment {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/** @name name\nhello*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.groupComment, @"name");
		XCTAssertEqualObjects(registrator.comment, @"hello");
	}];
}

- (void)testMixingGroupWithComment_ShouldTakeAsCommentIfAfnaNameIsFoundAfterSomeText {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**hello @name name*/" line:1];
		// verify
		XCTAssertNil(registrator.groupComment);
		XCTAssertEqualObjects(registrator.comment, @"hello @name name");
	}];
}

#pragma mark - Parsing comments

- (void)testParsingComments_SingleLine_ShouldDetectOneLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"///text" line:1];
		[parser notifyAndReset];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"text");
	}];
}

- (void)testParsingComments_SingleLine_ShouldAppendMultipleLines {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"///line1" line:1];
		[parser parseComment:@"///line2" line:2];
		[parser parseComment:@"///line3" line:3];
		[parser notifyAndReset];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2\nline3");
	}];
}

- (void)testParsingComments_SingleLine_ShouldKeepInBetweenEmptyLines {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"///line1" line:1];
		[parser parseComment:@"///" line:2];
		[parser parseComment:@"///line3" line:3];
		[parser notifyAndReset];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\n\nline3");
	}];
}

- (void)testParsingComments_SingleLine_ShouldNotifyAndResetIfDelimitedByAtLeastOneNonCommentLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"///line1" line:1];
		[parser parseComment:@"///line2" line:2];
		[parser parseComment:@"///line3" line:4];
		[parser notifyAndReset];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line3");
	}];
}

- (void)testParsingComments_MultipleLines_ShouldDetectOneLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**text*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"text");
	}];
}

- (void)testParsingComments_MultipleLines_ShouldDetectMultipleLines {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**line1\nline2\nline3*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2\nline3");
	}];
}

#pragma mark - Trimming

- (void)testTrimming_SingleLine_ShouldHandleNoPrefix {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**text*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"text");
	}];
}

- (void)testTrimming_SingleLine_ShouldTrimmSpacePrefix {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/** text*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"text");
	}];
}

- (void)testTrimming_SingleLine_ShouldTrimOnlySingleSpacePrefix {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**   text*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"  text");
	}];
}

- (void)testTrimming_SingleLine_ShouldKeepTabPrefix {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**\ttext*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"\ttext");
	}];
}

- (void)testTrimming_SingleLine_ShouldKeepTabPrefixButRemoveSingleSpacePrefix {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**  \ttext*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @" \ttext");
	}];
}

- (void)testTrimming_MultipleLines_ShouldTrimSpacePrefix {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/** line1\n line2\n line3*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2\nline3");
	}];
}

- (void)testTrimming_MultipleLines_ShouldTrimOnlySingleSpacePrefixFromEachLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**   line1\n line2\n  line3*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"  line1\nline2\n line3");
	}];
}

- (void)testTrimming_MultipleLines_ShouldKeepInBetweenNewLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**line1\n\nline2\nline3*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\n\nline2\nline3");
	}];
}

- (void)testTrimming_MultipleLines_ShouldIgnorePrefixNewLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**\nline1\nline2\nline3*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2\nline3");
	}];
}

- (void)testTrimming_MultipleLines_ShouldIgnoreTrailingNewLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**line1\nline2\nline3\n*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2\nline3");
	}];
}

#pragma mark - Inline comments

- (void)testInlineComments_SingleLiners_ShouldDetectWithOneLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"///< comment" line:1];
		[parser notifyAndReset];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"comment");
		XCTAssertEqual(registrator.isCommentInline, YES);
	}];
}

- (void)testInlineComments_SingleLiners_ShouldDetectMultiLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"///< line1" line:1];
		[parser parseComment:@"///< line2" line:2];
		[parser notifyAndReset];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2");
		XCTAssertEqual(registrator.isCommentInline, YES);
	}];
}

- (void)testInlineComments_SingleLiners_ShouldDetectMultiLineWithMarkerInFirstLineOnly {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"///< line1" line:1];
		[parser parseComment:@"/// line2" line:2];
		[parser notifyAndReset];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2");
		XCTAssertEqual(registrator.isCommentInline, YES);
	}];
}

- (void)testInlineComments_SingleLiners_ShouldIgnoreIfMarkerNotInFirstLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/// line1" line:1];
		[parser parseComment:@"///< line2" line:2];
		[parser notifyAndReset];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\n< line2");
		XCTAssertEqual(registrator.isCommentInline, NO);
	}];
}

- (void)testInlineComments_SingleLiners_ShouldIgnoreIfNoMarker {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/// line1" line:1];
		[parser parseComment:@"/// line2" line:2];
		[parser notifyAndReset];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2");
		XCTAssertEqual(registrator.isCommentInline, NO);
	}];
}

- (void)testInlineComments_MultiLiners_ShouldDetectWithOneLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**< comment*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"comment");
		XCTAssertEqual(registrator.isCommentInline, YES);
	}];
}

- (void)testInlineComments_MultiLiners_ShouldDetectMultiLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**< line1\n< line2*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2");
		XCTAssertEqual(registrator.isCommentInline, YES);
	}];
}

- (void)testInlineComments_MultiLiners_ShouldDetectWithMultiLineWithMarkerInFirstLineOnly {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**< line1\n line2*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2");
		XCTAssertEqual(registrator.isCommentInline, YES);
	}];
}

- (void)testInlineComments_MultiLiners_ShouldIgnoreIfMarkerNotInFirstLine {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/** line1\n< line2*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\n< line2");
		XCTAssertEqual(registrator.isCommentInline, NO);
	}];
}

- (void)testInlineComments_MultiLiners_ShouldIgnoreIfMarkerMissing {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/** line1\n line2*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.comment, @"line1\nline2");
		XCTAssertEqual(registrator.isCommentInline, NO);
	}];
}

- (void)testInlineComments_EdgeCases_ShouldIgnoreGroup {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/**< @name name*/" line:1];
		// verify
		XCTAssertNil(registrator.groupComment);
		XCTAssertEqualObjects(registrator.comment, @"@name name");
		XCTAssertEqual(registrator.isCommentInline, YES);
	}];
}

- (void)testInlineComments_EdgeCases_ShouldDetectGroupAndInline {
	[self runWithRegistrator:^(CommentParser *parser, ParserRegistratorMock *registrator) {
		// execute
		[parser parseComment:@"/** @name name\n< comment*/" line:1];
		// verify
		XCTAssertEqualObjects(registrator.groupComment, @"name");
		XCTAssertEqualObjects(registrator.comment, @"comment");
		XCTAssertEqual(registrator.isCommentInline, YES);
	}];
}

#pragma mark - Creator methods

- (void)runWithParser:(void(^)(CommentParser *parser))handler {
	CommentParser *parser = [[CommentParser alloc] init];
	handler(parser);
}

- (void)runWithRegistrator:(void(^)(CommentParser *parser, ParserRegistratorMock *registrator))handler {
	[self runWithParser:^(CommentParser *parser) {
		ParserRegistratorMock *registrator = [[ParserRegistratorMock alloc] initWithParser:parser];
		handler(parser, registrator);
	}];
}

@end