//
//  TestCreators.m
//  appledoc
//
//  Created by Igor Biscanin on 19/02/14.
//  Copyright (c) 2014 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TestCreators.h"

@implementation TestCreators

+ (id)classWithName:(NSString *)name {
	ClassInfo *result = [[ClassInfo alloc] init];
	result.nameOfClass = name;
	return result;
}

+ (id)extensionOfClass:(NSString *)name {
	CategoryInfo *result = [[CategoryInfo alloc] init];
	result.categoryClass.nameOfObject = name;
	result.nameOfCategory = @"";
	return result;
}

+ (id)categoryOfClass:(NSString *)name category:(NSString *)category {
	CategoryInfo *result = [[CategoryInfo alloc] init];
	result.categoryClass.nameOfObject = name;
	result.nameOfCategory = category;
	return result;
}

+ (id)protocolWithName:(NSString *)name {
	ProtocolInfo *result = [[ProtocolInfo alloc] init];
	result.nameOfProtocol = name;
	return result;
}

@end
