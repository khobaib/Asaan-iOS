//
//  ServerSelectGroupTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/8/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ServerSelectGroupTableViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "InlineCalls.h"
#import "Extension.h"
#import "GTLStoreendpointStoreTableGroupCollection.h"
#import "InStoreOrderReceiver.h"

@interface ServerSelectGroupTableViewController ()<InStoreOrderReceiver>
@property (strong, nonatomic) GTLStoreendpointStoreTableGroupCollection *tableGroups;

@end

@implementation ServerSelectGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    [appDelegate.globalObjectHolder.inStoreOrderDetails getOpenGroups:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) orderChanged
{
    // Don't care
}
- (void) tableGroupMemberChanged
{
    // Don't care
}
- (void) openGroupsChanged
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *title = [NSString stringWithFormat:@"Welcome to %@", appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name];
    [UtilCalls setupHeaderView:headerCell WithTitle:title AndSubTitle:@"Select a group for your table."];
    return headerCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (self.tableGroups == nil)
        return 0;
    else
        return self.tableGroups.items.count;
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    appDelegate.globalObjectHolder.inStoreOrderDetails.selectedTableGroup = [self.tableGroups.items objectAtIndex:indexPath.row];
    appDelegate.globalObjectHolder.inStoreOrderDetails.selectedTableGroup.orderId = self.selectedOrder.identifier;
    
    [self updateStoreTableGroup:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedTableGroup.identifier.longLongValue withOrderId:self.selectedOrder.identifier.longLongValue];
    
    [self performSegueWithIdentifier:@"segueUnwindSelectGroupToOrderSummary" sender:self];
}

- (void) updateStoreTableGroup:(long long)tableGroupId withOrderId:(long long)orderId
{
    if (self)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForUpdateStoreTableGroupWithOrderId:orderId storeTableGroupId:tableGroupId];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreTableGroupCollection *object,NSError *error)
         {
             if(error)
             {
                 NSLog(@"setupExistingGroupsData Error:%@",[error userInfo][@"error"]);
             }
         }];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
