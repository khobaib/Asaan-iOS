//
//  SlidingMenuViewController.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 1/4/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "SlidingMenuViewController.h"

#import "AddFriendViewController.h"

@implementation SMTableViewCell1
@end

@interface SlidingMenuViewController () {

    NSArray *_menu;
    NSArray *_menuSegue;
}

@end

@implementation SlidingMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menu = @[@"Stores", @"Profile", @"Friends", @"Cart", @"Order History", @"Logout"];
    _menuSegue = @[@"SMToStoreListSegue", @"SMToUpdateProfile", @"SMToFriendsSegue", @"SMToUpdateProfile", @"", @""];
    
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

    if ([_menuSegue[indexPath.row] isEqualToString:@""]) {
        return;
    }
    [self performSegueWithIdentifier:_menuSegue[indexPath.row] sender:self];
}

@end
