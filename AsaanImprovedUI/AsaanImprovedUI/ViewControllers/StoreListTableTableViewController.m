//
//  StoreListTableTableViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/18/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "StoreListTableTableViewController.h"
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
#import "StoreLoadingOperation.h"
#import "UIImageView+WebCache.h"
#import "MenuTableViewController.h"

const NSUInteger FluentPagingTablePreloadMargin = 5;

@interface StoreListTableTableViewController ()<DataProviderDelegate>
    @property (nonatomic, strong) MBProgressHUD *hud;
    @property (strong, nonatomic) IBOutlet UITableView *tableView;
    @property (nonatomic) int startPosition;
    @property (nonatomic) int maxResult;
    @property (weak, nonatomic) GTLStoreendpointStore *selectedStore;
@end

@implementation StoreListTableTableViewController
@synthesize tableView = _tableView;
@synthesize startPosition = _startPosition;
@synthesize maxResult = _maxResult;
@synthesize dataProvider = _dataProvider;
@synthesize selectedStore = _selectedStore;

- (IBAction)unwindToStoreList:(UIStoryboardSegue*)sender
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataProvider = [[DataProvider alloc] initWithPageSize:6 itemCount:6];
    _dataProvider.delegate = self;
    _dataProvider.shouldLoadAutomatically = YES;
    _dataProvider.automaticPreloadMargin = FluentPagingTablePreloadMargin;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    if ([self isViewLoaded])
//        [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hud = [MBProgressHUD showHUDAddedTo:_tableView animated:YES];
    [self.hud hide:YES];
    
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
//        [self performSegueWithIdentifier:@"segueStartup" sender:self];
        [self performSegueWithIdentifier:@"segueLoginStoryboard" sender:self];
        return;
    }
    
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

#pragma mark - Data controller delegate
- (void)dataProvider:(DataProvider *)dataProvider didLoadDataAtIndexes:(NSIndexSet *)indexes {
    
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

- (DataLoadingOperation *) getDataLoadingOperationForPage:(NSUInteger)page indexes:(NSIndexSet *)indexes {
    return [[StoreLoadingOperation alloc] initWithIndexes:indexes];
}

- (void)dataProvider:(DataProvider *)dataProvider willLoadDataAtIndexes:(NSIndexSet *)indexes {
    [self.hud hide:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataProvider.dataObjects.count;
}

- (void) callStore:(UIButton *)sender
{
    UITableViewCell* cell = (UITableViewCell*)[sender superview];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    _selectedStore = self.dataProvider.dataObjects[indexPath.row];
}
- (void) showMenu:(UIButton *)sender
{
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    UITableViewCell *cell = (UITableViewCell *)view;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    _selectedStore = self.dataProvider.dataObjects[indexPath.row];
    [self performSegueWithIdentifier:@"segueMenu" sender:sender];
}
- (void) placeOrder:(UIButton *)sender
{
    UITableViewCell* cell = (UITableViewCell*)[sender superview];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    _selectedStore = self.dataProvider.dataObjects[indexPath.row];
}
- (void) reserveTable:(UIButton *)sender
{
    UITableViewCell* cell = (UITableViewCell*)[sender superview];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    _selectedStore = self.dataProvider.dataObjects[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoreListCell" forIndexPath:indexPath];

    UIImageView *imgBackground = (UIImageView *)[cell viewWithTag:400];
//    imgBackground.image = [UIImage imageNamed:@"loading-wait"]; // placeholder image
    UILabel *txtName=(UILabel *)[cell viewWithTag:500];
    UILabel *txtTrophy=(UILabel *)[cell viewWithTag:501];
    UILabel *txtCuisine=(UILabel *)[cell viewWithTag:502];
    UILabel *txtVisits=(UILabel *)[cell viewWithTag:504];
    UILabel *txtLikes=(UILabel *)[cell viewWithTag:506];
    UILabel *txtRecommends=(UILabel *)[cell viewWithTag:508];
    
    UIButton *btnCall = (UIButton*)[cell viewWithTag:601];
    UIButton *btnMenu = (UIButton*)[cell viewWithTag:602];
    UIButton *btnOrder = (UIButton*)[cell viewWithTag:603];
    UIButton *btnReserve = (UIButton*)[cell viewWithTag:604];
    
    [btnCall addTarget:self action:@selector(callStore:) forControlEvents:UIControlEventTouchUpInside];
    [btnMenu addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [btnOrder addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    [btnReserve addTarget:self action:@selector(reserveTable:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgVisits = (UIImageView*)[cell viewWithTag:503];
    imgVisits.hidden = true;
    UIImageView *imgLikes = (UIImageView*)[cell viewWithTag:505];
    imgLikes.hidden = true;
    UIImageView *imgRecommends = (UIImageView*)[cell viewWithTag:507];
    imgRecommends.hidden = true;

    txtName.text = nil;
    txtTrophy.text = nil;
    txtCuisine.text = nil;
    txtVisits.text = nil;
    txtLikes.text = nil;
    txtRecommends.text = nil;
    
    id dataObject = self.dataProvider.dataObjects[indexPath.row];
    if ([dataObject isKindOfClass:[NSNull class]])
        return cell;

    GTLStoreendpointStore *store = dataObject;
    if (store != nil) {
        if (IsEmpty(store.backgroundImageUrl) == false) {
            PFQuery *query = [PFQuery queryWithClassName:@"PictureFiles"];
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            [query getObjectInBackgroundWithId:store.backgroundImageUrl block:^(PFObject *pictureFile, NSError *error) {
                if (error.code != kPFErrorCacheMiss) {
                    if (error)
                        NSLog(@"Store List Background image loading error:%@",[error userInfo]);
                    else {
                        PFFile *backgroundImgFile = pictureFile[@"picture_file"];
//                        [imgBackground sd_setImageWithURL:[NSURL URLWithString:backgroundImgFile.url]
//                                      placeholderImage:[UIImage imageNamed:@"loading-wait"]];
                        [imgBackground sd_setImageWithURL:[NSURL URLWithString:backgroundImgFile.url]
//                                         placeholderImage:[UIImage imageNamed:@"loading-wait"]
                                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *backgroundImgUrl) {
                                                    imgBackground.alpha = 0.0;
                                                    [UIView transitionWithView:imgBackground
                                                                      duration:3.0
                                                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                                                    animations:^{
                                                                        [imgBackground setImage:image];
                                                                        imgBackground.alpha = 1.0;
                                                                    } completion:NULL];
                                                }];
                    }
                }
            }];
        }
        NSLog(@"name = %@, torphy = %@, cuisine = %@", store.name, store.trophies.firstObject, store.subType);
        txtName.text = store.name;
        txtTrophy.text = store.trophies.firstObject;
        txtCuisine.text = store.subType;
    }
//    if (self.storeStatsList.count > indexPath.row)
//    {
//        GTLStoreendpointStoreStats *storeStats = [self.storeStatsList objectAtIndex:indexPath.row];
//        if (storeStats.visits.longValue > 0){
//            txtVisits.text = [UtilCalls formattedNumber:storeStats.visits];
//            imgVisits.hidden = false;
//        }
//        long reviewCount = storeStats.dislikes.longValue + storeStats.likes.longValue;
//        if (reviewCount > 0){
//            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
//            int iPercent = (int)(storeStats.likes.longValue*100/reviewCount);
//            NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
//            NSString *strReviews = [UtilCalls formattedNumber:[NSNumber numberWithLong:reviewCount]];
//            NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
//            txtLikes.text = [[[strLikePercent stringByAppendingString:@"%("] stringByAppendingString:strReviews] stringByAppendingString:@")"];
//            imgLikes.hidden = false;
//        }
//        
//        if (storeStats.recommendations.longValue > 0){
//            txtRecommends.text = [UtilCalls formattedNumber:storeStats.recommendations];
//            imgRecommends.hidden = false;
//        }
//    }
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"segueMenu"])
    {
        // Get reference to the destination view controller
        MenuTableViewController *menuController = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        [menuController setSelectedStore:_selectedStore];
    }
}

@end
