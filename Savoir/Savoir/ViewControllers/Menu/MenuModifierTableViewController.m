//
//  MenuModifierTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MenuModifierTableViewController.h"
#import "UtilCalls.h"
#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "AppDelegate.h"

@interface MenuModifierTableViewController ()
@end

@implementation MenuModifierTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationItem.title = self.modifierGroup.modifierGroupShortDescription;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allModifiers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ModifierCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *txtTitle=(UILabel *)[cell viewWithTag:501];
    
    GTLStoreendpointStoreMenuItemModifier *modifier = [self.allModifiers objectAtIndex:indexPath.row];
    
    if (modifier.price.longLongValue > 0)
        txtTitle.text = [[[modifier.shortDescription stringByAppendingString:@" ("] stringByAppendingString:[UtilCalls amountToString:modifier.price]] stringByAppendingString:@")"];
    else
        txtTitle.text = modifier.shortDescription;
    
    if (self.allSelections != nil)
    {
        NSNumber *bVal = [self.allSelections objectAtIndex:indexPath.row];
        if (bVal.boolValue == YES)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.allSelections == nil)
    {
        self.allSelections = [NSMutableArray arrayWithCapacity:self.allModifiers.count];
        for(int i = 0; i < self.allModifiers.count; i++)
        {
            NSNumber *bVal = [[NSNumber alloc]initWithBool:NO];
            [self.allSelections addObject:bVal];
        }
    }
    if (self.modifierGroup.modifierGroupMaximum.longLongValue <= 1)
        [self tableView:tableView didSelectRowAtIndexPathForExclusive:indexPath];
    else
        [self tableView:tableView didSelectRowAtIndexPathForInclusive:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPathForExclusive:(NSIndexPath *)indexPath
{
    for (int i=0;i < self.allSelections.count; i++)
    {
        NSNumber *bVal = [self.allSelections objectAtIndex:i];
        if (bVal.boolValue == YES)
        {
            NSNumber *bVal = [[NSNumber alloc]initWithBool:NO];
            [_allSelections replaceObjectAtIndex:i withObject:bVal];
            
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
            if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark)
                oldCell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
    }
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone)
    {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSNumber *bVal = [[NSNumber alloc]initWithBool:YES];
        [_allSelections replaceObjectAtIndex:indexPath.row withObject:bVal];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPathForInclusive:(NSIndexPath *)newIndexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:newIndexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSNumber *bVal = [[NSNumber alloc]initWithBool:YES];
        [_allSelections replaceObjectAtIndex:newIndexPath.row withObject:bVal];
    }
    else if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSNumber *bVal = [[NSNumber alloc]initWithBool:NO];
        [_allSelections replaceObjectAtIndex:newIndexPath.row withObject:bVal];
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
