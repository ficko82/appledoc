//
//  ObjectiveCParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCFileState.h"
#import "ObjectiveCInterfaceState.h"
#import "ObjectiveCPropertyState.h"
#import "ObjectiveCMethodState.h"
#import "ObjectiveCPragmaMarkState.h"
#import "ObjectiveCEnumState.h"
#import "ObjectiveCStructState.h"
#import "ObjectiveCConstantState.h"
#import "ObjectiveCParser.h"
#import "CommentParser.h"
#import "TestCaseBase.h"

@interface ObjectiveCParser (UnitTestingPrivateAPI)
@property (nonatomic, strong, readwrite) Store *store;
@property (nonatomic, strong, readwrite) GBSettings *settings;
@property (nonatomic, strong, readwrite) NSString *filename;
@property (nonatomic, strong) CommentParser *commentParser;
@end

@interface ObjectiveCParserTests : XCTestCase
@end

@implementation ObjectiveCParserTests

#pragma mark - Lazy accessors

- (void)testLazyAccessors_ShouldInitializeObjects {
	[self runWithParser:^(ObjectiveCParser *parser) {
		// execute & verify
		XCTAssertTrue([parser.fileState isMemberOfClass:([ObjectiveCFileState class])]);
		XCTAssertTrue([parser.interfaceState isMemberOfClass:([ObjectiveCInterfaceState class])]);
		XCTAssertTrue([parser.propertyState isMemberOfClass:([ObjectiveCPropertyState class])]);
		XCTAssertTrue([parser.methodState isMemberOfClass:([ObjectiveCMethodState class])]);
		XCTAssertTrue([parser.pragmaMarkState isMemberOfClass:([ObjectiveCPragmaMarkState class])]);
		XCTAssertTrue([parser.enumState isMemberOfClass:([ObjectiveCEnumState class])]);
		XCTAssertTrue([parser.structState isMemberOfClass:([ObjectiveCStructState class])]);
		XCTAssertTrue([parser.constantState isMemberOfClass:([ObjectiveCConstantState class])]);
		XCTAssertTrue([parser.tokenizer isMemberOfClass:([PKTokenizer class])]);
		XCTAssertTrue([parser.commentParser isMemberOfClass:([CommentParser class])]);
	}];
}

#pragma mark - Comments parsing

- (void)testCommentsParsing_MethodGroups_ShouldAppendMethodGroupFromSingleLineComment {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/// @name name of group"];
		// verify
		XCTAssertNoThrow([verify(store) appendMethodGroupWithDescription:@"name of group"]);
	}];
}

- (void)testCommentsParsing_MethodGroups_ShouldAppendMethodGroupFromMultiLineComment {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/** @name name of group */"];
		// verify
		XCTAssertNoThrow([verify(store) appendMethodGroupWithDescription:@"name of group"]);
	}];
}

- (void)testCommentsParsing_CommentBeforeObjects_SingleLineComments_ShouldIgnoreStandardComments {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute - this will raise exception if anything gets registered to store due to using strict mock!
		XCTAssertNoThrow([parser parseString:@"// comment"]);
	}];

}
			
- (void)testCommentsParsing_CommentBeforeObjects_SingleLineComments_ShouldRegisterOneLineCommentToStore {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/// comment"];
		// verify
		XCTAssertNoThrow([verify(store) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"comment"]);
	}];
}

- (void)testCommentsParsing_CommentBeforeObjects_SingleLineComments_ShouldGroupSuccessiveLinesTogether {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/// line1\n/// line2\n/// line3"];
		// verify
		XCTAssertNoThrow([verify(store) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"line1\nline2\nline3"]);
	}];
}

- (void)testCommentsParsing_CommentBeforeObjects_SingleLineComments_ShouldRegisterSuccessiveComments {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/// line1\n/// line2\n\n/// line3\n/// line4"];
		// verify
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"line1\nline2"]);
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"line3\nline4"]);
	}];
}

- (void)testCommentsParsing_CommentBeforeObjects_MultiLineComments_ShouldIgnoreStandardComments {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		XCTAssertNoThrow([parser parseString:@"/* comment */"]);
	}];
}

- (void)testCommentsParsing_CommentBeforeObjects_MultiLineComments_ShouldRegisterSingleCommentToStore {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/** comment*/"];
		// verify
		XCTAssertNoThrow([verify(store) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"comment"]);
	}];
}

- (void)testCommentsParsing_CommentBeforeObjects_MultiLineComments_ShouldRegisterSuccessiveCommentToStore {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/** line1\n line2*/\n/** line3\n line4*/"];
		// verify
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"line1\nline2"]);
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"line3\nline4"]);
	}];
}

- (void)testCommentsParsing_InlineComments_SingleLineComments_ShouldIgnoreStandardComment {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute - this will raise exception if anything is registered to store due to using strict mock!
		XCTAssertNoThrow([parser parseString:@"//< comment"]);
	}];
}

- (void)testCommentsParsing_InlineComments_SingleLineComments_ShouldRegisterOneLineCommentToStore {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"///< comment"];
		// verify
		XCTAssertNoThrow([verify(store) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToPreviousObject:@"comment"]);
	}];
}

- (void)testCommentsParsing_InlineComments_SingleLineComments_ShouldGroupSuccessiveLinesTogether {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/// line1\n/// line2\n/// line3"];
		// verify
		XCTAssertNoThrow([verify(store) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"line1\nline2\nline3"]);
	}];
}

- (void)testCommentsParsing_InlineComments_SingleLineComments_ShouldRegisterSuccessiveComments {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"///< line1\n/// line2\n\n///< line3\n/// line4"];
		// verify
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToPreviousObject:@"line1\nline2"]);
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToPreviousObject:@"line3\nline4"]);
	}];
}

- (void)testCommentsParsing_InlineComments_MultiLineComments_ShouldIgnoreStandardComments {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute - this will raise exception if anything is registered to store due to using strict mock!
		XCTAssertNoThrow([parser parseString:@"/*< comment */"]);
	}];
}

- (void)testCommentsParsing_InlineComments_MultiLineComments_ShouldRegisterSingleCommentToStore {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/**< comment*/"];
		// verify
		XCTAssertNoThrow([verify(store) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToPreviousObject:@"comment"]);
	}];
}

- (void)testCommentsParsing_InlineComments_MultiLineComments_ShouldRegisterSuccessiveCommentToStore {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/**< line1\n line2*/\n/**< line3\n line4*/"];
		// verify
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToPreviousObject:@"line1\nline2"]);
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToPreviousObject:@"line3\nline4"]);
	}];
}

- (void)testCommentsParsing_MixedCases_ShouldRegisterPreviousAndNextSingleLineComment {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"///< line1\n/// line2\n\n/// line3\n/// line4"];
		// verify
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToPreviousObject:@"line1\nline2"]);
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"line3\nline4"]);
	}];
}

- (void)testCommentsParsing_MixedCases_ShouldRegisterPreviousAndNextMultiLineComment {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"/**< line1\nline2*/\n/** line3\nline4*/"];
		// verify
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToPreviousObject:@"line1\nline2"]);
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"line3\nline4"]);
	}];
}

- (void)testCommentsParsing_MixedCases_ShouldHandleProbablyTheMostCommonCase {
	[self runWithStrictParser:^(ObjectiveCParser *parser, id store, id settings) {
		// execute
		[parser parseString:@"///< line1\n/// line2\n\n/** line3\n line4*/"];
		// verify
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToPreviousObject:@"line1\nline2"]);
		XCTAssertNoThrow([verifyCount(store, times(2)) setCurrentSourceInfo:anything()]);
		XCTAssertNoThrow([verify(store) appendCommentToNextObject:@"line3\nline4"]);
	}];
}

#pragma mark - Creator methods

- (void)runWithParser:(void(^)(ObjectiveCParser *parser))handler {
	ObjectiveCParser *parser = [[ObjectiveCParser alloc] init];
	handler(parser);
}

- (void)runWithStrictParser:(void(^)(ObjectiveCParser *parser, id store, id settings))handler {
	[self runWithParser:^(ObjectiveCParser *parser) {
		parser.filename = @"file.h";
		parser.store = mock([Store class]);
		parser.settings = mock([GBSettings class]);
		handler(parser, parser.store, parser.settings);
	}];
}

@end