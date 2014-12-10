//
//  MenuTableViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MenuTableViewController.h"
#import "MenuModifierGroupViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "GTLStoreendpoint.h"
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "UIColor+AsaanGoldColor.h"
#import "DataProvider.h"
#import "DropdownView.h"
//#import "UIImageView+WebCache.h"
#import "MenuItemLoadingOperation.h"
#import "MenuSegmentHolder.h"
#import "UIColor+AsaanBackgroundColor.h"

#import "MenuItemCell.h"
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MenuMWCaptionView.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "Extension.h"
#import "GlobalObjectHolder.h"


const NSUInteger MenuFluentPagingTablePreloadMargin = 5;
const NSUInteger MenuFluentPagingTablePageSize = 50;

@interface MenuTableViewController() <DataProviderDelegate, DropdownViewDelegate, MWPhotoBrowserDelegate, MenuItemCellDelegate, MenuMWCaptionViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic) NSInteger segmentedControlSelectedIndex;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) int startPosition;
@property (nonatomic) int maxResult;
@property (strong, nonatomic) NSMutableArray *menuSegmentHolders;
@property (strong, nonatomic) GTLStoreendpointStoreMenuItem *selectedMenuItem;

- (void) showOrderSummaryPressed;

@end

@implementation MenuTableViewController

@synthesize tableView = _tableView;
@synthesize segmentedControl = _segmentedControl;
@synthesize segmentedControlSelectedIndex = _segmentedControlSelectedIndex;
@synthesize startPosition = _startPosition;
@synthesize maxResult = _maxResult;
@synthesize dataProvider = _dataProvider;
@synthesize menuSegmentHolders = _menuSegmentHolders;
@synthesize selectedStore = _selectedStore;

static NSString *SubMenuCellIdentifier = @"SubMenuCell";
static NSString *MenuItemCellIdentifier = @"MenuItemCell";

#pragma mark -
#pragma mark === View Life Cycle ===
#pragma mark -

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupMenuSegmentController];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor goldColor]};
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
    if (goh.orderInProgress != nil)
    {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cart.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showOrderSummaryPressed)];
        [self.navigationItem setRightBarButtonItem:item animated:YES];
    }
}

- (void) showOrderSummaryPressed
{
    [self performSegueWithIdentifier:@"segueMenuToOrderSummary" sender:self];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark === Private Methods ===
#pragma mark -



#pragma mark -
#pragma mark === Actions ===
#pragma mark -

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (IBAction)segmentControllerValueChanged:(id)sender
{
    MenuSegmentHolder *oldMenuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControlSelectedIndex];
    NSIndexPath *firstVisibleIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    oldMenuSegmentHolder.topRowIndex = firstVisibleIndexPath;
    
    _segmentedControlSelectedIndex = _segmentedControl.selectedSegmentIndex;
    MenuSegmentHolder *newMenuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControlSelectedIndex];
    firstVisibleIndexPath = newMenuSegmentHolder.topRowIndex;
    
    [_tableView scrollToRowAtIndexPath:firstVisibleIndexPath
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:NO];
    [_tableView reloadData];
}

- (void)setupMenuSegmentController {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    _menuSegmentHolders = [[NSMutableArray alloc] init];
    
    if (self)
    {
        typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreMenuHierarchyAndItemsWithStoreId:self.selectedStore.identifier.longValue menuType:0 maxResult:MenuFluentPagingTablePageSize];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointMenusAndMenuItems *object,NSError *error)
         {
             if(!error && object.menuItems.count > 0 && object.menusAndSubmenus.count > 0){
                 GTLStoreendpointStoreMenuItem *menuItem = [object.menuItems firstObject];
                 for (GTLStoreendpointStoreMenuHierarchy *menu in object.menusAndSubmenus)
                 {
                     if (menu.level.intValue == 0)
                     {
                         MenuSegmentHolder *menuSegmentHolder = [[MenuSegmentHolder alloc]init];
                         menuSegmentHolder.menu = menu;
                         menuSegmentHolder.subMenus = [[NSMutableArray alloc] init];
                         
                         for (GTLStoreendpointStoreMenuHierarchy *submenu in object.menusAndSubmenus)
                         {
                             if (submenu.level.intValue == 1 && submenu.menuPOSId.longValue == menu.menuPOSId.longValue)
                             {
                                 [menuSegmentHolder.subMenus addObject:submenu];
                             }
                         }
                         
                         menuSegmentHolder.provider = [[DataProvider alloc] initWithPageSize:object.menuItems.count itemCount:menu.menuItemCount.integerValue];
                         menuSegmentHolder.provider.delegate = weakSelf;
                         menuSegmentHolder.provider.shouldLoadAutomatically = YES;
                         menuSegmentHolder.provider.automaticPreloadMargin = MenuFluentPagingTablePreloadMargin;
                         menuSegmentHolder.topRowIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                         [_menuSegmentHolders addObject:menuSegmentHolder];
                         if (menu.menuPOSId.longValue == menuItem.menuPOSId.longValue)
                             [menuSegmentHolder.provider setInitialObjects:object.menuItems ForPage:0];
                     }
                 }
                 
             }else{
                 NSLog(@"StoreLoadingOperation Error:%@",[error userInfo]);
             }
             
             if (_menuSegmentHolders.count == 1)
             {
                 MenuSegmentHolder *menuSegmentHolder = [_menuSegmentHolders firstObject];
                 weakSelf.navigationItem.title = menuSegmentHolder.menu.name;
             }
             else
             {
                 _segmentedControl = [[UISegmentedControl alloc] init];
                 [_segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
                 UIFont *font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
                 NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
                 [_segmentedControl setTitleTextAttributes:attributes
                                                  forState:UIControlStateNormal];
                 self.navigationItem.titleView = _segmentedControl;
                 
                 for (MenuSegmentHolder *menuSegmentHolder in _menuSegmentHolders) {
                     [_segmentedControl insertSegmentWithTitle:menuSegmentHolder.menu.name atIndex:_segmentedControl.numberOfSegments animated:NO];
                 }
                 
                 [_segmentedControl sizeToFit];
                 [_segmentedControl addTarget:self
                                       action:@selector(segmentControllerValueChanged:)
                             forControlEvents:UIControlEventValueChanged];
                 _segmentedControlSelectedIndex = 0;
                 [_segmentedControl setSelectedSegmentIndex:_segmentedControlSelectedIndex];
                 _segmentedControl.apportionsSegmentWidthsByContent = YES;
             }
             [weakSelf.tableView reloadData];
             hud.hidden = YES;
         }];
    }
}

#pragma mark -
#pragma mark  === DropdownViewDelegate ===
#pragma mark -

- (void)dropdownViewActionForSelectedRow:(int)row sender:(id)sender
{
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:row]
                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)setupDropdownView:(DropdownView *)dropdownView
{
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    
    NSMutableArray *subMenuNames = [[NSMutableArray alloc]initWithCapacity:menuSegmentHolder.subMenus.count];
    for (GTLStoreendpointStoreMenuHierarchy *submenu in menuSegmentHolder.subMenus)
        [subMenuNames addObject:submenu.name];
    
    [dropdownView refresh];
    [dropdownView setData:subMenuNames];
    dropdownView.delegate = self;
    dropdownView.listBackgroundColor = [UIColor asaanBackgroundColor];
    dropdownView.titleColor = [UIColor whiteColor];
    dropdownView.enabledTitle = false;
    dropdownView.enabledCheckmark = false;
}

#pragma mark -
#pragma mark  === DataProviderDelegate ===
#pragma mark -

- (void)dataProvider:(DataProvider *)dataProvider didLoadDataAtIndexes:(NSIndexSet *)indexes
{
    
    NSMutableArray *indexPathsToReload = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        
        if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
            [indexPathsToReload addObject:indexPath];
        }
    }];
    
    if (indexPathsToReload.count > 0) {
        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.hud hide:YES];
}

- (DataLoadingOperation *) getDataLoadingOperationForPage:(NSUInteger)page indexes:(NSIndexSet *)indexes
{
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    long storeId = menuSegmentHolder.menu.storeId.longValue;
    long menuPOSId = menuSegmentHolder.menu.menuPOSId.longValue;
    MenuItemLoadingOperation *milo = [[MenuItemLoadingOperation alloc] initWithIndexes:indexes storeId:storeId menuPOSId:menuPOSId];
    return milo;
}

- (void)dataProvider:(DataProvider *)dataProvider willLoadDataAtIndexes:(NSIndexSet *)indexes
{
    [self.hud hide:NO];
}

#pragma mark -
#pragma mark  === UITableViewDataSource ===
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_menuSegmentHolders == nil || _menuSegmentHolders.count == 0)
        return 0;
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    return menuSegmentHolder.subMenus.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_menuSegmentHolders == nil || _menuSegmentHolders.count == 0)
        return 0;
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    GTLStoreendpointStoreMenuHierarchy *submenu = [menuSegmentHolder.subMenus objectAtIndex:section];
    return submenu.menuItemCount.integerValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    
    GTLStoreendpointStoreMenuHierarchy *submenu = [menuSegmentHolder.subMenus objectAtIndex:indexPath.section];
    NSInteger rowIndex = submenu.menuItemPosition.intValue + indexPath.row + 1;
    
    MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:MenuItemCellIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.text = nil;
    cell.descriptionLabel.text = nil;
    cell.todaysOrdersLabels.text = nil;
    cell.likesLabel.text = nil;
    cell.likeImageView.image = nil;
    cell.priceLabel.text = nil;
    cell.mostOrderedLabel.text = nil;
    
    id dataObject = menuSegmentHolder.provider.dataObjects[rowIndex];
    if ([dataObject isKindOfClass:[NSNull class]])
        return cell;
    
    GTLStoreendpointStoreMenuItem *menuItem = dataObject;
    
    cell.titleLabel.text = menuItem.shortDescription;
    cell.descriptionLabel.text = menuItem.longDescription;
    cell.priceLabel.text = [UtilCalls amountToString:menuItem.price];
    
    cell.delegate = self;
    cell.itemImageView.tag = rowIndex - indexPath.section - 1;
    
    NSLog(@"Test yy %d %ld %ld", submenu.menuItemPosition.intValue, (long)indexPath.row, (long)indexPath.section);
    
    if (IsEmpty(menuItem.thumbnailUrl) == false)
    {
        //        [cell.itemPFImageView sd_setImageWithURL:[NSURL URLWithString:menuItem.thumbnailUrl]];
        [cell.itemImageView setImageWithURL:[NSURL URLWithString:menuItem.thumbnailUrl]
                             placeholderImage:[UIImage imageWithColor:RGBA(0.0, 0.0, 0.0, 0.5)]
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                        if (error) {
                                            NSLog(@"ERROR : %@", error);
                                        }
                                    }
                  usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    else {
        cell.itemImageView.image = [UIImage imageNamed:@"no_image"];
    }
    
    return cell;
}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    GTLStoreendpointStoreMenuHierarchy *submenu = [menuSegmentHolder.subMenus objectAtIndex:section];
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:SubMenuCellIdentifier];
    if (headerView == nil){
        [NSException raise:@"headerView == nil.." format:@"No cells with matching SubMenuCellIdentifier loaded from your storyboard"];
    }
    UILabel *txtName=(UILabel *)[headerView viewWithTag:401];
    txtName.text = submenu.name;
    DropdownView *dropdownView = (DropdownView*)[headerView  viewWithTag:402];
    [self setupDropdownView:dropdownView];
    return headerView;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.savedUserCard isKindOfClass:[GTLUserendpointUserCard class]]) // Menu is in Order Mode
    {
        MenuSegmentHolder *menuSegmentHolder;
        if (_menuSegmentHolders.count > 1)
            menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
        else
            menuSegmentHolder = [_menuSegmentHolders firstObject];
        
        GTLStoreendpointStoreMenuHierarchy *submenu = [menuSegmentHolder.subMenus objectAtIndex:indexPath.section];
        NSInteger rowIndex = submenu.menuItemPosition.intValue + indexPath.row + 1;
        
        id dataObject = menuSegmentHolder.provider.dataObjects[rowIndex];
        if (![dataObject isKindOfClass:[NSNull class]])
        {
            self.selectedMenuItem = dataObject;
            [self performSegueWithIdentifier:@"segueMenuToModifierGroup" sender:self];
        }
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    MenuSegmentHolder *menuSegmentHolder;
//    if (_menuSegmentHolders.count > 1)
//        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
//    else
//        menuSegmentHolder = [_menuSegmentHolders firstObject];
//
//    NSLog(@"heightForRowAtIndexPath index = %d", indexPath.row);
//    id dataObject = menuSegmentHolder.provider.dataObjects[indexPath.row];
//    UITableViewCell *cell;
//
//    if ([dataObject isKindOfClass:[NSNull class]])
//    {
//        [self configureSubMenuCell:self.prototypeSubMenuCell forRowAtIndexPath:indexPath withItem:dataObject];
//        cell = self.prototypeSubMenuCell;
//    }
//    else
//    {
//        GTLStoreendpointStoreMenuItem *menuItem = dataObject;
//
//        if (menuItem.level.intValue == 1)
//        {
//            [self configureSubMenuCell:self.prototypeSubMenuCell forRowAtIndexPath:indexPath withItem:menuItem];
//            cell = self.prototypeSubMenuCell;
//        }
//        else
//        {
//            [self configureMenuItemCell:self.prototypeMenuItemCell forRowAtIndexPath:indexPath withItem:menuItem];
//            cell = self.prototypeMenuItemCell;
//        }
//    }
//
//    // Need to set the width of the prototype cell to the width of the table view
//    // as this will change when the device is rotated.
//
//    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(cell.bounds));
//
//    [cell layoutIfNeeded];
//
//    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    return size.height+1;
//}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark -
#pragma mark === MWPhotoBrowserDelegate ===
#pragma mark -

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    if (_menuSegmentHolders == nil || _menuSegmentHolders.count == 0)
        return 0;
    
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    
    int sum = 0;
    for (GTLStoreendpointStoreMenuHierarchy *submenu in menuSegmentHolder.subMenus) {
        sum += submenu.menuItemCount.integerValue;
    }
    
    return sum;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    if (_menuSegmentHolders == nil || _menuSegmentHolders.count == 0)
        return nil;
    
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    
    if (menuSegmentHolder.provider.dataObjects.count == 0 && index >= menuSegmentHolder.provider.dataObjects.count) {
        return nil;
    }
    
    int sum = 0;
    int section = 0;
    for (GTLStoreendpointStoreMenuHierarchy *submenu in menuSegmentHolder.subMenus) {
        
        sum += submenu.menuItemCount.integerValue;
        
        if (index < sum) {
            break;
        }
        section += 1;
    }
    
    NSLog(@"Test %lu %d %d", (unsigned long)index, sum, section);
    
    //    GTLStoreendpointStoreMenuHierarchy *submenu = [menuSegmentHolder.subMenus objectAtIndex:section];
    NSInteger rowIndex = section + index + 1;
    id dataObject = menuSegmentHolder.provider.dataObjects[rowIndex];
    if ([dataObject isKindOfClass:[NSNull class]])
        return nil;
    
    GTLStoreendpointStoreMenuItem *menuItem = dataObject;
    MWPhoto *photo = nil;
    
    if (IsEmpty(menuItem.imageUrl) == false)
    {
        //        photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1011283712_5750c5ba8e_b.jpg"]];
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:menuItem.imageUrl]];
    }
    else {
        photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"no_image_big" ofType:@"png"]]];
        //        photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1011283712_5750c5ba8e_b.jpg"]];
    }
    
    return photo;
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
    
    if (_menuSegmentHolders == nil || _menuSegmentHolders.count == 0)
        return nil;
    
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    
    if (menuSegmentHolder.provider.dataObjects.count == 0 && index >= menuSegmentHolder.provider.dataObjects.count) {
        return nil;
    }
    
    int sum = 0;
    int section = 0;
    for (GTLStoreendpointStoreMenuHierarchy *submenu in menuSegmentHolder.subMenus) {
        
        sum += submenu.menuItemCount.integerValue;
        
        if (index < sum) {
            break;
        }
        section += 1;
    }
    
    //    GTLStoreendpointStoreMenuHierarchy *submenu = [menuSegmentHolder.subMenus objectAtIndex:section];
    NSInteger rowIndex = section + index + 1;
    id dataObject = menuSegmentHolder.provider.dataObjects[rowIndex];
    if ([dataObject isKindOfClass:[NSNull class]])
        return nil;
    
    GTLStoreendpointStoreMenuItem *menuItem = dataObject;
    MWPhoto *photo = nil;
    
    if (IsEmpty(menuItem.imageUrl) == false)
    {
        //        photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1011283712_5750c5ba8e_b.jpg"]];
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:menuItem.imageUrl]];
    }
    else {
        photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"no_image_big" ofType:@"png"]]];
        //        photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1011283712_5750c5ba8e_b.jpg"]];
    }
    
    MenuMWCaptionView *captionView = [[MenuMWCaptionView alloc] initWithPhoto:photo];
    
    NSString *string = menuItem.shortDescription;
    if (string && ![string isEqualToString:@""]) {
        captionView.textTitle = string;
        
        //        captionView.textTitle = [NSString stringWithFormat:@"stringstringstringstringstringstring stringstringstringstring kjkljakjlkfjalkjlkjf \n jlkajlkdjfkj"];
    }
    
    string = [UtilCalls amountToString:menuItem.price];
    if (string && ![string isEqualToString:@""]) {
        captionView.textPrice = string;
    }
    
    string = menuItem.longDescription;
    if (string && ![string isEqualToString:@""]) {
        captionView.textDescription = string;
    }
    
    captionView.textTodaysOrders = @"18 peoples ordered today.";
    captionView.textMostOrdered = @"Most ordered";
    captionView.imageLike = [UIImage imageNamed:@"Like"];
    captionView.textLikes = @"1800";
    
#warning These are needed to enable/disable order button
    captionView.index = index;
    captionView.delegate = self;
    captionView.enabledOrderButton = true;
    
    return captionView;
}

#pragma mark -
#pragma mark === MenuItemCellDelegate ===
#pragma mark -

- (void)menuItemCell:(MenuItemCell *)menuItemCell didClickedItemImage:(UIImageView *)sender
{
    
    NSLog(@"Test gh %lu ", sender.tag);
    
    // Create browser (must be done each time photo browser is
    // displayed. Photo browser objects cannot be re-used)
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = NO; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
    
    // Manipulate
    [browser showNextPhotoAnimated:YES];
    [browser showPreviousPhotoAnimated:YES];
    [browser setCurrentPhotoIndex:sender.tag];
}

#pragma mark -
#pragma mark === MenuMWCaptionViewDelegate ===
#pragma mark -

#warning Use this to go to ordercontroller and here 'index' starts from 0;
- (void)menuMWCaptionView:(MenuMWCaptionView *)menuMWCaptionView didClickedOrderButtonAtIndex:(NSUInteger)index {
    
    NSLog(@"Tapped order button at index : %lu", index);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Get reference to the destination view controller
    if ([[segue identifier] isEqualToString:@"segueMenuToModifierGroup"])
    {
        MenuModifierGroupViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
        [controller setSelectedMenuItem:self.selectedMenuItem];
        [controller setSavedUserAddress:self.savedUserAddress];
        [controller setSavedUserCard:self.savedUserCard];
        [controller setOrderTime:self.orderTime];
        [controller setOrderType:self.orderType];
        [controller setPartySize:self.partySize];
    }
}

- (IBAction)unwindModifierGroupToMenu:(UIStoryboardSegue *)unwindSegue
{
}

@end
