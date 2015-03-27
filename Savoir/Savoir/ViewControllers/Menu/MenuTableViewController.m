//
//  MenuTableViewController.m
//  Savoir
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
#import "UIColor+SavoirGoldColor.h"
#import "DataProvider.h"
#import "DropdownView.h"
//#import "UIImageView+WebCache.h"
#import "MenuItemLoadingOperation.h"
#import "MenuSegmentHolder.h"
#import "UIColor+SavoirBackgroundColor.h"

#import "MenuItemCell.h"
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MenuMWCaptionView.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "Extension.h"
#import "GlobalObjectHolder.h"
#import "UIView+Toast.h"


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
@property (strong, nonatomic) GTLStoreendpointMenuItemAndStats *selectedMenuItem;
@property (strong, nonatomic) NSMutableDictionary *allMenuStats;

@property (nonatomic) CGFloat cellHeight;

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
    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
//    {
//        self.tableView.rowHeight = UITableViewAutomaticDimension;
//        self.tableView.estimatedRowHeight = 160;
//    }
//    else
        self.cellHeight = 160;
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
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GlobalObjectHolder *goh = appDelegate.globalObjectHolder;
    if (goh.orderInProgress != nil)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"cart.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showOrderSummaryPressed) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 25, 25)];
        button.backgroundColor = [UIColor clearColor];
        
        //        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 5, 50, 20)];
        //        [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
        //        [label setText:@"Order"];
        //        label.textAlignment = UITextAlignmentCenter;
        //        [label setTextColor:[UIColor whiteColor]];
        //        [label setBackgroundColor:[UIColor clearColor]];
        //        [button addSubview:label];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = item;
    }
}
// As of iOS 8 Beta 5 you need to reload the table data on viewDidAppear.  YUK...
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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

- (void)setupMenuSegmentController {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    _menuSegmentHolders = [[NSMutableArray alloc] init];
    self.allMenuStats = [[NSMutableDictionary alloc] init];
    
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreMenuHierarchyAndItemsWithStoreId:self.selectedStore.identifier.longLongValue menuType:0 maxResult:MenuFluentPagingTablePageSize];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointMenusAndMenuItems *object,NSError *error)
         {
             if(!error && object.menuItems.count > 0 && object.menusAndSubmenus.count > 0)
             {
                 [self setTableHeightBasedOnLargestMenuItemIn:object.menuItems];
                 GTLStoreendpointMenuItemAndStats *menuItemAndStats = [object.menuItems firstObject];
                 for (GTLStoreendpointStoreMenuHierarchy *menu in object.menusAndSubmenus)
                 {
                     if (menu.level.intValue == 0)
                     {
                         MenuSegmentHolder *menuSegmentHolder = [[MenuSegmentHolder alloc]init];
                         menuSegmentHolder.menu = menu;
                         menuSegmentHolder.subMenus = [[NSMutableArray alloc] init];
                         
                         for (GTLStoreendpointStoreMenuHierarchy *submenu in object.menusAndSubmenus)
                         {
                             if (submenu.level.intValue == 1 && submenu.menuPOSId.longLongValue == menu.menuPOSId.longLongValue && submenu.menuItemCount.intValue > 0)
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
                         if (menu.menuPOSId.longLongValue == menuItemAndStats.menuItem.menuPOSId.longLongValue)
                             [menuSegmentHolder.provider setInitialObjects:object.menuItems ForPage:1];
                     }
                 }
                 for (GTLStoreendpointStoreMenuStats *menuStats in object.menuStats)
                 {
                     NSString *key = [NSString stringWithFormat:@"%@_%@", menuStats.menuPOSId, menuStats.subMenuPOSId];
                     [self.allMenuStats setObject:menuStats forKey:key];
                 }
                 
             }else{
                 NSLog(@"MenusAndMenuItems Error:%@",[error userInfo][@"error"]);
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

- (void) setTableHeightBasedOnLargestMenuItemIn:(NSArray *)menuItems // of GTLStoreendpointMenuItemAndStats
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        return;
    
    long size = 0;
    for (GTLStoreendpointMenuItemAndStats *object in menuItems)
        if ((object.menuItem.shortDescription.length*2 + object.menuItem.longDescription.length) > size)
            size = object.menuItem.shortDescription.length*2 + object.menuItem.longDescription.length;
    
    if (size > 80)
        self.cellHeight = 200;
    else
        self.cellHeight = 150;
}

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

#pragma mark -
#pragma mark  === DropdownViewDelegate ===
#pragma mark -

- (void)dropdownViewActionForSelectedRow:(int)row sender:(id)sender
{
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    
    GTLStoreendpointStoreMenuHierarchy *submenu = [menuSegmentHolder.subMenus objectAtIndex:row];
    
    if (submenu.menuItemCount.longLongValue > 0)
    {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:row]
                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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
//    NSMutableArray *indexPathsToReload = [NSMutableArray array];
//    
//    NSUInteger index = [indexes firstIndex];
//    
//    while(index != NSNotFound)
//    {
//        NSIndexPath *indexPath = [self calculateIndexPathForIndex:index];
//                                  
//        if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath])
//        {
//            NSLog(@"indexPathsForVisibleRows section = %ld row = %ld", (long)indexPath.section, (long)indexPath.row);
//            [indexPathsToReload addObject:indexPath];
//        }
//        
//        index=[indexes indexGreaterThanIndex: index];
//    }
//    
//    if (indexPathsToReload.count > 0)
//        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
    [self.hud hide:YES];
}

- (NSIndexPath *)calculateIndexPathForIndex:(NSUInteger) index
{
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];

    NSUInteger section = 0;
    for (GTLStoreendpointStoreMenuHierarchy *submenu in menuSegmentHolder.subMenus)
    {
        NSUInteger startIndex = submenu.menuItemPosition.intValue;
        NSUInteger count = submenu.menuItemCount.intValue;
        if (index > startIndex && index < startIndex + count)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(index - startIndex) inSection:section];
            return indexPath;
        }
        section++;
    }
    return nil;
}

- (DataLoadingOperation *) getDataLoadingOperationForPage:(NSUInteger)page indexes:(NSIndexSet *)indexes
{
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    long long storeId = menuSegmentHolder.menu.storeId.longLongValue;
    int menuPOSId = menuSegmentHolder.menu.menuPOSId.intValue;
    MenuItemLoadingOperation *milo = [[MenuItemLoadingOperation alloc] initWithIndexes:indexes storeId:storeId menuPOSId:menuPOSId];
    return milo;
}

- (void)dataProvider:(DataProvider *)dataProvider willLoadDataAtIndexes:(NSIndexSet *)indexes
{
    [self.hud show:YES];
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
    cell.backgroundColor = [UIColor clearColor];
    
    cell.titleLabel.text = nil;
    cell.descriptionLabel.text = nil;
    cell.todaysOrdersLabels.text = nil;
    cell.likesLabel.text = nil;
    cell.priceLabel.text = nil;
    cell.mostOrderedLabel.text = nil;
    cell.reviewsLabel.text = nil;
    cell.likesImageView.image = nil;
    cell.visitorsImageView.image = nil;
    
    id dataObject = menuSegmentHolder.provider.dataObjects[rowIndex];
    if ([dataObject isKindOfClass:[NSNull class]])
        return cell;
    
    GTLStoreendpointMenuItemAndStats *menuItemAndStats = dataObject;
    cell.titleLabel.text = menuItemAndStats.menuItem.shortDescription;
    cell.descriptionLabel.text = menuItemAndStats.menuItem.longDescription;
    cell.priceLabel.text = [UtilCalls amountToString:menuItemAndStats.menuItem.price];
    
    NSString *keyForMenuStats = [NSString stringWithFormat:@"%@_%@", menuItemAndStats.menuItem.menuPOSId, menuItemAndStats.menuItem.subMenuPOSId];
    GTLStoreendpointStoreMenuStats *menuStats = [self.allMenuStats objectForKey:keyForMenuStats];
    
    if (menuStats.mostFrequentlyOrderedMenuItemPOSId.intValue == menuItemAndStats.menuItem.menuItemPOSId.intValue)
        cell.mostOrderedLabel.text = @"Most Frequently Ordered";
    
    if (menuItemAndStats.stats.orders != nil && menuItemAndStats.stats.orders.longLongValue > 0)
    {
        cell.visitorsImageView.image = [UIImage imageNamed:@"number_visitors"];
        cell.todaysOrdersLabels.text = [UtilCalls formattedNumber:menuItemAndStats.stats.orders];
    }
    
    long long reviewCount = menuItemAndStats.stats.dislikes.longLongValue + menuItemAndStats.stats.likes.longLongValue;
    if (reviewCount > 0)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        int iPercent = (int)(menuItemAndStats.stats.likes.longLongValue*100/reviewCount);
        NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
        NSString *strReviews = [UtilCalls formattedNumber:[NSNumber numberWithLongLong:reviewCount]];
        NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
        cell.reviewsLabel.text = [[[strLikePercent stringByAppendingString:@"%("] stringByAppendingString:strReviews] stringByAppendingString:@")"];
        cell.likesImageView.image = [UIImage imageNamed:@"number_likes"];
    }

    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.itemImageView.tag = rowIndex - indexPath.section - 1;
    
    cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.size.width / 2;
    cell.itemImageView.clipsToBounds = YES;
    cell.itemImageView.layer.borderWidth = 1.0f;
    cell.itemImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // NOTE: Rounded rect
    // self.profileImageView.layer.cornerRadius = 10.0f;
    
    NSString *strUrl = menuItemAndStats.menuItem.thumbnailUrl;
    if (IsEmpty(menuItemAndStats.menuItem.thumbnailUrl) == true)
        strUrl = menuItemAndStats.menuItem.imageUrl;
    
    if (IsEmpty(strUrl) == false)
    {
        //        [cell.itemPFImageView sd_setImageWithURL:[NSURL URLWithString:menuItemAndStats.menuItem.thumbnailUrl]];
        [cell.itemImageView setImageWithURL:[NSURL URLWithString:strUrl ]
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
    txtName.numberOfLines = 0;
    if (IsEmpty(submenu.descriptionProperty) == true)
        txtName.text = submenu.name;
    else
        txtName.attributedText = [self getAttributedHeaderTextForSubMenu:submenu];
    DropdownView *dropdownView = (DropdownView*)[headerView  viewWithTag:402];
    [self setupDropdownView:dropdownView];
    return headerView.contentView;
}

-(NSAttributedString *) getAttributedHeaderTextForSubMenu:(GTLStoreendpointStoreMenuHierarchy *)submenu
{
    NSString *str = [NSString stringWithFormat:@"\n\n%@", submenu.descriptionProperty];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:submenu.name];
    NSAttributedString *atrStr = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[UIFont smallSystemFontSize]]}];
    [attributedString appendAttributedString:atrStr];
    
    return attributedString;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.bMenuIsInOrderMode) // Menu is in Order Mode
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
    else
        [self.view makeToast:@"Please start an order from the \"Order Online\" button on the Store List."];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    GTLStoreendpointStoreMenuHierarchy *submenu = [menuSegmentHolder.subMenus objectAtIndex:section];
    if (IsEmpty(submenu.descriptionProperty))
        return tableView.sectionHeaderHeight;
    else
        return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
//        return UITableViewAutomaticDimension;
//    else
        return self.cellHeight;
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
    
    NSInteger rowIndex = section + index + 1;
    id dataObject = menuSegmentHolder.provider.dataObjects[rowIndex];
    if ([dataObject isKindOfClass:[NSNull class]])
        return nil;
    
    GTLStoreendpointMenuItemAndStats *menuItemAndStats = dataObject;
    MWPhoto *photo = nil;
    
    if (IsEmpty(menuItemAndStats.menuItem.imageUrl) == false)
    {
        //        photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1011283712_5750c5ba8e_b.jpg"]];
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:menuItemAndStats.menuItem.imageUrl]];
    }
    else {
        photo = [MWPhoto photoWithImage:[UIImage imageNamed:@"no_image"]];
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
    
    NSInteger rowIndex = section + index + 1;
    id dataObject = menuSegmentHolder.provider.dataObjects[rowIndex];
    if ([dataObject isKindOfClass:[NSNull class]])
        return nil;
    
    // Selected Item
    self.selectedMenuItem = dataObject;
    
    GTLStoreendpointMenuItemAndStats *menuItemAndStats = dataObject;
    MWPhoto *photo = nil;
    
    if (IsEmpty(menuItemAndStats.menuItem.imageUrl) == false)
    {
        //        photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1011283712_5750c5ba8e_b.jpg"]];
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:menuItemAndStats.menuItem.imageUrl]];
    }
    else {
        photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"no_image_big" ofType:@"png"]]];
        //        photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1011283712_5750c5ba8e_b.jpg"]];
    }
    
    MenuMWCaptionView *captionView = [[MenuMWCaptionView alloc] initWithPhoto:photo];
    
    NSString *string = menuItemAndStats.menuItem.shortDescription;
    if (string && ![string isEqualToString:@""]) {
        captionView.textTitle = string;
    }
    
    string = [UtilCalls amountToString:menuItemAndStats.menuItem.price];
    if (string && ![string isEqualToString:@""]) {
        captionView.textPrice = string;
    }
    
    string = menuItemAndStats.menuItem.longDescription;
    if (string && ![string isEqualToString:@""]) {
        captionView.textDescription = string;
    }
    
    if (menuItemAndStats.stats.orders != nil && menuItemAndStats.stats.orders.longLongValue > 0) {
        captionView.textTodaysOrders = [NSString stringWithFormat:@"%@ peoples ordered today.", [UtilCalls formattedNumber:menuItemAndStats.stats.orders]];
        
        
        NSString *keyForMenuStats = [NSString stringWithFormat:@"%@_%@", menuItemAndStats.menuItem.menuPOSId, menuItemAndStats.menuItem.subMenuPOSId];
        GTLStoreendpointStoreMenuStats *menuStats = [self.allMenuStats objectForKey:keyForMenuStats];
        
        if (menuStats.mostFrequentlyOrderedMenuItemPOSId.intValue == menuItemAndStats.menuItem.menuItemPOSId.intValue)
            captionView.textMostOrdered = @"Most Frequently Ordered";
    }
    
    long long reviewCount = menuItemAndStats.stats.dislikes.longLongValue + menuItemAndStats.stats.likes.longLongValue;
    if (reviewCount > 0)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        int iPercent = (int)(menuItemAndStats.stats.likes.longLongValue*100/reviewCount);
        NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
        NSString *strReviews = [UtilCalls formattedNumber:[NSNumber numberWithLongLong:reviewCount]];
        NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
        captionView.textLikes = [[[strLikePercent stringByAppendingString:@"%("] stringByAppendingString:strReviews] stringByAppendingString:@")"];
        captionView.imageLike = [UIImage imageNamed:@"Like"];
    }
    
//    captionView.textTodaysOrders = @"18 peoples ordered today.";
//    captionView.textMostOrdered = @"Most ordered";
//    captionView.imageLike = [UIImage imageNamed:@"Like"];
//    captionView.textLikes = @"1800";
    
#warning These are needed to enable/disable order button
    if (self.bMenuIsInOrderMode) // Menu is in Order Mode
    {
        captionView.index = index;
        captionView.delegate = self;
        captionView.enabledOrderButton = true;
    }
    
    return captionView;
}

#pragma mark -
#pragma mark === MenuItemCellDelegate ===
#pragma mark -

- (void)menuItemCell:(MenuItemCell *)menuItemCell didClickedItemImage:(UIImageView *)sender
{
    
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
    
    // Selected Item
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    
    GTLStoreendpointStoreMenuHierarchy *submenu = [menuSegmentHolder.subMenus objectAtIndex:menuItemCell.indexPath.section];
    NSInteger rowIndex = submenu.menuItemPosition.intValue + menuItemCell.indexPath.row + 1;
    
    id dataObject = menuSegmentHolder.provider.dataObjects[rowIndex];
    if (![dataObject isKindOfClass:[NSNull class]])
    {
        self.selectedMenuItem = dataObject;
    }
}

#pragma mark -
#pragma mark === MenuMWCaptionViewDelegate ===
#pragma mark -

- (IBAction)addToOrder:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    OnlineOrderDetails *orderInProgress = appDelegate.globalObjectHolder.orderInProgress;
    
//    if (self.bInEditMode == YES)
//    {
//        orderInProgress.specialInstructions = self.txtSpecialInstructions.text;
//        [orderInProgress.selectedMenuItems replaceObjectAtIndex:self.selectedIndex withObject:self.onlineOrderSelectedMenuItem];
//        [self performSegueWithIdentifier:@"unwindModifierGroupToOrderSummary" sender:self];
//        return;
//    }
    
    if (orderInProgress == nil)
    {
        orderInProgress = [appDelegate.globalObjectHolder createOrderInProgress];
        orderInProgress.selectedStore = self.selectedStore;//_onlineOrderSelectedMenuItem.selectedStore;
        orderInProgress.orderType = self.orderType;
        orderInProgress.orderTime = self.orderTime;
        orderInProgress.partySize = self.partySize;
//        orderInProgress.specialInstructions = @"";//self.txtSpecialInstructions.text;
        [orderInProgress.selectedMenuItems addObject:self.selectedMenuItem];
//        [self performSegueWithIdentifier:@"segueunwindModifierGroupToMenu" sender:self];
        
    }
//    else
//    {
//        orderInProgress.specialInstructions = self.txtSpecialInstructions.text;
//        [orderInProgress.selectedMenuItems addObject:self.onlineOrderSelectedMenuItem];
//        [self performSegueWithIdentifier:@"segueunwindModifierGroupToMenu" sender:self];
//    }
    
    NSArray *viewConrollers = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[viewConrollers objectAtIndex:[viewConrollers count]-2] animated:YES];
}

#warning Use this to go to ordercontroller and here 'index' starts from 0;
- (void)menuMWCaptionView:(MenuMWCaptionView *)menuMWCaptionView didClickedOrderButtonAtIndex:(NSUInteger)index {
    
//    NSLog(@"Tapped order button at index : %lu", (unsigned long)index);
//    [self addToOrder:self];
    
    [self performSegueWithIdentifier:@"segueMenuToModifierGroup" sender:self];
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
        [controller setSelectedMenuItem:self.selectedMenuItem.menuItem];
        [controller setOrderTime:self.orderTime];
        [controller setOrderType:self.orderType];
        [controller setPartySize:self.partySize];
        [controller setBInEditMode:NO];
    }
    else if ([[segue identifier] isEqualToString:@"segueMenuToOrderSummary"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        OnlineOrderDetails *orderInProgress = appDelegate.globalObjectHolder.orderInProgress;
        orderInProgress.orderType = self.orderType;
        orderInProgress.orderTime = self.orderTime;
        orderInProgress.partySize = self.partySize;
    }
}

- (IBAction)unwindModifierGroupToMenu:(UIStoryboardSegue *)unwindSegue
{
}

@end
