//
//  MenuTableViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MenuTableViewController.h"
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
#include "DropdownView.h"
#import "UIImageView+WebCache.h"
#import "MenuItemLoadingOperation.h"
#import "MenuSegmentHolder.h"

const NSUInteger MenuFluentPagingTablePreloadMargin = 5;
const NSUInteger MenuFluentPagingTablePageSize = 20;

@interface MenuTableViewController ()<DataProviderDelegate, DropdownViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) int startPosition;
@property (nonatomic) int maxResult;
@property (strong, nonatomic) NSMutableArray *menuSegmentHolders;

@end

@implementation MenuTableViewController
@synthesize tableView = _tableView;
@synthesize segmentedControl = _segmentedControl;
@synthesize startPosition = _startPosition;
@synthesize maxResult = _maxResult;
@synthesize dataProvider = _dataProvider;
@synthesize menuSegmentHolders = _menuSegmentHolders;
@synthesize selectedStore = _selectedStore;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMenuSegmentController];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
- (IBAction)segmentControllerValueChanged:(id)sender
{
    [_tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
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
        GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreMenuHierarchyAndItemsWithStoreId:[_selectedStore identifier].longValue menuType:0 maxResult:20];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointMenusAndMenuItems *object,NSError *error)
        {
            if(!error){
                for (GTLStoreendpointStoreMenuHierarchy *menu in object.menusAndSubmenus)
                {
                    if (menu.level.intValue == 0)
                    {
                        MenuSegmentHolder *menuSegmentHolder = [[MenuSegmentHolder alloc]init];
                        menuSegmentHolder.menu = menu;
                        menuSegmentHolder.provider = [[DataProvider alloc] initWithPageSize:MenuFluentPagingTablePageSize itemCount:menu.menuItemCount.integerValue];
                        menuSegmentHolder.provider.delegate = weakSelf;
                        menuSegmentHolder.provider.shouldLoadAutomatically = YES;
                        menuSegmentHolder.provider.automaticPreloadMargin = MenuFluentPagingTablePreloadMargin;
                        menuSegmentHolder.topRowIndex = 0;
                        [_menuSegmentHolders addObject:menuSegmentHolder];
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
                                                forState:UIControlStateNormal];                self.navigationItem.titleView = _segmentedControl;
                for (MenuSegmentHolder *menuSegmentHolder in _menuSegmentHolders)
                    [_segmentedControl insertSegmentWithTitle:menuSegmentHolder.menu.name atIndex:_segmentedControl.numberOfSegments animated:NO];
                [_segmentedControl sizeToFit];
                [_segmentedControl addTarget:self
                           action:@selector(segmentControllerValueChanged:)
                            forControlEvents:UIControlEventValueChanged];
                [_segmentedControl setSelectedSegmentIndex:0];
                _segmentedControl.apportionsSegmentWidthsByContent = YES;
            }
            [weakSelf.tableView reloadData];
            hud.hidden = YES;
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDropdownView:(DropdownView *)dropdownView
{
    [dropdownView setData:@[@"15%", @"20%", @"25%", @"30%"]];
    dropdownView.delegate = self;
}

#pragma mark - Data controller delegate
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

#pragma mark - DropdownViewDelegate
- (void)dropdownViewActionForSelectedRow:(int)row sender:(id)sender
{
    NSLog(@"Selected row : %d", row);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    return menuSegmentHolder.provider.dataObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuSegmentHolder *menuSegmentHolder;
    if (_menuSegmentHolders.count > 1)
        menuSegmentHolder = [_menuSegmentHolders objectAtIndex:_segmentedControl.selectedSegmentIndex];
    else
        menuSegmentHolder = [_menuSegmentHolders firstObject];
    
    id dataObject = menuSegmentHolder.provider.dataObjects[indexPath.row];
    if ([dataObject isKindOfClass:[NSNull class]])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubMenuCell" forIndexPath:indexPath];
        UILabel *txtName=(UILabel *)[cell viewWithTag:401];
        txtName.text = nil;
        return cell;
    }
    
    GTLStoreendpointStoreMenuItem *menuItem = dataObject;
    if (menuItem != nil)
    {
        if (menuItem.level.intValue == 1)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubMenuCell" forIndexPath:indexPath];
            UILabel *txtName=(UILabel *)[cell viewWithTag:401];
            DropdownView *dropdownView = (DropdownView*)[cell viewWithTag:402];
            
            txtName.text = menuItem.shortDescription;
//            dropdownView.delegate = self;
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UIImageView *imgBackground = (UIImageView *)[cell viewWithTag:301];
            //    imgBackground.image = [UIImage imageNamed:@"loading-wait"]; // placeholder image
            UILabel *txtName=(UILabel *)[cell viewWithTag:302];
            UILabel *txtDescription=(UILabel *)[cell viewWithTag:303];
            UILabel *txtTodaysOrders=(UILabel *)[cell viewWithTag:304];
            UILabel *txtLikes=(UILabel *)[cell viewWithTag:305];
            UIImageView *imgLike = (UIImageView *)[cell viewWithTag:306];
            UILabel *txtPrice=(UILabel *)[cell viewWithTag:307];
            UILabel *txtMostOrdered=(UILabel *)[cell viewWithTag:308];
            
            txtName.text = menuItem.shortDescription;
            txtDescription.text = menuItem.longDescription;
            txtTodaysOrders.text = nil;
            txtLikes.text = nil;
            imgLike.image = nil;
            txtPrice.text = [UtilCalls amountToString:menuItem.price];
            txtMostOrdered.text = nil;

            if (IsEmpty(menuItem.imageUrl) == false)
            {
                PFQuery *query = [PFQuery queryWithClassName:@"PictureFiles"];
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
                [query getObjectInBackgroundWithId:menuItem.imageUrl block:^(PFObject *pictureFile, NSError *error)
                {
                    if (error.code != kPFErrorCacheMiss)
                    {
                        if (error)
                            NSLog(@"Store List Background image loading error:%@",[error userInfo]);
                        else
                        {
                            PFFile *backgroundImgFile = pictureFile[@"picture_file"];
                            [imgBackground sd_setImageWithURL:[NSURL URLWithString:backgroundImgFile.url]
                                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *backgroundImgUrl)
                            {
                                imgBackground.alpha = 0.0;
                                [UIView transitionWithView:imgBackground duration:3.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
                                {
                                    [imgBackground setImage:image];
                                    imgBackground.alpha = 1.0;
                                } completion:NULL];
                            }];
                        }
                    }
                }];
            }
            return cell;
        }
    }
    return nil;
}
@end
