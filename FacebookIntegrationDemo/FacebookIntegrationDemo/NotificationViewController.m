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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary<FBGraphObject> *object = self.friendslist[indexPath.row];
    NSString *stringID = object[@"id"];
    [self deleteRequestID:[NSString stringWithFormat:@"%@", stringID] atIndex:indexPath.row];
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

- (void)deleteRequestID:(NSString*)requestID atIndex:(NSInteger)index
{
    NSString *path = [NSString stringWithFormat:@"/%@", requestID];
    [FBRequestConnection startWithGraphPath:path
                                 parameters:nil
                                 HTTPMethod:@"DELETE"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
    z                          if (!error)
                              {
                                  MLog(@"successful!");
                                  [self.friendslist removeObjectAtIndex:index];
                                  [self.tableView reloadData];
                              }
                          }];
}
@end
