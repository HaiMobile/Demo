//
//  ListTableViewController.h
//  IntegratingFacebookTutorial
//
//  Created by Developer on 12/23/14.
//
//

#import <UIKit/UIKit.h>
#import "ItemTableViewCell.h"

@interface ListTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet ItemTableViewCell *itemCell;

@end
