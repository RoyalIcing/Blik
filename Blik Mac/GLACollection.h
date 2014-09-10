//
//  GLAProjectItem.h
//  Blik
//
//  Created by Patrick Smith on 18/07/2014.
//  Copyright (c) 2014 Burnt Caramel. All rights reserved.
//

@import Foundation;
#import "Mantle/Mantle.h"
@class GLAProject;
@class GLACollectionContent;


typedef NS_ENUM(NSInteger, GLACollectionColor) {
	GLACollectionColorUnknown,
	GLACollectionColorLightBlue,
	GLACollectionColorGreen,
	GLACollectionColorPinkyPurple,
	GLACollectionColorRed,
	GLACollectionColorYellow
};


@protocol GLACollectedItem <NSObject>

@property(copy, readonly, nonatomic) NSString *title;

@end


@interface GLACollection : MTLModel <GLACollectedItem, MTLJSONSerializing, NSPasteboardReading, NSPasteboardWriting>

@property(weak, nonatomic) GLAProject *project;

@property(nonatomic) GLACollectionContent *content;

@property(readonly, nonatomic) NSUUID *UUID;
@property(copy, nonatomic) NSString *title;

@property(nonatomic) GLACollectionColor colorIdentifier;

+ (NSValueTransformer *)colorIdentifierValueTransformer;

@end


@interface GLACollection (PasteboardSupport)

extern NSString *GLACollectionJSONPasteboardType;

- (NSPasteboardItem *)newPasteboardItem;
+ (void)writeCollections:(NSArray *)collections toPasteboard:(NSPasteboard *)pboard;

+ (BOOL)canCopyCollectionsFromPasteboard:(NSPasteboard *)pboard;
+ (NSArray *)copyCollectionsFromPasteboard:(NSPasteboard *)pboard;

@end


@interface GLACollection (GLADummyContent)

+ (instancetype)dummyCollectionWithTitle:(NSString *)title colorIdentifier:(GLACollectionColor)colorIdentifier content:(GLACollectionContent *)content;

@end


@protocol GLACollectionListEditing <NSObject>

- (void)addChildCollections:(NSArray *)collections;
- (void)insertChildCollections:(NSArray *)collections atIndexes:(NSIndexSet *)indexes;
//- (void)removeChildCollections:(NSArray *)collections;
- (void)removeChildCollectionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceChildCollectionsAtIndexes:(NSIndexSet *)indexes withChildCollections:(NSArray *)collections;
- (void)moveChildCollectionsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)toIndex;

- (NSArray *)copyCollections;
- (NSArray *)childCollectionsAtIndexes:(NSIndexSet *)indexes;

//- (void)addObserverForAnyChanges:(void(^)(void))block;

/*
- (void)addObserverForInsertedCollections:(void(^)(NSIndexSet *indexesInserted))block;
- (void)addObserverForRemovedCollections:(void(^)(NSIndexSet *indexesRemoved, NSArray *collectionsRemoved))block;
- (void)addObserverForChangedIndexes:(void(^)(NSIndexSet *indexesChanged))block;
*/
@end