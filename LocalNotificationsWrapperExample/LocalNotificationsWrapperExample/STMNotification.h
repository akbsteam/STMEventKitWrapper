//
//  STMNotification.h
//  LocalNotificationsWrapperExample
//
//  Created by Andy Bennett on 03/12/2012.
//  Copyright (c) 2012 steamshift. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMLocalNotificationsWrapper.h"

@interface STMNotification : NSObject <STMLocalNotificationProtocol>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *alertBody;
@property (nonatomic, strong) NSString *alertAction;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSNumber *repeat;
@property (nonatomic, strong) NSNumber *period;

@end
