//
//  FriendlistViewController.m
//  IntegratingFacebookTutorial
//
//  Created by Developer on 12/18/14.
//
//

#import "FriendlistViewController.h"

@interface FriendlistViewController ()

@end

@implementation FriendlistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendlistcell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
@end
