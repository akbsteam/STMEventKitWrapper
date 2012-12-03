//
//  STMLocalNotificationsWrapper.m
//  LocalNotificationsWrapperExample
//
//  Created by Andy Bennett on 03/12/2012.
//  Copyright (c) 2012 steamshift. All rights reserved.
//

#import "STMLocalNotificationsWrapper.h"

@interface STMLocalNotificationsWrapper()

@property (nonatomic, strong) NSDictionary *identifiers;

@end

@implementation STMLocalNotificationsWrapper

+ (STMLocalNotificationsWrapper *)sharedInstance {
    static dispatch_once_t pred;
    static STMLocalNotificationsWrapper *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[STMLocalNotificationsWrapper alloc] init];
    });
    
    return sharedInstance;
}

- (EKCalendar *)eventStore:(EKEventStore *)eventStore calendarForEvents:(NSString *)calendarIdentifier
{
    EKCalendar *calendar = [eventStore calendarWithIdentifier:calendarIdentifier];
    if (calendar)
        return calendar;

    NSString* calendarName = @"My Cal";
    
    
    // Get the calendar source
    EKSource *localSource;
    for (EKSource* source in eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal)
        {
            localSource = source;
            break;
        }
    }
    
    if (!localSource)
        return nil;
    
    if ([EKCalendar respondsToSelector:@selector(calendarForEntityType:eventStore:)]) {
        calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
    } else {
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        calendar = [EKCalendar calendarWithEventStore:eventStore];
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
    }
    
    calendar.source = localSource;
    calendar.title = calendarName;
    
    NSError* error;
    [eventStore saveCalendar:calendar commit:YES error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error.description);
        return nil;
    }

    return calendar;
}

- (EKRecurrenceFrequency)frequencyFromCalendarUnit:(NSCalendarUnit)calendarUnit
{
    EKRecurrenceFrequency freq;
    switch (calendarUnit) {
        case NSHourCalendarUnit:
            freq = EKRecurrenceFrequencyDaily;
            break;
            
        case NSDayCalendarUnit:
            freq = EKRecurrenceFrequencyDaily;
            break;
            
        case NSWeekCalendarUnit:
            freq = EKRecurrenceFrequencyWeekly;
            break;
            
        case NSMonthCalendarUnit:
            freq = EKRecurrenceFrequencyMonthly;
            break;
            
        case NSYearCalendarUnit:
            freq = EKRecurrenceFrequencyYearly;
            break;
            
        default:
            freq = EKRecurrenceFrequencyDaily;
            break;
    }
    return freq;
}

- (void)eventKit:(id <STMLocalNotificationProtocol>)notification
{
    EKEventStore *eventDB = [[EKEventStore alloc] init];

    if ([eventDB respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            [self createEvent:notification withStore:eventDB];
        }];
    } else {
        [self createEvent:notification withStore:eventDB];
    }
}

- (void)createEvent:(id <STMLocalNotificationProtocol>)notification withStore:(EKEventStore *)eventDB
{
    EKEvent *myEvent  = [EKEvent eventWithEventStore:eventDB];
    
	myEvent.title     = notification.message;
    myEvent.startDate = notification.startDate;
    myEvent.endDate   = notification.startDate;
	myEvent.allDay = NO;
    myEvent.URL = [NSURL URLWithString:@"http://google.com"];
    myEvent.notes = notification.alertBody;
    
    EKRecurrenceFrequency freq = [self frequencyFromCalendarUnit:[notification.period intValue]];
    
    EKRecurrenceRule *recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:freq interval:[notification.repeat intValue] end:[EKRecurrenceEnd recurrenceEndWithEndDate:notification.endDate]];
    
    [myEvent addRecurrenceRule:recurrenceRule];
    
    [myEvent addAlarm:[EKAlarm alarmWithRelativeOffset:0]];
    [myEvent setCalendar:[self eventStore:eventDB calendarForEvents:@"myEvents"]];
    
    NSError *err;
    
    [eventDB saveEvent:myEvent span:EKSpanThisEvent error:&err];
    
	if (!err) {
		UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Event Created"
                              message:@"Yay!?"
                              delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil];
		[alert show];
	}
}

@end
