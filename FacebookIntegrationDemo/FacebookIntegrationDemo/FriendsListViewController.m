//
//  FriendsListViewController.m
//  FacebookIntegrationDemo
//
//  Created by Developer on 12/30/14.
//  Copyright (c) 2014 s4world. All rights reserved.
//

#import "FriendsListViewController.h"
#import "FriendlistTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FriendsListViewController ()
@property (nonatomic, strong)FriendlistTableViewCell *friendListCell;
@end

@implementation FriendsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    // If the user is already logged in, display any previously cached values before we get the latest from Facebook.
    if ([PFUser currentUser]) {
        //do nothing
    }
    
    /* make the API call */
    
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
         self.friendslist = [NSMutableArray arrayWithArray:friends];
         [self.tableView reloadData];
         /*
          for (NSDictionary<FBGraphUser>* friend in friends) {
          NSString *friendProfilePhotoURLString = friend[@"picture"][@"data"][@"url"];
          NSLog(@"Friend named %@ with id %@ url:%@", friend.name, friend.objectID, friendProfilePhotoURLString);
          }
          */
         
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
    FriendlistTableViewCell *cell = (FriendlistTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"friendlistcell" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[FriendlistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendlistcell"];
    }
    NSDictionary<FBGraphUser> *friend = self.friendslist[indexPath.row];
    NSString *friendProfilePhotoURLString = friend[@"picture"][@"data"][@"url"];
    [cell.thumbImageView sd_setImageWithURL:[NSURL URLWithString:friendProfilePhotoURLString]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      //MLog(@"Set image %@ successful!", image);
                                  }];
    
    //MLog(@"Name:%@, url:%@", friend.name, friendProfilePhotoURLString);
    cell.titleLabel.text = friend.name;
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
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"YOUR_MESSAGE_HERE"
     title:nil
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                 }
             }
         }
     }];
}
void FacebookController::SendRequest(NSArray* friendIDs, const int nScore)
{
    // Normally this won't be hardcoded but will be context specific, i.e. players you are in a match with, or players who recently played the game etc
    NSArray *suggestedFriends = [[NSArray alloc] initWithObjects:
                                 @"223400030", @"286400088", @"767670639", @"516910788",
                                 nil];
    
    SBJsonWriter *jsonWriter = [SBJsonWriter new];
    NSDictionary *challenge =  [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d", nScore], @"challenge_score", nil];
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
                                                  message:[NSString stringWithFormat:@"I just smashed %d friends! Can you beat it?", nScore]
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
