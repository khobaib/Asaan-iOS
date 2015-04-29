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
#import "InStoreOrderReceiver.h"

@interface SplitEvenTableViewController ()<InStoreOrderReceiver>
@property (strong, nonatomic) NSIndexPath *indexOfMemberMe;
@property (strong, nonatomic) NSMutableDictionary *changedMembers;
@property (nonatomic, strong) NSTimer *timer;
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
    
    self.changedMembers = [[NSMutableDictionary alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startTimer];
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:35.0 target:self selector:@selector(refreshOrderDetails) userInfo:nil repeats:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orderChanged
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.memberMe == nil
        || appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderStatus.intValue == 4 // Fully Paid
        || appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderStatus.intValue == 5) // Paid and Closed
    {
        [self.timer invalidate];
        [UtilCalls handleClosedOrderFor:self SegueTo:@"segueUnwindSplitEvenToStoreList"];
    }
    [self.tableView reloadData];
}

- (void)openGroupsChanged
{
    [self.timer invalidate];
    [self performSegueWithIdentifier:@"segueSplitEvenlyToPay" sender:self];
}

- (void)refreshOrderDetails
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.globalObjectHolder.inStoreOrderDetails getStoreOrderDetails:self];
}
- (IBAction)btnDoneClicked:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (self.changedMembers != nil && self.changedMembers.count > 0)
        [appDelegate.globalObjectHolder.inStoreOrderDetails updateStoreTableGroupMembers:self.changedMembers receiver:self];
    else
        [self openGroupsChanged];
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    long count = appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imgProfilePhoto = (UIImageView *)[cell viewWithTag:501];
    UILabel *txtName = (UILabel *)[cell viewWithTag:502];
    UILabel *txtDesc = (UILabel *)[cell viewWithTag:503];
    
    cell.tag = indexPath.row;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointStoreTableGroupMember *member = [appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members objectAtIndex:indexPath.row];
    
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
        self.indexOfMemberMe = indexPath;
        if (member.payingUserId.longLongValue == member.userId.longLongValue)
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    if (appDelegate.globalObjectHolder.currentUser.identifier.longLongValue == member.payingUserId.longLongValue)
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    txtDesc.text = [self payingForStringForRow:indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointStoreTableGroupMember *member = [appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members objectAtIndex:indexPath.row];
    if (self.indexOfMemberMe.row == indexPath.row)
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        member.payingUserId = member.userId;
        member.payingFor = [NSNumber numberWithInt:1];
        [self.changedMembers setObject:member forKey:indexPath];
        UILabel *txtDesc = (UILabel *)[cell viewWithTag:503];
        txtDesc.text = [self payingForStringForRow:indexPath.row];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        UITableViewCell *cellMe = [self.tableView cellForRowAtIndexPath:self.indexOfMemberMe];
        GTLStoreendpointStoreTableGroupMember *memberMe = appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.memberMe;
        if (cellMe.accessoryType == UITableViewCellAccessoryNone)
        {
            [cellMe setAccessoryType:UITableViewCellAccessoryCheckmark];
            memberMe.payingUserId = memberMe.userId;
            memberMe.payingFor = [NSNumber numberWithInt:1];
            [self.changedMembers setObject:memberMe forKey:self.indexOfMemberMe];
        }

        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            member.payingUserId = member.userId;
            member.payingFor = [NSNumber numberWithInt:1];
            memberMe.payingFor = [NSNumber numberWithInt:(memberMe.payingFor.intValue - 1)];
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            member.payingUserId = memberMe.userId;
            member.payingFor = [NSNumber numberWithInt:0];
            memberMe.payingFor = [NSNumber numberWithInt:(memberMe.payingFor.intValue + 1)];
        }
        [self.changedMembers setObject:member forKey:indexPath];
        [self.changedMembers setObject:memberMe forKey:self.indexOfMemberMe];
        UILabel *txtDesc = (UILabel *)[cell viewWithTag:503];
        txtDesc.text = [self payingForStringForRow:indexPath.row];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        txtDesc = (UILabel *)[cellMe viewWithTag:503];
        txtDesc.text = [self payingForStringForRow:self.indexOfMemberMe.row];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.indexOfMemberMe] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSString *)payingForStringForRow:(NSUInteger)row
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointStoreTableGroupMember *payingMember = [appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members objectAtIndex:row];
    long long payingUserId = payingMember.userId.longLongValue;
    
    int payingForCount = 0;
    for (GTLStoreendpointStoreTableGroupMember *member in appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members)
    {
        if (member.payingUserId.longLongValue == payingUserId)
            payingForCount++;
    }
    payingMember.payingFor = [NSNumber numberWithInt:payingForCount];
    if (payingMember.payingFor.intValue > 0)
        return [NSString stringWithFormat:@"Paying for %d of %lu", payingMember.payingFor.intValue, (unsigned long)appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members.count];
    
    for (GTLStoreendpointStoreTableGroupMember *otherMember in appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members)
    {
        if (otherMember.userId.longLongValue == payingMember.payingUserId.longLongValue)
            return [NSString stringWithFormat:@"Paid by %@ %@", otherMember.firstName, otherMember.lastName];
    }
    return nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    // Get reference to the destination view controller
//    if ([[segue identifier] isEqualToString:@"segueSplitEvenlyToPay"])
//    {
//        [self updateStoreTableGroupMembers];
//    }
}

@end
