//
//  Processor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "LinkKnownObjectsTask.h"
#import "MergeKnownObjectsTask.h"
#import "FetchDocumentationTask.h"
#import "SplitCommentToSectionsTask.h"
#import "RegisterCommentComponentsTask.h"
#import "DetectCrossReferencesTask.h"
#import "Processor.h"

@implementation Processor

#pragma mark - Task invocation

- (NSInteger)runTask {
	LogNormal(@"Processing...");
	GBResult result = GBResultOk;
	GB_PROCESS([self.linkKnownObjectsTask runTask]);
	GB_PROCESS([self.mergeKnownObjectsTask runTask]);
	GB_PROCESS([self.fetchDocumentationTask runTask]);
	GB_PROCESS([self processInterfaces:self.store.storeClasses]);
	GB_PROCESS([self processInterfaces:self.store.storeExtensions]);
	GB_PROCESS([self processInterfaces:self.store.storeCategories]);
	GB_PROCESS([self processInterfaces:self.store.storeProtocols]);
	LogDebug(@"Processing finished.");
	return result;
}

#pragma mark - Processor helpers

- (NSInteger)processInterfaces:(NSArray *)interfaces {
	LogDebug(@"Processing %lu...", (unsigned long)interfaces.count);
	__weak Processor *bself = self;
	__block NSInteger result = GBResultOk;
	[interfaces enumerateObjectsUsingBlock:^(InterfaceInfoBase *info, NSUInteger idx, BOOL *stop) {
		GB_PROCESS([bself processInterface:info]);
	}];
	return result;
}

- (NSInteger)processInterface:(InterfaceInfoBase *)interface {
	LogNormal(@"%@", interface);
	NSInteger result = GBResultOk;
	[self processCommentForObject:interface context:interface];
	GB_PROCESS([self processMembers:interface.interfaceClassMethods forObject:interface]);
	GB_PROCESS([self processMembers:interface.interfaceInstanceMethods forObject:interface]);
	GB_PROCESS([self processMembers:interface.interfaceProperties forObject:interface]);
	return result;
}

- (NSInteger *)processMembers:(NSArray *)members forObject:(InterfaceInfoBase *)object {
	__weak Processor *blockSelf = self;
	__block NSInteger result = GBResultOk;
	[members enumerateObjectsUsingBlock:^(ObjectInfoBase *member, NSUInteger idx, BOOL *stop) {
		LogDebug(@"Processing %@...", member);
		[blockSelf processCommentForObject:member context:object];
	}];
	return result;
}

- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)context {
	if (!object.comment) return GBResultOk;
	LogDebug(@"Processing comment for %@", object);
	NSInteger result = GBResultOk;
	GB_PROCESS([self.splitCommentToSectionsTask processCommentForObject:object context:context]);
	GB_PROCESS([self.registerCommentComponentsTask processCommentForObject:object context:context]);
	GB_PROCESS([self.detectCrossReferencesTask processCommentForObject:object context:context]);
	return result;
}

#pragma mark - Lazy loading properties

- (ProcessorTask *)linkKnownObjectsTask {
	if (_linkKnownObjectsTask) return _linkKnownObjectsTask;
	LogDebug(@"Initializing link known objects task due to first access...");
	_linkKnownObjectsTask = [[LinkKnownObjectsTask alloc] initWithStore:self.store settings:self.settings];
	return _linkKnownObjectsTask;
}

- (ProcessorTask *)mergeKnownObjectsTask {
	if (_mergeKnownObjectsTask) return _mergeKnownObjectsTask;
	LogDebug(@"Initializing merge known objects task due to first access...");
	_mergeKnownObjectsTask = [[MergeKnownObjectsTask alloc] initWithStore:self.store settings:self.settings];
	return _mergeKnownObjectsTask;
}

- (ProcessorTask *)fetchDocumentationTask {
	if (_fetchDocumentationTask) return _fetchDocumentationTask;
	LogDebug(@"Initializing fetch documentation task due to first access...");
	_fetchDocumentationTask = [[FetchDocumentationTask alloc] initWithStore:self.store settings:self.settings];
	return _fetchDocumentationTask;
}

- (ProcessorCommentTask *)splitCommentToSectionsTask {
	if (_splitCommentToSectionsTask) return _splitCommentToSectionsTask;
	LogDebug(@"Initializing split comment to sections task due to first acces...");
	_splitCommentToSectionsTask = [[SplitCommentToSectionsTask alloc] initWithStore:self.store settings:self.settings];
	return _splitCommentToSectionsTask;
}

- (ProcessorCommentTask *)registerCommentComponentsTask {
	if (_registerCommentComponentsTask) return _registerCommentComponentsTask;
	LogDebug(@"Initializing register comment components task due to first access...");
	_registerCommentComponentsTask = [[RegisterCommentComponentsTask alloc] initWithStore:self.store settings:self.settings];
	return _registerCommentComponentsTask;
}

- (ProcessorCommentTask *)detectCrossReferencesTask {
	if (_detectCrossReferencesTask) return _detectCrossReferencesTask;
	LogDebug(@"Initializing detect cross references task due to first access...");
	_detectCrossReferencesTask = [[DetectCrossReferencesTask alloc] initWithStore:self.store settings:self.settings];
	return _detectCrossReferencesTask;
}

@end
