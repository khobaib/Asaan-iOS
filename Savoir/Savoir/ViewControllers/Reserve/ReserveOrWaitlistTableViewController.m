//
//  ReserveOrWaitlistTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/9/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ReserveOrWaitlistTableViewController.h"
#import "ReserveTableViewController.h"
#import "WaitlistTableViewController.h"
#import "AppDelegate.h"
#import "UIAlertView+Blocks.h"
#import "UtilCalls.h"

@interface ReserveOrWaitlistTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *txtReserve;
@property (weak, nonatomic) IBOutlet UILabel *txtWaitlist;

@end

@implementation ReserveOrWaitlistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.selectedStore.providesReservation.boolValue == false)
    {
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSString *strMsg = [NSString stringWithFormat:@"Reserve: %@ does not support reservations through Savoir", self.selectedStore.name];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:strMsg attributes:attributes];
        
        self.txtReserve.attributedText = attributedString;
    }
    if (self.selectedStore.providesWaitlist.boolValue == false)
    {
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSString *strMsg = [NSString stringWithFormat:@"Wait list: %@ does not support wait listing through Savoir", self.selectedStore.name];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:strMsg attributes:attributes];
        
        self.txtWaitlist.attributedText = attributedString;
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        if (self.selectedStore.providesReservation.boolValue == false)
            return;

        [self performSegueWithIdentifier:@"segueReserveAndWaitlistToReserve" sender:self];
    }
    else if (indexPath.row == 1)
    {
        if (self.selectedStore.providesWaitlist.boolValue == false)
            return;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        if (appDelegate.globalObjectHolder.queueEntry != nil)
        {
            NSString *errMsg = [NSString stringWithFormat:@"You are joining the wait list at a new restaurant. Do you want to remove yourself from %@'s wait list?", appDelegate.globalObjectHolder.queueEntry.storeName];
            [UIAlertView showWithTitle:@"Leave your current wait-list?" message:errMsg cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 if (buttonIndex == [alertView cancelButtonIndex])
                     return;
                 else
                 {
                     [appDelegate.globalObjectHolder removeWaitListQueueEntry];
                     [self performSegueWithIdentifier:@"segueReserveAndWaitlistToWaitlist" sender:self];
                 }
             }];
        }
        else
            [self performSegueWithIdentifier:@"segueReserveAndWaitlistToWaitlist" sender:self];
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UtilCalls setupStaticHeaderViewForTable:tableView WithTitle:self.selectedStore.name AndSubTitle:@"Welcome. Let's find a table for you."];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"segueReserveAndWaitlistToReserve"])
    {
        ReserveTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
    }
    else if ([[segue identifier] isEqualToString:@"segueReserveAndWaitlistToWaitlist"])
    {
        WaitlistTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
    }
}

@end