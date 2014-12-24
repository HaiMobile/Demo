//
//  ListTableViewController.m
//  IntegratingFacebookTutorial
//
//  Created by Developer on 12/23/14.
//
//

#import "ListTableViewController.h"

#define kClassName @"ABC"
#define kAuthor @"uuthor"
#define kScore @"score"
#define kLevelId @"levelId"
#define MAX_LEVELS @50

@interface ListTableViewController ()
@property (nonatomic, strong) NSMutableArray *items;
@property NSInteger randomNum;
@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [NSMutableArray array];
    self.randomNum = 100;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self syncAllLevelsOnlineToDataStore];
}

#pragma mark - Online Parse

- (void)getAllLevelsOfCurrentUser
{
    // Create a query
    PFQuery *postQuery = [PFQuery queryWithClassName:kClassName];
    
    // Follow relationship
    [postQuery whereKey:kAuthor equalTo:[PFUser currentUser]];
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.items setArray:objects];
            [self.tableView reloadData];
        }
    }];
    
}

#pragma mark - Datastore parse

- (void)syncAllLevelsOnlineToDataStore
{
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query whereKey:kAuthor equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            if (objects.count >0)
            {
                [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
                    [self getAllLevelsFromDataStore];
                }];
            }
            else
            {
                [self getAllLevelsFromDataStore];
            }
        }
    }];
}
- (void)getAllLevelsFromDataStore
{
    MLog(@"Get All Data from Datastore ...");
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [self.items setArray:objects];
            if (self.items.count == 0)
            {
                MLog(@"There are no data in Datastore ...");
                [self storeAllLevelsToDataStore];
            }
            else
            {
                /**
                 *  Pull Data to layout
                 */
                MLog(@"Pull data To UI ...");
                [self.tableView reloadData];
            }
        }
    }];
}

- (void)storeAllLevelsToDataStore
{
    NSMutableArray *levels = [NSMutableArray array];
    for (int i=0; i<MAX_LEVELS.integerValue; i++)
    {
        PFObject *level = [PFObject objectWithClassName:kClassName];
        level[kScore] = @0;
        level[kLevelId] = [NSNumber numberWithInteger:i+1];
        level[kAuthor] = [PFUser currentUser];
        [levels addObject:level];
    }
    [PFObject pinAllInBackground:levels block:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            MLog(@"Created Levels in DataStore ...");
            [self getAllLevelsFromDataStore];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
        // Cannot select these cells
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    
    PFObject *object = self.items[indexPath.row];
    
    //MLog(@"Object:%@", object);
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"Item:%@",object[kLevelId]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",object[kScore]];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *object = self.items[indexPath.row];
    object[kScore] = [NSNumber numberWithInteger:self.randomNum++];
    object[kAuthor] = [PFUser currentUser];
    MLog(@"User:%@", object[kAuthor]);
    
    [object saveEventually:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            MLog(@"Save Row %@ successful!", object[kLevelId]);
            [self.tableView reloadData];
        }
    }];
    /*
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            MLog(@"Save Row %@ successful!", object[@"levelId"]);
        }
    }];
     */
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)saveScore:(NSNumber*)score toLevel:(NSNumber*)levelId
{
    PFObject *level = [PFObject objectWithClassName:kClassName];
    level[@"levelId"] = levelId;
    level[@"score"] = @1337;
    level[@"author"] = [PFUser currentUser];
    [level saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            MLog(@"Save level %@ successful!", levelId);
        }
    }];
}
@end
