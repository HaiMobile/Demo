//
//  NotificationViewController.m
//  FacebookIntegrationDemo
//
//  Created by Developer on 12/30/14.
//  Copyright (c) 2014 s4world. All rights reserved.
//

#import "NotificationViewController.h"
#import "MessageTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface NotificationViewController ()

@property (nonatomic, strong)MessageTableViewCell *messageCell;

@end
static FBFrictionlessRecipientCache* ms_friendCache;

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
    [FBRequestConnection startWithGraphPath:@"/me/apprequests"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              NSArray* friends = [result objectForKey:@"data"];
                              NSLog(@"Found: %lu friends", (unsigned long)friends.count);
                              
                              self.friendslist = [NSMutableArray arrayWithArray:friends];
                              [self.tableView reloadData];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.friendslist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *cell = (MessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"messagecell" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"messagecell"];
    }
    NSDictionary<FBGraphObject> *object = self.friendslist[indexPath.row];
    
    NSLog(@"message:%d - %@ ", indexPath.row, object);
    /*
    NSString *friendProfilePhotoURLString = object[@"picture"][@"data"][@"url"];
    [cell.thumbImageView sd_setImageWithURL:[NSURL URLWithString:friendProfilePhotoURLString]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      //MLog(@"Set image %@ successful!", image);
                                  }];
    */
    //MLog(@"Name:%@, url:%@", friend.name, friendProfilePhotoURLString);
    NSString *message = [NSString stringWithFormat:@"%@ %@", object[@"from"][@"name"], object[@"message"]];
    cell.titleLabel.text = message;
    // Configure the cell...
    //https://developers.facebook.com/docs/games/requests/v2.2
    return cell;
}


- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (IBAction)done:(id)sender {
    
    // Normally this won't be hardcoded but will be context specific, i.e. players you are in a match with, or players who recently played the game etc
    NSMutableArray *friendIDs = [NSMutableArray array];
    [friendIDs addObject:@"1597812257117573"];
    for (NSDictionary<FBGraphUser>* friend in self.friendslist)
    {
        NSString *friendProfilePhotoURLString = friend[@"picture"][@"data"][@"url"];
        NSLog(@"Friend named %@ with id %@ url:%@", friend.name, friend.objectID, friendProfilePhotoURLString);
        //[friendIDs addObject:friend.objectID];
    }
    NSInteger nScore = 0000;
    
    SBJson4Writer *jsonWriter = [SBJson4Writer new];
    NSDictionary *challenge =  [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)nScore], @"challenge_score", nil];
    NSString *challengeStr = [jsonWriter stringWithObject:challenge];
    
    
    // Create a dictionary of key/value pairs which are the parameters of the dialog
    
    // 1. No additional parameters provided - enables generic Multi-friend selector
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     // 2. Optionally provide a 'to' param to direct the request at a specific user
                                     [friendIDs componentsJoinedByString:@","], @"to", // Ali
                                     // 3. Suggest friends the user may want to request, could be game context specific?
                                     //[suggestedFriends componentsJoinedByString:@","], @"suggestions",
                                     challengeStr, @"data",
                                     nil];
    
    
    
    if (ms_friendCache == NULL) {
        ms_friendCache = [[FBFrictionlessRecipientCache alloc] init];
    }
    
    [ms_friendCache prefetchAndCacheForSession:nil];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:[NSString stringWithFormat:@"I just smashed %ld friends! Can you beat it?", (long)nScore]
                                                    title:@"Smashing!"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result,
                                                            NSURL *resultURL,
                                                            NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }
                                                  }
                                              friendCache:ms_friendCache];
}
- (void)action
{
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     
                                     // Optional parameter for sending request directly to user
                                     // with UID. If not specified, the MFS will be invoked
                                     @"RECIPIENT_USER_ID", @"to",
                                     
                                     // Give the action object request information
                                     @"send", @"action_type",
                                     @"YOUR_OBJECT_ID", @"object_id",
                                     
                                     nil];
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Take this bomb to blast your way to victory!"
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {}
     ];
}
@end
