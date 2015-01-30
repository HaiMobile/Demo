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

static NSString* ms_nsstrFirstName;
static FBFrictionlessRecipientCache* ms_friendCache;

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
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser])
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
    [FBRequestConnection startWithGraphPath:@"/me/friends"
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
         NSLog(@"Format: %@", friends);
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
#define kRequestID @"RequestID"
#define kAskLiveId @"AskLive"
#define kAskLiveMessage @"Give me a hand"
#define kInviteId @"Invite"
#define kInviteMessage @"Come join me in Light"

- (IBAction)sendInviteClicked:(id)sender {
    NSMutableDictionary* params;
    
    NSMutableArray *friendIDs = [NSMutableArray array];
    [friendIDs addObject:@"AVlhfAfk0_445AAqEl4JDyibi80P-Tgw6o8f_y_v6IUZd2iId9Z0FIkfhynAYvH_1cUiR001f98JikyVrX-PxHLbCIRtkVbLwsn9hQhFXulX8Q"];
    for (NSDictionary<FBGraphUser>* friend in self.friendslist)
    {
        NSLog(@"Friend named %@ with id %@", friend.name, friend.objectID);
        //[friendIDs addObject:friend.objectID];
    }

    if (friendIDs) {
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys: [friendIDs componentsJoinedByString:@","], @"to", nil];
    }
    else {
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys: nil];
    }
    
    NSLog(@"Send To %@ ", friendIDs);
    
    if (ms_friendCache == NULL) {
        ms_friendCache = [[FBFrictionlessRecipientCache alloc] init];
    }
    
    [ms_friendCache prefetchAndCacheForSession:nil];
    
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:kInviteMessage
                                                    title:@"Light ME"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
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
                                                      }}
                                              friendCache:ms_friendCache];
}

- (IBAction)askLive:(id)sender
{
    // Normally this won't be hardcoded but will be context specific, i.e. players you are in a match with, or players who recently played the game etc
    NSMutableArray *friendIDs = [NSMutableArray array];
    //[friendIDs addObject:@"AVlhfAfk0_445AAqEl4JDyibi80P-Tgw6o8f_y_v6IUZd2iId9Z0FIkfhynAYvH_1cUiR001f98JikyVrX-PxHLbCIRtkVbLwsn9hQhFXulX8Q"];
    //Jena-CA: AVmJHcXV-w3HQcDW2LCLuSA5gFenGrJMFGy04CJTIO9n8Vvbq13mwI_8mwEThBwaf4TNOGmvcMb5dDAE2p_HC38QUqWR2Oh2-oIZNFCLErH5Zw
    for (NSDictionary<FBGraphUser>* friend in self.friendslist)
    {
        NSString *friendProfilePhotoURLString = friend[@"picture"][@"data"][@"url"];
        NSLog(@"Friend named %@ with id %@ url:%@", friend.name, friend.objectID, friendProfilePhotoURLString);
        [friendIDs addObject:friend.objectID];
    }
     NSLog(@"Send To %@ ", friendIDs);
//    
//    SBJson4Writer *jsonWriter = [SBJson4Writer new];
//    NSDictionary *challenge =  [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%@", @YES], kAskLiveId, nil];
    NSString *challengeStr = kAskLiveId;//[jsonWriter stringWithObject:challenge];
    
    
    // Create a dictionary of key/value pairs which are the parameters of the dialog
    
    // 1. No additional parameters provided - enables generic Multi-friend selector
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     // 2. Optionally provide a 'to' param to direct the request at a specific user
                                     [friendIDs componentsJoinedByString:@","], @"to", // Ali
                                     // 3. Suggest friends the user may want to request, could be game context specific?
                                     //[suggestedFriends componentsJoinedByString:@","], @"suggestions",
                                     challengeStr, kRequestID,
                                     nil];
    
    
    
    if (ms_friendCache == NULL) {
        ms_friendCache = [[FBFrictionlessRecipientCache alloc] init];
    }
    
    [ms_friendCache prefetchAndCacheForSession:nil];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:kAskLiveMessage
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
