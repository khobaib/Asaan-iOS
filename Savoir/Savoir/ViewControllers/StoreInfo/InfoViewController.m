//
//  InfoViewController.m
//  Savoir
//
//  Created by Hasan Ibna Akbar on 12/16/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "InfoViewController.h"
#import "UIImageView+WebCache.h"
#import "InlineCalls.h"
#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "StoreMapViewController.h"

@interface InfoViewController ()

@property (nonatomic, strong) NSMutableArray *cellHeightArray;

@property (weak, nonatomic) IBOutlet UIImageView *restaurantImageView;

@property (weak, nonatomic) IBOutlet UILabel *restaurantTitle;
@property (weak, nonatomic) IBOutlet UILabel *cuisineTitle;
@property (weak, nonatomic) IBOutlet UILabel *chefTitle;
@property (weak, nonatomic) IBOutlet UILabel *trophiesTitle;
@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *cuisineName;
@property (weak, nonatomic) IBOutlet UILabel *chefName;
@property (weak, nonatomic) IBOutlet UILabel *trophiesName;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressTitle;
@property (weak, nonatomic) IBOutlet UILabel *phoneTitle;
@property (weak, nonatomic) IBOutlet UILabel *webTitle;
@property (weak, nonatomic) IBOutlet UILabel *facebookTitle;
@property (weak, nonatomic) IBOutlet UILabel *twitterTitle;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *webLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor asaanBackgroundColor];
    
    self.cellHeightArray = [[NSMutableArray alloc] initWithArray:@[@160, @160, @64, @64, @160, @160]];
    
    self.restaurantTitle.textColor = self.cuisineTitle.textColor = self.chefTitle.textColor = self.trophiesTitle.textColor = [UIColor goldColor];
    self.addressTitle.textColor = self.phoneTitle.textColor = self.webTitle.textColor = self.facebookTitle.textColor = self.twitterTitle.textColor = [UIColor goldColor];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.selectedStore != nil) {
        
        if (!IsEmpty(self.selectedStore.backgroundImageUrl)) {
            
            __weak __typeof__(self) weakSelf = self;
            [self.restaurantImageView sd_setImageWithURL:[NSURL URLWithString:self.selectedStore.backgroundImageUrl]
                                        placeholderImage:nil
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
             {
                 if (!error && image && weakSelf &&  weakSelf.tableView) {
                     
                     [weakSelf.cellHeightArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:[[UIScreen mainScreen] bounds].size.width * image.size.height / image.size.width]];
                     
                     // This code forces UITableView to reload cell sizes only, but not cell contents
                     [weakSelf.tableView beginUpdates];
                     [weakSelf.tableView endUpdates];
                 }
             }];
        }
            
//        NSLog(@"name = %@, torphy = %@, cuisine = %@", _selectedStore.name, _selectedStore.trophies.firstObject, _selectedStore.subType);
        
        self.restaurantName.text = _selectedStore.name;
        self.chefName.text = _selectedStore.executiveChef;
        self.cuisineName.text = _selectedStore.subType;
        
        NSMutableString *trophies = [[NSMutableString alloc] initWithString:@""];
        for (NSString *trophy in _selectedStore.trophies) {
            [trophies appendFormat:@"%@, ", trophy];
        }
        self.trophiesName.text = trophies;
        
        self.descriptionLabel.text = _selectedStore.descriptionProperty ? _selectedStore.descriptionProperty : @"";
        
        self.addressLabel.text = _selectedStore.address ? _selectedStore.address : @"";
        self.phoneLabel.text = _selectedStore.phone ? _selectedStore.phone : @"";
        self.webLabel.text = _selectedStore.webSiteUrl ? _selectedStore.webSiteUrl : @"";
        self.facebookLabel.text = _selectedStore.fbUrl ? _selectedStore.fbUrl : @"";
        self.twitterLabel.text = _selectedStore.twitterUrl ? _selectedStore.twitterUrl : @"";
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"InfoToMapVCSegue"]) {
        StoreMapViewController *storeMapViewController = (StoreMapViewController *)segue.destinationViewController;
        storeMapViewController.selectedStore = self.selectedStore;
    }
}

#pragma mark - UITableViewDataSource
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//    
//    if (indexPath.row == 0) {
//        
//        if (self.selectedStore != nil && !IsEmpty(self.selectedStore.backgroundImageUrl)) {
//            
//            [((UIImageView * )[cell viewWithTag:101]) sd_setImageWithURL:[NSURL URLWithString:self.selectedStore.backgroundImageUrl]
//                                                        placeholderImage:nil
//                                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
//             {
////                 [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//                 CGRect frame = cell.frame;
//                 [self.cellHeightArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:frame.size.width * image.size.height / image.size.width]];
//                 
//                 // This code forces UITableView to reload cell sizes only, but not cell contents
//                 [tableView beginUpdates];
//                 [tableView endUpdates];
//             }];
//            
//            NSLog(@"name = %@, torphy = %@, cuisine = %@", _selectedStore.name, _selectedStore.trophies.firstObject, _selectedStore.subType);
//            
//            //        txtName.text = _selectedStore.name;
//            //        txtTrophy.text = _selectedStore.trophies.firstObject;
//            //        txtCuisine.text = _selectedStore.subType;
//        }
//    }
//    
//    return cell;
//}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.cellHeightArray objectAtIndex:indexPath.row] intValue];
}

@end
