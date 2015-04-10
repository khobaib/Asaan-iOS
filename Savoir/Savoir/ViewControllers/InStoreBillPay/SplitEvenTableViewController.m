//
//  SplitEvenTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "SplitEvenTableViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "InlineCalls.h"
#import "Extension.h"
#import "InStoreOrderDetails.h"

@interface SplitEvenTableViewController ()
@property (strong, nonatomic) GTLStoreendpointStoreTableGroupMember *memberMe;
@property (strong, nonatomic) NSMutableArray *changedRows;
@end

@implementation SplitEvenTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.changedRows = [[NSMutableArray alloc]init];
    [self setupGroupMembers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupGroupMembers
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        long long storeTableGroupId = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedTableGroup.identifier.longLongValue;
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetMembersForStoreTableGroupWithStoreTableGroupId:storeTableGroupId];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreTableGroupMemberCollection *object,NSError *error)
         {
             if(!error)
             {
                 appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers = object;
                 [weakSelf.tableView reloadData];
              }else{
                 NSLog(@"setupExistingGroupsData Error:%@",[error userInfo][@"error"]);
             }
             hud.hidden = YES;
         }];
    }
}

#pragma mark - Table view data source

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *title = [NSString stringWithFormat:@"Welcome to %@", appDelegate.globalObjectHolder.selectedStore.name];
    [UtilCalls setupHeaderView:headerCell WithTitle:title AndSubTitle:@"Find your group or create a new one."];
    return headerCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    return appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imgProfilePhoto = (UIImageView *)[cell viewWithTag:501];
    UILabel *txtName = (UILabel *)[cell viewWithTag:502];
    UILabel *txtDesc = (UILabel *)[cell viewWithTag:503];
    
    cell.tag = indexPath.row;
    
    int bChanged = 0;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointStoreTableGroupMember *member = [appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items objectAtIndex:indexPath.row];
    
    // NOTE: Rounded rect
    imgProfilePhoto.layer.cornerRadius = 10.0f;
    imgProfilePhoto.clipsToBounds = YES;
    //    imgProfilePhoto.layer.borderWidth = 1.0f;
    //    imgProfilePhoto.layer.borderColor = [UIColor grayColor].CGColor;
    
    if (IsEmpty(member.profilePhotoUrl) == false && ![member.profilePhotoUrl isEqualToString:@"undefined"])
    {
        //        [cell.itemPFImageView sd_setImageWithURL:[NSURL URLWithString:menuItemAndStats.menuItem.thumbnailUrl]];
        [imgProfilePhoto setImageWithURL:[NSURL URLWithString:member.profilePhotoUrl ]
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
    
    txtName.text = [NSString stringWithFormat:@"%@ %@", member.firstName, member.lastName];
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if (member.userId.longLongValue == appDelegate.globalObjectHolder.currentUser.identifier.longLongValue)
    {
        self.memberMe = member;
        if (self.memberMe.paymentType != [NSNumber numberWithInt:[InStoreOrderDetails PAYMENT_TYPE_SPLITEVENLY]])
        {
            self.memberMe.paymentType = [NSNumber numberWithInt:[InStoreOrderDetails PAYMENT_TYPE_SPLITEVENLY]];
            self.memberMe.payingUserId = [NSNumber numberWithLongLong:0ll];
            self.memberMe.payingFor = [NSNumber numberWithInt:1];
            bChanged = 1;
        }
        appDelegate.globalObjectHolder.inStoreOrderDetails.memberMe = self.memberMe;
        if (self.memberMe.payingUserId.longLongValue == 0)
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    if (appDelegate.globalObjectHolder.currentUser.identifier.longLongValue == member.payingUserId.longLongValue)
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    if (member.payingUserId.longLongValue != 0)
    {
        for (GTLStoreendpointStoreTableGroupMember *otherMember in appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items)
        {
            if (otherMember.userId.longLongValue == member.payingUserId.longLongValue)
            {
                txtDesc.text = [NSString stringWithFormat:@"Paid by %@ %@", otherMember.firstName, otherMember.lastName];
                break;
            }
        }
    }
    else
        txtDesc.text = [NSString stringWithFormat:@"Paying for %d of %d", member.payingFor.intValue, appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items.count];
    
    [self.changedRows addObject:[NSNumber numberWithInt:bChanged]];
    return cell;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointStoreTableGroupMember *member = [appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items objectAtIndex:indexPath.row];
    if (member.identifier.longLongValue == self.memberMe.identifier.longLongValue)
    {
        if (self.memberMe.payingUserId.longLongValue == 0)
            return;
        else
        {
            self.memberMe.paymentType = [NSNumber numberWithInt:[InStoreOrderDetails PAYMENT_TYPE_SPLITEVENLY]];
            self.memberMe.payingUserId = [NSNumber numberWithLongLong:0ll];
            self.memberMe.payingFor = [NSNumber numberWithInt:1];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else
    {
        if (member.payingUserId.longLongValue != 0)
            return;
        else if (member.payingFor.intValue > 1)
        {
            NSString *msg = [NSString stringWithFormat:@"%@ %@ is already paying for other guests.", member.firstName, member.lastName];
            [[[UIAlertView alloc]initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        else
        {
            member.payingUserId = [NSNumber numberWithLongLong:self.memberMe.userId.longLongValue];
            member.paymentType = [NSNumber numberWithInt:[InStoreOrderDetails PAYMENT_TYPE_SPLITEVENLY]];
            member.payingFor = [NSNumber numberWithInt:0];
            self.memberMe.payingFor = [NSNumber numberWithInt:self.memberMe.payingFor.intValue + 1];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    [self.changedRows replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt:1]];
}

- (void) updateStoreTableGroupMembers:(NSMutableArray *)memberArray
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    GTLStoreendpointStoreTableGroupMemberArray *memberCollection = [[GTLStoreendpointStoreTableGroupMemberArray alloc]init];
    memberCollection.members = memberArray;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForUpdateStoreTableGroupMemberWithObject:memberCollection];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object,NSError *error)
     {
         if(error)
             NSLog(@"queryForUpdateStoreTableGroupMemberWithObject Error:%@",[error userInfo][@"error"]);
         hud.hidden = YES;
     }];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    // Get reference to the destination view controller
    if ([[segue identifier] isEqualToString:@"segueSplitEvenlyToPay"])
    {
        NSMutableArray *memberArray = [[NSMutableArray alloc]init];
        int i = 0;
        for (NSNumber *bChanged in self.changedRows)
        {
            i++;
            if (bChanged.intValue == 1)
                [memberArray addObject:[appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items objectAtIndex:i]];
        }
        [self updateStoreTableGroupMembers:memberArray];
    }
}

@end
