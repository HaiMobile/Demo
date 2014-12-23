//
//  FriendlistViewController.h
//  IntegratingFacebookTutorial
//
//  Created by Developer on 12/18/14.
//
//

#import <UIKit/UIKit.h>

@interface FriendlistViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friendslist;
@end
