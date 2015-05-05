//
//  ExistingGroupsTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ExistingGroupsTableViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "InlineCalls.h"
#import "Extension.h"
#import "GTLStoreendpointStoreTableGroupCollection.h"
#import "InStoreOrderReceiver.h"

@interface ExistingGroupsTableViewController () <InStoreOrderReceiver>
@property (strong, nonatomic) GTLStoreendpointStoreTableGroupCollection *tableGroups;
@end

@implementation ExistingGroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers[0] == self)
    {
        //        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        //        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UINavigationBarBackIndicatorGold"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        self.navigationItem.leftBarButtonItem = backButton;
    }

    self.refreshControl = [[UIRefreshControl alloc] init];
    //    self.refreshControl.backgroundColor = [UIColor goldColor];
    //    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(setupExistingGroupsData)
                  forControlEvents:UIControlEventValueChanged];

    [self setupExistingGroupsData];
}

- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - InStoreOrderReceiver Delegate

- (void)orderChanged:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    if (!error)
        [self performSegueWithIdentifier:@"segueCreateOrJoinGroupAndShowOrder" sender:self];
    else
    {
        NSString *msg = [NSString stringWithFormat:@"Failed to obtain order information. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team. Error: %@", [error userInfo][@"error"]];
        [[[UIAlertView alloc]initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (void) tableGroupMemberChanged:(NSError *)error
{
    // Don't Care.
}

- (void) openGroupsChanged:(NSError *)error
{
    // Don't Care.
}

- (void)setupExistingGroupsData
{
    if (self.refreshControl.isRefreshing == false)
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        long long storeId = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.identifier.longLongValue;
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreTableGroupsForStoreWithStoreId:storeId];

        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreTableGroupCollection *object,NSError *error)
         {
             if(!error)
             {
                 weakSelf.tableGroups = object;
                 [weakSelf.tableView reloadData];
             }else{
                 NSString *msg = [NSString stringWithFormat:@"Failed to obtain information on existing groups and tables. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team. Error: %@", [error userInfo][@"error"]];
                 [[[UIAlertView alloc]initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                 NSLog(@"setupExistingGroupsData Error:%@",[error userInfo][@"error"]);
             }
             if (self.refreshControl.isRefreshing == true)
                 [self.refreshControl endRefreshing];
             else
                 [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
         }];
    }
}
- (IBAction)createGroup:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.globalObjectHolder.inStoreOrderDetails createGroup:self];
}

#pragma mark - Table view data source

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *title = [NSString stringWithFormat:@"Welcome to %@", appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name];
    [UtilCalls setupHeaderView:headerCell WithTitle:title AndSubTitle:@"Find your group or create a new one."];
    return headerCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // Display a message when the table is empty
    if (self.tableGroups.items.count == 0)
    {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No groups are available. Please pull down to refresh or create a new group.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    else
    {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return self.tableGroups.items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imgProfilePhoto = (UIImageView *)[cell viewWithTag:501];
    UILabel *txtName = (UILabel *)[cell viewWithTag:502];
    
    cell.tag = indexPath.row;
    
    GTLStoreendpointStoreTableGroup *tableGroup = [self.tableGroups.items objectAtIndex:indexPath.row];
    
    // NOTE: Rounded rect
    imgProfilePhoto.layer.cornerRadius = 10.0f;
    imgProfilePhoto.clipsToBounds = YES;
    //    imgProfilePhoto.layer.borderWidth = 1.0f;
    //    imgProfilePhoto.layer.borderColor = [UIColor grayColor].CGColor;
    
    if (IsEmpty(tableGroup.profilePhotoUrl) == false && ![tableGroup.profilePhotoUrl isEqualToString:@"undefined"])
    {
        //        [cell.itemPFImageView sd_setImageWithURL:[NSURL URLWithString:menuItemAndStats.menuItem.thumbnailUrl]];
        [imgProfilePhoto setImageWithURL:[NSURL URLWithString:tableGroup.profilePhotoUrl ]
                        placeholderImage:[UIImage imageWithColor:RGBA(0.0, 0.0, 0.0, 0.5)]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   if (error) {
                                       NSLog(@"ERROR : %@", error);
                                   }
                               }
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    else {
        imgProfilePhoto.image = [UIImage imageNamed:@"no_image"];
    }
    
    txtName.text = [NSString stringWithFormat:@"%@ %@", tableGroup.firstName, tableGroup.lastName];
    
    return cell;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.globalObjectHolder.inStoreOrderDetails joinGroup:[self.tableGroups.items objectAtIndex:indexPath.row] receiver:self];
}

#pragma mark - Navigation
/*

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get reference to the destination view controller
    if ([[segue identifier] isEqualToString:@"segueShowGroupMembers"])
    {
        JoinGroupTableViewController *controller = [segue destinationViewController];
        [controller setSelectedTableGroup:self.selectedTableGroup];
    }
}
 */

- (IBAction)unwindToExistingGroupsTableViewController:(UIStoryboardSegue *)unwindSegue
{
}

@end
