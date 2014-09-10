//
//  GLACollectedFile.h
//  Blik
//
//  Created by Patrick Smith on 2/08/2014.
//  Copyright (c) 2014 Burnt Caramel. All rights reserved.
//

#import "MTLModel.h"
#import "Mantle/Mantle.h"

/*
@protocol GLACollectedFileInfoReading <NSObject>

@property(readonly, nonatomic) NSString *displayName;

@end
*/

@interface GLACollectedFile : MTLModel <MTLJSONSerializing>

- (instancetype)initWithFileURL:(NSURL *)URL;
+ (instancetype)collectedFileWithFileURL:(NSURL *)URL;

@property(readonly, nonatomic) NSURL *URL;

- (NSData *)bookmarkDataWithError:(NSError *__autoreleasing *)error;
@property(readonly, nonatomic) NSData *bookmarkData;

@end