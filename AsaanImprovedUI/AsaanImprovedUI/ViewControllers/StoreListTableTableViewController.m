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
#import "UIColor+AsaanGoldColor.h"

@interface StoreListTableTableViewController ()
{
    MBProgressHUD *hud;
    NSMutableArray *storeList;
    NSMutableArray *storeStatsList;
}
- (NSString *) formattedNumber:(NSNumber*) number;
@end

@implementation StoreListTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    storeList = [[NSMutableArray alloc]init];
    storeStatsList = [[NSMutableArray alloc]init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.hidden=NO;
    PFUser *currentUser = [PFUser currentUser];
    hud.hidden=YES;
    if (!currentUser) {
        [self performSegueWithIdentifier:@"segueStartup" sender:self];
        return;
    }
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor goldColor]};

    [self fetchStoresFromServer];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)fetchStoresFromServer{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoresWithFirstPosition:0 maxResult:20];
    
    __weak StoreListTableTableViewController *myself = self;
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreCollection *object,NSError *error){
        if(!error){
            storeList = [object.items mutableCopy];
            [myself.tableView reloadData];
        }else{
            NSLog(@"%@",[error userInfo]);
        }
    }];
    
    GTLQueryStoreendpoint *query2=[GTLQueryStoreendpoint queryForGetStatsForAllStoresWithFirstPosition:0 maxResult:20];
    
    [gtlStoreService executeQuery:query2 completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreStatsCollection *object,NSError *error){
        if(!error){
            storeStatsList = [object.items mutableCopy];
            [myself.tableView reloadData];
        }else{
            NSLog(@"%@",[error userInfo]);
        }
    }];
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
    return storeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoreListCell" forIndexPath:indexPath];
    PFImageView *imgBackground = (PFImageView *)[cell viewWithTag:400];
    UILabel *txtName=(UILabel *)[cell viewWithTag:500];
    UILabel *txtTrophy=(UILabel *)[cell viewWithTag:501];
    UILabel *txtCuisine=(UILabel *)[cell viewWithTag:502];
    UILabel *txtVisits=(UILabel *)[cell viewWithTag:504];
    UILabel *txtLikes=(UILabel *)[cell viewWithTag:506];
    UILabel *txtRecommends=(UILabel *)[cell viewWithTag:508];
    
    UIImageView *imgVisits = (UIImageView*)[cell viewWithTag:503];
    imgVisits.hidden = true;
    UIImageView *imgLikes = (UIImageView*)[cell viewWithTag:505];
    imgLikes.hidden = true;
    UIImageView *imgRecommends = (UIImageView*)[cell viewWithTag:507];
    imgRecommends.hidden = true;
    
    txtVisits.text = nil;
    txtLikes.text = nil;
    txtRecommends.text = nil;

    GTLStoreendpointStore *store=[storeList objectAtIndex:indexPath.row];
    if (store != nil) {
        if (IsEmpty(store.backgroundImageUrl) == false) {
            imgBackground.image = [UIImage imageNamed:@"loading-wait"]; // placeholder image
            PFQuery *query = [PFQuery queryWithClassName:@"PictureFiles"];
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            [query getObjectInBackgroundWithId:store.backgroundImageUrl block:^(PFObject *pictureFile, NSError *error) {
                PFFile *backgroundImgFile = pictureFile[@"picture_file"];
                imgBackground.file = backgroundImgFile;
                [imgBackground loadInBackground];
            }];
        }
        NSLog(@"name = %@, torphy = %@, cuisine = %@", store.name, store.trophies.firstObject, store.subType);
        txtName.text = store.name;
        txtTrophy.text = store.trophies.firstObject;
        txtCuisine.text = store.subType;
    }
    if (storeStatsList.count > indexPath.row)
    {
        GTLStoreendpointStoreStats *storeStats = [storeStatsList objectAtIndex:indexPath.row];
        if (storeStats.visits.longValue > 0){
            txtVisits.text = [self formattedNumber:storeStats.visits];
            imgVisits.hidden = false;
        }
        long reviewCount = storeStats.dislikes.longValue + storeStats.likes.longValue;
        if (reviewCount > 0){
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            int iPercent = (int)(storeStats.likes.longValue*100/reviewCount);
            NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
            NSString *strReviews = [self formattedNumber:[NSNumber numberWithLong:reviewCount]];
            NSString *strLikePercent = [self formattedNumber:likePercent];
            txtLikes.text = [[[strLikePercent stringByAppendingString:@"%("] stringByAppendingString:strReviews] stringByAppendingString:@")"];
            imgLikes.hidden = false;
        }
        
        if (storeStats.recommendations.longValue > 0){
            txtRecommends.text = [self formattedNumber:storeStats.recommendations];
            imgRecommends.hidden = false;
        }
    }
    
    return cell;
}

- (NSString *) formattedNumber:(NSNumber*) number{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if (number.longValue >= 1000000){
        number = [NSNumber numberWithFloat:ceil(number.longValue/1000000)];
        NSString *strNumber = [numberFormatter stringFromNumber:number];
        return [strNumber stringByAppendingString:@"M+"];
    }
    else if (number.longValue >= 10000){
        number = [NSNumber numberWithFloat:ceil(number.longValue/1000)];
        NSString *strNumber = [numberFormatter stringFromNumber:number];
        return [strNumber stringByAppendingString:@"K+"];
    }
    else
        return [numberFormatter stringFromNumber:number];
}

- (void)addShadowToText:(UILabel *)textView withText:(NSString *)text{
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = NSMakeRange(0, [attString length]);
    
    [attString addAttribute:NSFontAttributeName value:textView.font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:textView.textColor range:range];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor grayColor];
    shadow.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [attString addAttribute:NSShadowAttributeName value:shadow range:range];
    
    textView.attributedText = attString;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
