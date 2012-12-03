//
//  STMViewController.m
//  LocalNotificationsWrapperExample
//
//  Created by Andy Bennett on 03/12/2012.
//  Copyright (c) 2012 steamshift. All rights reserved.
//

#import "STMViewController.h"
#import "STMLocalNotificationsWrapper.h"
#import "STMNotification.h"

@interface STMViewController ()

@end

@implementation STMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    STMNotification *notification = [[STMNotification alloc] init];
    
    notification.alertBody = @"alert body";
    notification.alertAction = @"alert action";
    notification.message = @"message";
    notification.repeat = @(4);
    notification.period = @(NSHourCalendarUnit);
    notification.startDate = [NSDate dateWithTimeIntervalSinceNow:60];
    notification.endDate = [NSDate dateWithTimeIntervalSinceNow:1200];
    notification.identifier = @"myEvent";
    
    [[STMLocalNotificationsWrapper sharedInstance] eventKit:notification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
