//
//  TablesViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/8/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "TablesViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "InlineCalls.h"
#import "Extension.h"
#import "ServerOrderSummaryViewController.h"
#import "XMLPOSOrder.h"
#import "UIColor+SavoirGoldColor.h"

@interface TablesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) GTLStoreendpointTableGroupsAndOrders *ordersAndGroups;
@property (strong, nonatomic) NSMutableArray *orders;

@end

@implementation TablesViewController

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
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.backgroundColor = [UIColor goldColor];
//    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(setupExistingTablesFromOrders) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
    [self setupExistingTablesFromOrders];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
//    [self.timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editTable:(id)sender
{
    if (self.btnEdit.tag == 0) // start editing
    {
        [self setEditing:YES animated:YES];
        self.btnEdit.title = @"Done";
        self.btnEdit.tag = 1;
        self.btnAdd.enabled = NO;
    }
    else
    {
        [self setEditing:NO animated:YES];
        self.btnEdit.title = @"Edit";
        self.btnEdit.tag = 0;
        self.btnAdd.enabled = YES;
    }
}

- (void)setupExistingTablesFromOrders
{
    if (self)
    {
        if (self.refreshControl.isRefreshing == false)
            [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];

        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        long long storeId = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.identifier.longLongValue;
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreOrdersAndGroupsForEmployeeWithStoreId:storeId];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointTableGroupsAndOrders *object,NSError *error)
         {
             if (weakSelf.refreshControl.isRefreshing == true)
                 [weakSelf.refreshControl endRefreshing];
             else
                 [MBProgressHUD hideAllHUDsForView:weakSelf.tableView animated:YES];
             if(!error)
             {
                 weakSelf.ordersAndGroups = object;
                 weakSelf.orders = [[NSMutableArray alloc]initWithArray:weakSelf.ordersAndGroups.orders];
                 [weakSelf.tableView reloadData];
             }
             else
             {
                 NSString *msg = @"Failed to set up tables and orders. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:false];
             }
         }];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}
#pragma mark -
#pragma mark  === UITableViewDataSource ===
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Display a message when the table is empty
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.orders.count == 0)
    {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No table information is currently available. Please pull down to refresh.";
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
        return self.orders.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imgProfilePhoto = (UIImageView *)[cell viewWithTag:501];
    UILabel *txtName = (UILabel *)[cell viewWithTag:502];
    UILabel *txtStatus = (UILabel *)[cell viewWithTag:503];
    UILabel *txtTable = (UILabel *)[cell viewWithTag:504];
    
    cell.tag = indexPath.row;
    imgProfilePhoto.image = [UIImage imageNamed:@"no_image"];
    txtName.text = nil;
    txtStatus.text = nil;
    txtTable.text = nil;
    
    GTLStoreendpointStoreOrder *order = [self.orders objectAtIndex:indexPath.row];
    GTLStoreendpointStoreTableGroup *tableGroup;
    for (GTLStoreendpointStoreTableGroup *tg in self.ordersAndGroups.groups)
    {
        if (tg.identifier.longLongValue == order.storeTableGroupId.longLongValue)
        {
            tableGroup = tg;
            break;
        }
    }
    
    if (order.orderStatus.shortValue == 0)
        txtStatus.text = @"Status: Open";
    else if (order.orderStatus.shortValue == 1)
        txtStatus.text = @"Status: Acknowledged";
    else if (order.orderStatus.shortValue == 2)
        txtStatus.text = @"Status: Ready";
    else if (order.orderStatus.shortValue == 3)
        txtStatus.text = @"Status: Partially Paid";
    else if (order.orderStatus.shortValue == 4)
        txtStatus.text = @"Status: Paid";
    else if (order.orderStatus.shortValue == 5)
        txtStatus.text = @"Status: Closed";
    
    txtTable.text = [NSString stringWithFormat:@"Table: %d", order.tableNumber.intValue];

    imgProfilePhoto.image = [UIImage imageNamed:@"no_image"];
    txtName.text = @"Not known - not using Savoir";
    
    if (tableGroup != nil)
    {
        txtName.text = [NSString stringWithFormat:@"%@ %@", tableGroup.firstName, tableGroup.lastName];
        
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
    }
    
    return cell;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTLStoreendpointStoreOrder *order = [self.orders objectAtIndex:indexPath.row];
    if (order.orderStatus.shortValue <= 3)
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        GTLStoreendpointStoreOrder *order = [self.orders objectAtIndex:indexPath.row];
        if (order.orderStatus.shortValue <= 3)
        {
            [[[UIAlertView alloc]initWithTitle:@"Error" message:@"This table is not fully paid and closed. Please close table first." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        else
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
            order.orderStatus = [NSNumber numberWithInt:5]; // Status = closed
            
            GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForUpdateOrderFromServerWithObject:order];
            
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
            
            [query setAdditionalHTTPHeaders:dic];
            
            [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object,NSError *error)
             {
                 if(error)
                 {
                     NSString *msg = @"Failed to remove order. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                     [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:false];
                 }
             }];
            [self.orders removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }
    }
}
- (IBAction)btnAddClicked:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails = [[GTLStoreendpointStoreOrderAndTeamDetails alloc]init];
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order = nil;
    [self performSegueWithIdentifier:@"segueTablesToOrderSummary" sender:self];
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails = [[GTLStoreendpointStoreOrderAndTeamDetails alloc]init];
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order = [self.orders objectAtIndex:indexPath.row];
    appDelegate.globalObjectHolder.inStoreOrderDetails.selectedDiscount = [XMLPOSOrder getDiscountFromXML:appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderDetails];
    [self performSegueWithIdentifier:@"segueTablesToOrderSummary" sender:self];
}

#pragma mark -
#pragma mark === TableOrderReceiver ===
#pragma mark -

- (void) changedOrder:(GTLStoreendpointStoreOrder *)order error:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    if (!error)
    {
        long long changedOrderId = order.identifier.longLongValue;
        if (changedOrderId == 0)
            return;
        [self setupExistingTablesFromOrders];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"Failed to obtain order information. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team. Error: %@", [error userInfo][@"error"]];
        [[[UIAlertView alloc]initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueTablesToOrderSummary"])
    {
        ServerOrderSummaryViewController *controller = [segue destinationViewController];
        [controller setReceiver:self];
    }
}

- (IBAction)unwindToServerTableList:(UIStoryboardSegue *)unwindSegue
{
}

@end
