//
//  STMLocalNotificationsWrapper.m
//  LocalNotificationsWrapperExample
//
//  Created by Andy Bennett on 03/12/2012.
//  Copyright (c) 2012 steamshift. All rights reserved.
//

#import "STMEventKitWrapper.h"

@implementation STMEventKitWrapper

- (id)initWithName:(NSString *)name identifier:(NSString *)identifier
{
    if (!(self = [super init]))
        return nil;
    
    _calendarName = name;
    _calendarIdentifier = identifier;
    
    return self;
}

- (EKCalendar *)eventStore:(EKEventStore *)eventStore calendarForEvents:(NSString *)calendarIdentifier
{
    EKCalendar *calendar = [eventStore calendarWithIdentifier:calendarIdentifier];
    if (calendar)
        return calendar;

    NSString* calendarName = _calendarName;
    
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

- (void)eventKitCreate:(id <STMEventKitWrapperProtocol>)event
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure
{
    EKEventStore *eventDB = [[EKEventStore alloc] init];

    if ([eventDB respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            [self createEvent:event withStore:eventDB success:success failure:failure];
        }];
    } else {
        [self createEvent:event withStore:eventDB success:success failure:failure];
    }
}

- (void)createEvent:(id <STMEventKitWrapperProtocol>)event
          withStore:(EKEventStore *)eventDB
            success:(void (^)(void))success
            failure:(void (^)(NSError *error))failure
{
    EKEvent *calendarEvent  = [EKEvent eventWithEventStore:eventDB];
    
	calendarEvent.title     = event.message;
    calendarEvent.startDate = event.startDate;
    calendarEvent.endDate   = event.startDate;
	calendarEvent.allDay = NO;
    calendarEvent.URL = event.url;
    calendarEvent.notes = event.alertBody;
    
    EKRecurrenceFrequency freq = [self frequencyFromCalendarUnit:[event.period intValue]];
    
    EKRecurrenceRule *recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:freq interval:[event.repeat intValue] end:[EKRecurrenceEnd recurrenceEndWithEndDate:event.endDate]];
    
    [calendarEvent addRecurrenceRule:recurrenceRule];
    
    [calendarEvent addAlarm:[EKAlarm alarmWithRelativeOffset:0]];
    [calendarEvent setCalendar:[self eventStore:eventDB calendarForEvents:_calendarIdentifier]];
    
    NSError *err;
    
    [eventDB saveEvent:calendarEvent span:EKSpanThisEvent error:&err];
    
    if (err != nil) {
        failure(err);
    } else {
        success();
    }
}

@end
