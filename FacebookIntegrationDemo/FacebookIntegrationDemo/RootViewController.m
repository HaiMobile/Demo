//
//  RootViewController.m
//  FacebookIntegrationDemo
//
//  Created by Developer on 12/30/14.
//  Copyright (c) 2014 s4world. All rights reserved.
//

#import "RootViewController.h"
#import "FriendsListViewController.h"

@interface RootViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Login
- (IBAction)FriendClicked:(id)sender
{
    if ([PFUser currentUser])
    {
        [self gotoFriendList:NO];
    }
    /*
    if ([PFUser currentUser])
    {
        [self gotoFriendList:NO];
    }
    else
    {
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed.");
            } else {
                NSLog(@"Anonymous user logged in.");
                [self gotoFriendList:NO];
            }
        }];
    }
     */
}

- (IBAction)loginButtonTouchHandler:(id)sender  {
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser])
    {
        [[PFFacebookUtils session] closeAndClearTokenInformation];
        [[PFFacebookUtils session] close];
        [[FBSession activeSession] closeAndClearTokenInformation];
        [[FBSession activeSession] close];
        [FBSession setActiveSession:nil];
        [PFUser logOut];
        NSLog(@"User is %@", [PFUser currentUser]);
        NSLog(@"Facebook session is %@", [PFFacebookUtils session]);
        NSLog(@"Facebook session is %@", FBSession.activeSession.observationInfo);
        [self.loginButton setSelected:NO];
        return;
    }
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"public_profile", @"email", @"user_friends"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                MLog(@"result;%@", result);
                [[PFUser currentUser] setObject:result forKey:@"profile"];
                [[PFUser currentUser]saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                    {
                        MLog(@"save profile success");
                    }
                }];
            }];
            [self.loginButton setSelected:YES];
        }
    }];
    
}

- (void)enableLogOutButton
{
    self.loginButton.selected = YES;
}
- (void)enableLogInButton
{
    self.loginButton.selected = NO;
}

#pragma mark -
#pragma mark UserDetailsViewController

- (void)gotoFriendList:(BOOL)animated {
    [self performSegueWithIdentifier:@"friendlistsegue" sender:self];
}
@end
