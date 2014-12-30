//
//  FriendsListViewController.m
//  FacebookIntegrationDemo
//
//  Created by Developer on 12/30/14.
//  Copyright (c) 2014 s4world. All rights reserved.
//

#import "FriendsListViewController.h"
#import "FriendlistTableViewCell.h"

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
    MLog(@"Name:%@, url:%@", friend.name, friendProfilePhotoURLString);
    cell.thumbImageView.image = [UIImage imageWithContentsOfFile:friendProfilePhotoURLString];
    cell.titleLabel.text = friend.name;
    // Configure the cell...
    
    return cell;
}

@end
