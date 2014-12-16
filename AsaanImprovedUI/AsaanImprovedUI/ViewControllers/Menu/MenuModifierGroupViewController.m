//
//  MenuModifierGroupViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MenuModifierGroupViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "InlineCalls.h"
#import "GTLStoreendpointStoreMenuItemModifierGroup.h"
#import "GTLStoreendpointStoreMenuItemModifier.h"
#import "MenuModifierTableViewController.h"
#import "OnlineOrderSelectedModifierGroup.h"


@interface MenuModifierGroupViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *txtMenuItemName;
@property (weak, nonatomic) IBOutlet UILabel *txtAmount;
@property (weak, nonatomic) IBOutlet UILabel *txtQty;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *txtSpecialInstructions;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToOrder;
@property (strong, nonatomic) GTLStoreendpointStoreMenuItemModifierGroup *selectedModifierGroup;
@property (strong, nonatomic) NSIndexPath *selectedRow;
@property (strong, nonatomic) OnlineOrderSelectedMenuItem *onlineOrderSelectedMenuItem;
@property (strong, nonatomic) GTLStoreendpointMenuItemModifiersAndGroups *gtlModifiersAndGroups;

@end

@implementation MenuModifierGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    _onlineOrderSelectedMenuItem = [[OnlineOrderSelectedMenuItem alloc]init];
    
    if (self.bInEditMode == NO)
    {
        _onlineOrderSelectedMenuItem.selectedItem = self.selectedMenuItem;
        _onlineOrderSelectedMenuItem.selectedStore = self.selectedStore;
        _onlineOrderSelectedMenuItem.selectedModifierGroups = [[NSMutableArray alloc]init];
        _onlineOrderSelectedMenuItem.qty = 1;
        _onlineOrderSelectedMenuItem.price = self.selectedMenuItem.price.longValue;
        _onlineOrderSelectedMenuItem.amount = _onlineOrderSelectedMenuItem.price*_onlineOrderSelectedMenuItem.qty;
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        OnlineOrderDetails *orderInProgress = appDelegate.globalObjectHolder.orderInProgress;
        if (orderInProgress != nil)
        {
            OnlineOrderSelectedMenuItem *currentSelectedMenu = [orderInProgress.selectedMenuItems objectAtIndex:self.selectedIndex];
            _onlineOrderSelectedMenuItem.selectedItem = currentSelectedMenu.selectedItem;
            _onlineOrderSelectedMenuItem.selectedStore = currentSelectedMenu.selectedStore;
            _onlineOrderSelectedMenuItem.selectedModifierGroups = [[NSMutableArray alloc]initWithArray:currentSelectedMenu.selectedModifierGroups copyItems:YES];
            _onlineOrderSelectedMenuItem.qty = currentSelectedMenu.qty;
            _onlineOrderSelectedMenuItem.price = currentSelectedMenu.price;
            _onlineOrderSelectedMenuItem.amount = currentSelectedMenu.amount;
            self.gtlModifiersAndGroups = _onlineOrderSelectedMenuItem.allModifiersAndGroups = currentSelectedMenu.allModifiersAndGroups;
        }
    }
    self.txtMenuItemName.text = _onlineOrderSelectedMenuItem.selectedItem.shortDescription;
    NSNumber *amount = [[NSNumber alloc] initWithLong:_onlineOrderSelectedMenuItem.amount];
    _onlineOrderSelectedMenuItem.amount = amount.longValue;
    self.txtAmount.text = [UtilCalls amountToString:amount];
    if (self.bInEditMode == YES)
        [self.btnAddToOrder setTitle:[NSString stringWithFormat:@"Change Order - %@", self.txtAmount.text] forState:UIControlStateNormal];
    else
        [self.btnAddToOrder setTitle:[NSString stringWithFormat:@"Add to Order - %@", self.txtAmount.text] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationItem.title = _onlineOrderSelectedMenuItem.selectedItem.shortDescription;
    if (_onlineOrderSelectedMenuItem.selectedItem.hasModifiers.boolValue == true)
        [self getModifierGroupsAndModifiers];
}

- (void) getModifierGroupsAndModifiers
{
    if (_gtlModifiersAndGroups != nil) return;
    typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreMenuItemModifiersWithStoreId:_onlineOrderSelectedMenuItem.selectedStore.identifier.longValue menuItemPOSId:_onlineOrderSelectedMenuItem.selectedItem.menuItemPOSId.longValue];
    
    NSLog(@"storeid=%ld, menuitemposid=%ld", _onlineOrderSelectedMenuItem.selectedStore.identifier.longValue, _onlineOrderSelectedMenuItem.selectedItem.menuItemPOSId.longValue);
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
     {
         if (!error)
         {
             weakSelf.gtlModifiersAndGroups = object;
             [weakSelf.tableView reloadData];
         }
         else
         {
             NSString *errMsg = [NSString stringWithFormat:@"%@", [error userInfo]];
             UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Asaan Server Access Failure" message:errMsg delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             
             [alert show];
             return;
         }
     }];
}

- (void) updatePriceAndTable
{
    if (_onlineOrderSelectedMenuItem.selectedModifierGroups.count > 0)
    {
        long finalPrice = _onlineOrderSelectedMenuItem.selectedItem.price.longValue;
        for (OnlineOrderSelectedModifierGroup *modifierGroup in _onlineOrderSelectedMenuItem.selectedModifierGroups)
        {
            for (int i = 0; i < modifierGroup.selectedModifierIndexes.count; i++)
            {
                NSNumber *isSelected = [modifierGroup.selectedModifierIndexes objectAtIndex:i];
                if (isSelected.boolValue == YES)
                {
                    GTLStoreendpointStoreMenuItemModifier *modifier = [modifierGroup.modifiers objectAtIndex:i];
                    if (modifier.price.longValue > 0)
                        finalPrice += modifier.price.longValue;
                }
            }
        }
        _onlineOrderSelectedMenuItem.price = finalPrice;
        _onlineOrderSelectedMenuItem.amount = _onlineOrderSelectedMenuItem.price*_onlineOrderSelectedMenuItem.qty;
        _onlineOrderSelectedMenuItem.qty = _onlineOrderSelectedMenuItem.qty;
        _onlineOrderSelectedMenuItem.amount = _onlineOrderSelectedMenuItem.price*_onlineOrderSelectedMenuItem.qty;
        NSNumber *amount = [[NSNumber alloc] initWithLong: _onlineOrderSelectedMenuItem.amount];
        self.txtAmount.text = [UtilCalls amountToString:amount];
        if (self.bInEditMode == YES)
            [self.btnAddToOrder setTitle:[NSString stringWithFormat:@"Change Order - %@", self.txtAmount.text] forState:UIControlStateNormal];
        else
            [self.btnAddToOrder setTitle:[NSString stringWithFormat:@"Add to Order - %@", self.txtAmount.text] forState:UIControlStateNormal];
        [self.tableView reloadData];
    }
}

- (NSString*) updateDescriptionForModifierGroup:(GTLStoreendpointStoreMenuItemModifierGroup *)group
{
    if (_onlineOrderSelectedMenuItem == nil || _onlineOrderSelectedMenuItem.selectedModifierGroups == nil)
        return nil;
    
    NSString *description;
    for (OnlineOrderSelectedModifierGroup *modifierGroup in _onlineOrderSelectedMenuItem.selectedModifierGroups)
    {
        if (group.modifierGroupPOSId.longValue == modifierGroup.modifierGroup.modifierGroupPOSId.longValue)
        {
            for (int i = 0; i < modifierGroup.selectedModifierIndexes.count; i++)
            {
                NSNumber *isSelected = [modifierGroup.selectedModifierIndexes objectAtIndex:i];
                if (isSelected.boolValue == YES)
                {
                    GTLStoreendpointStoreMenuItemModifier *modifier = [modifierGroup.modifiers objectAtIndex:i];
                    if (modifier.price.longValue > 0)
                    {
                        if (IsEmpty(description) == false)
                            description = [description stringByAppendingString:[NSString stringWithFormat:@", %@ (+%@)", modifier.shortDescription, [UtilCalls amountToString:modifier.price]]];
                        else
                            description = [NSString stringWithFormat:@"%@ (+%@)", modifier.shortDescription, [UtilCalls amountToString:modifier.price]];
                    }
                    else
                    {
                        if (IsEmpty(description) == false)
                            description = [description stringByAppendingString:[NSString stringWithFormat:@", %@", modifier.shortDescription]];
                        else
                            description = [NSString stringWithFormat:@"%@", modifier.shortDescription];
                    }
                }
            }
        }
    }
    return description;
}

#pragma mark -
#pragma mark  === UITableViewDataSource ===
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_gtlModifiersAndGroups == nil || _gtlModifiersAndGroups.modifierGroups.count == 0)
        return 0;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_gtlModifiersAndGroups == nil || _gtlModifiersAndGroups.modifierGroups.count == 0)
        return 0;
    else
        return _gtlModifiersAndGroups.modifierGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ModifierGroupCell" forIndexPath:indexPath];
    GTLStoreendpointStoreMenuItemModifierGroup *modGroup = [_gtlModifiersAndGroups.modifierGroups objectAtIndex:indexPath.row];
    cell.textLabel.text = modGroup.modifierGroupShortDescription;
    cell.detailTextLabel.text = [self updateDescriptionForModifierGroup:modGroup];
    return cell;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath;
    _selectedModifierGroup = [_gtlModifiersAndGroups.modifierGroups objectAtIndex:indexPath.row];
    
    if (_selectedModifierGroup != nil)
    {
        _allModifiersForSelectedGroup = [[NSMutableArray alloc]init];
        for (GTLStoreendpointStoreMenuItemModifier *object in _gtlModifiersAndGroups.modifiers)
            if (object.modifierGroupPOSId.longValue == _selectedModifierGroup.modifierGroupPOSId.longValue)
                [_allModifiersForSelectedGroup addObject:object];

        [self performSegueWithIdentifier:@"segueGroupToModifier" sender:self];
    }
}

- (IBAction)incQty:(id)sender
{
    _onlineOrderSelectedMenuItem.qty++;
    _onlineOrderSelectedMenuItem.amount = _onlineOrderSelectedMenuItem.price*_onlineOrderSelectedMenuItem.qty;
    NSNumber *amount = [[NSNumber alloc] initWithLong: _onlineOrderSelectedMenuItem.amount];
    self.txtAmount.text = [UtilCalls amountToString:amount];
    if (self.bInEditMode == YES)
        [self.btnAddToOrder setTitle:[NSString stringWithFormat:@"Change Order - %@", self.txtAmount.text] forState:UIControlStateNormal];
    else
        [self.btnAddToOrder setTitle:[NSString stringWithFormat:@"Add to Order - %@", self.txtAmount.text] forState:UIControlStateNormal];
    self.txtQty.text = [NSString stringWithFormat:@"%lu", (unsigned long)_onlineOrderSelectedMenuItem.qty];
}
- (IBAction)decQty:(id)sender
{
    if (_onlineOrderSelectedMenuItem.qty > 1)
    {
        _onlineOrderSelectedMenuItem.qty--;
        _onlineOrderSelectedMenuItem.amount = _onlineOrderSelectedMenuItem.price*_onlineOrderSelectedMenuItem.qty;
        NSNumber *amount = [[NSNumber alloc] initWithLong: _onlineOrderSelectedMenuItem.amount];
        self.txtAmount.text = [UtilCalls amountToString:amount];
        if (self.bInEditMode == YES)
            [self.btnAddToOrder setTitle:[NSString stringWithFormat:@"Change Order - %@", self.txtAmount.text] forState:UIControlStateNormal];
        else
            [self.btnAddToOrder setTitle:[NSString stringWithFormat:@"Add to Order - %@", self.txtAmount.text] forState:UIControlStateNormal];
        self.txtQty.text = [NSString stringWithFormat:@"%lu", (unsigned long)_onlineOrderSelectedMenuItem.qty];
    }
    
}
- (IBAction)addToOrder:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    OnlineOrderDetails *orderInProgress = appDelegate.globalObjectHolder.orderInProgress;
    
    if (self.bInEditMode == YES)
    {
        [orderInProgress.selectedMenuItems replaceObjectAtIndex:self.selectedIndex withObject:self.onlineOrderSelectedMenuItem];
        [self performSegueWithIdentifier:@"unwindModifierGroupToOrderSummary" sender:self];
        return;
    }

    if (orderInProgress == nil)
    {
        orderInProgress = [appDelegate.globalObjectHolder createOrderInProgress];
        orderInProgress.selectedStore = _onlineOrderSelectedMenuItem.selectedStore;
        orderInProgress.orderType = self.orderType;
        orderInProgress.orderTime = self.orderTime;
        orderInProgress.partySize = self.partySize;
        [orderInProgress.selectedMenuItems addObject:self.onlineOrderSelectedMenuItem];
        [self performSegueWithIdentifier:@"segueunwindModifierGroupToMenu" sender:self];
    }
    else
    {
        [orderInProgress.selectedMenuItems addObject:self.onlineOrderSelectedMenuItem];
        [self performSegueWithIdentifier:@"segueunwindModifierGroupToMenu" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueGroupToModifier"])
    {
        MenuModifierTableViewController *controller = [segue destinationViewController];
        [controller setModifierGroup:self.selectedModifierGroup];
        [controller setAllModifiers:self.allModifiersForSelectedGroup];
        OnlineOrderSelectedModifierGroup *savedModifierGroup;
        for (OnlineOrderSelectedModifierGroup *object in _onlineOrderSelectedMenuItem.selectedModifierGroups)
        {
            if (object.modifierGroup.modifierGroupPOSId.longValue == controller.modifierGroup.modifierGroupPOSId.longValue)
            {
                savedModifierGroup = object;
                break;
            }
        }
        if (savedModifierGroup != nil)
            [controller setAllSelections:savedModifierGroup.selectedModifierIndexes];
    }
}

- (IBAction)unwindModifierToModifierGroup:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"Back to SelectPaymentTableViewController");
    UIViewController *cc = [unwindSegue sourceViewController];

    if ([cc isKindOfClass:[MenuModifierTableViewController class]])
    {
        MenuModifierTableViewController *controller = (MenuModifierTableViewController *)cc;
        
        if (controller.allSelections == nil || controller.allSelections.count == 0)
            return;

        OnlineOrderSelectedModifierGroup *savedModifierGroup;
        Boolean bFound = NO;
        for (OnlineOrderSelectedModifierGroup *object in _onlineOrderSelectedMenuItem.selectedModifierGroups)
        {
            if (object.modifierGroup.modifierGroupPOSId.longValue == controller.modifierGroup.modifierGroupPOSId.longValue)
            {
                savedModifierGroup = object;
                bFound = YES;
                break;
            }
        }
        if (savedModifierGroup == nil)
            savedModifierGroup = [[OnlineOrderSelectedModifierGroup alloc]init];
        
        savedModifierGroup.modifierGroup = controller.modifierGroup;
        savedModifierGroup.modifiers = controller.allModifiers;
        savedModifierGroup.selectedModifierIndexes = controller.allSelections;
        
        if (bFound == NO)
            [_onlineOrderSelectedMenuItem.selectedModifierGroups addObject:savedModifierGroup];
        
        [self updatePriceAndTable];
    }
}
@end
