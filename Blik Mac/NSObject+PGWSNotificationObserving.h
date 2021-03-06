//
//  NSObject+PGWSNotificationObserving.h
//  Blik
//
//  Created by Patrick Smith on 9/12/2014.
//  Copyright (c) 2014 Burnt Caramel. All rights reserved.
//

@import Foundation;


@interface NSObject (PGWSNotificationObserving)

#pragma mark Notifying

- (void)pgws_postNotificationName:(NSString *)notificationName;
- (void)pgws_postNotificationName:(NSString *)notificationName userInfo:(NSDictionary *)userInfo;

@end
