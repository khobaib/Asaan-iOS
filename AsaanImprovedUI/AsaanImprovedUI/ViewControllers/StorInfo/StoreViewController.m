//
//  StoreViewController.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 12/16/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "StoreViewController.h"

#import "ContainerViewController.h"
#import "OrderHistoryTableViewController.h"
#import "InfoViewController.h"
#import "ReviewsViewController.h"

@interface StoreViewController () <ContainerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) ContainerViewController *containerViewController;

@end

@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainerStore"]) {
        
        self.containerViewController = segue.destinationViewController;
        self.containerViewController.segues   = @[@"segueContainerToOrderHistory", @"storeInfoSegue", @"reviewsSegue"];
        
        self.containerViewController.initialIndex = 1;
        self.containerViewController.delegate = self;
    }
}

#pragma mark - Actions
- (IBAction)segmentedValueChanged:(id)sender {
    
    UISegmentedControl *seg = sender;
    [self.containerViewController swapViewControllers:(int)seg.selectedSegmentIndex];
}

#pragma mark - ContainerViewControllerDelegate
- (void)containerViewController:(ContainerViewController *)containerViewController willShowViewController:(UIViewController*)viewController {

    if ([viewController isKindOfClass:[InfoViewController class]]) {
        ((InfoViewController *)viewController).selectedStore = self.selectedStore;
    }
    else if ([viewController isKindOfClass:[OrderHistoryTableViewController class]]) {
        ((OrderHistoryTableViewController *)viewController).selectedStore = self.selectedStore;
    }
    else if ([viewController isKindOfClass:[ReviewsViewController class]]) {
        ((ReviewsViewController *)viewController).selectedStore = self.selectedStore;
    }
}

@end
