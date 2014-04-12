//
//  ObjectiveCStateTestsHelpers.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <ParseKit/ParseKit.h>
#import "TestStrings.h"
#import "ObjectiveCStateTestsHelpers.h"
#import <OCMockito/OCMockito.h>

void runWithString(NSString *string, GBStateMockBlock handler) {
	ObjectiveCParser *parser = [ObjectiveCParser new];
	parser.tokenizer.string = string;
	TokensStream *tokens = [TokensStream tokensStreamWithTokenizer:parser.tokenizer];
	handler(parser, tokens);
}

void runWithFile(NSString *file, GBStateMockBlock handler) {
	NSString *string = [TestStrings stringFromResourceFile:file];
	runWithString(string, handler);
}

@implementation ObjectiveCStateTestsHelpers

+ (void)runWithString:(NSString *)string block:(GBStateMockBlock)handler {
	ObjectiveCParser *parser = [ObjectiveCParser new];
	parser.tokenizer.string = string;
	TokensStream *tokens = [TokensStream tokensStreamWithTokenizer:parser.tokenizer];
	handler(parser, tokens);
}

+ (void)runWithFile:(NSString *)file block:(GBStateMockBlock)handler {
	NSString *string = [TestStrings stringFromResourceFile:file];
	runWithString(string, handler);
}

@end
