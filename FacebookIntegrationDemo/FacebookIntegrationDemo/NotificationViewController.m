//
//  NotificationViewController.m
//  FacebookIntegrationDemo
//
//  Created by Developer on 12/30/14.
//  Copyright (c) 2014 s4world. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [self getFBFriendsList];
    }
    else
    {
        NSAssert(1, @"No FB Login");
    }
}

- (void)getFBFriendsList
{
    [FBRequestConnection startWithGraphPath:@"/me/invitable_friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         NSArray* friends = [result objectForKey:@"data"];
         NSLog(@"Found: %lu friends", (unsigned long)friends.count);
         NSLog(@"Format: %@", friends[0]);
//         self.friendslist = [NSMutableArray arrayWithArray:friends];
//         [self.tableView reloadData];
         
     }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
