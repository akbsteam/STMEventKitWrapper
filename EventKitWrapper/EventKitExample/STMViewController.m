//
//  STMViewController.m
//  LocalNotificationsWrapperExample
//
//  Created by Andy Bennett on 03/12/2012.
//  Copyright (c) 2012 steamshift. All rights reserved.
//

#import "STMViewController.h"
#import "STMEventKitWrapper.h"
#import "STMEvent.h"

@interface STMViewController ()

@end

@implementation STMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    STMEventKitWrapper *wrapper = [[STMEventKitWrapper alloc] initWithName:@"My Events" identifier:@"myEvents"];
    
    STMEvent *event = [[STMEvent alloc] init];
    
    event.alertBody = @"alert body";
    event.alertAction = @"alert action";
    event.message = @"message";
    event.repeat = @(4);
    event.period = @(NSHourCalendarUnit);
    event.startDate = [NSDate dateWithTimeIntervalSinceNow:60];
    event.endDate = [NSDate dateWithTimeIntervalSinceNow:1200];
    event.identifier = @"myEvent";
    event.url = [NSURL URLWithString:@"http://google.com"];
    
    [wrapper eventKitCreate:event success:^{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Event Created"
                              message:@"Yay!?"
                              delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil];
		[alert show];
    } failure:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
