//
//  TestCreators.h
//  appledoc
//
//  Created by Igor Biscanin on 19/02/14.
//  Copyright (c) 2014 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestCreators : NSObject

+ (id)classWithName:(NSString *)name;
+ (id)extensionOfClass:(NSString *)name;
+ (id)categoryOfClass:(NSString *)name category:(NSString *)category;
+ (id)protocolWithName:(NSString *)name;

@end
