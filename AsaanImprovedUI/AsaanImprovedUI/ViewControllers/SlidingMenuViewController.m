//
//  SlidingMenuViewController.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 1/4/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "SlidingMenuViewController.h"

#import "AddFriendViewController.h"
#import "GroupView.h"
#import <Parse/Parse.h>

@implementation SMTableViewCell1
@end

#define SEGUE_SMToStoreList         @"SMToStoreListSegue"
#define SEGUE_SMToUpdateProfile     @"SMToUpdateProfile"
#define SEGUE_SMToChatHistory       @"SMToChatHistory"
#define SEGUE_SMToFriends           @"SMToFriendsSegue"
#define SEGUE_SMToCart              SEGUE_SMToUpdateProfile
#define SEGUE_SMToOrderHistory      @""
#define SEGUE_UnwindToStoreList     @"UnwindToStoreList"

@interface SlidingMenuViewController () {

    NSArray *_menu;
    NSArray *_menuSegue;
}

@end

@implementation SlidingMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menu = @[@"Stores", @"Profile", @"Chat History", @"Friends", @"Cart", @"Order History", @"Logout"];
    _menuSegue = @[SEGUE_SMToStoreList, SEGUE_SMToUpdateProfile, SEGUE_SMToChatHistory, SEGUE_SMToFriends, SEGUE_SMToUpdateProfile, SEGUE_SMToOrderHistory, SEGUE_UnwindToStoreList];
    
    NSAssert(_menu.count == _menuSegue.count, @"Menu and MenuSegue length should be equal.");
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SMToFriendsSegue"]) {
        AddFriendViewController *vc = (AddFriendViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        vc.showSlidingMenuButton = true;
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SlidingMenuCell";
    
    SMTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    
    cell.titleLabel.text = _menu[indexPath.row];
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Test %@", _menuSegue[indexPath.row]);
    if ([_menuSegue[indexPath.row] isEqualToString:@""]) {
        return;
    }
//    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_SMToChatHistory]) {
//        
//        SWRevealViewController *revealViewController = self.revealViewController;
//        GroupView *groupView = [[GroupView alloc] init];
//        [(UINavigationController *)revealViewController.frontViewController pushViewController:groupView animated:YES];
//    }
    else if ([_menuSegue[indexPath.row] isEqualToString:SEGUE_UnwindToStoreList]) {
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser)
            [PFUser logOut];
        
        [self performSegueWithIdentifier:SEGUE_SMToStoreList sender:self];
    }
    else {
        [self performSegueWithIdentifier:_menuSegue[indexPath.row] sender:self];
    }
}

@end
