//
//  StoreViewController.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 12/16/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "StoreViewController.h"
#import "ContainerViewController.h"

@interface StoreViewController ()

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
        self.containerViewController.segueIdentifierFirst   = @"historySegue";
        self.containerViewController.segueIdentifierSecond  = @"storeInfoSegue";
        self.containerViewController.segueIdentifierThird  = @"reviewsSegue";
        
        self.containerViewController.initialSegueIdentifier = self.containerViewController.segueIdentifierSecond;
    }
}
#pragma mark - Actions
- (IBAction)segmentedValueChanged:(id)sender {
    
    UISegmentedControl *seg = sender;
    [self.containerViewController swapViewControllers:(int)seg.selectedSegmentIndex];
}

@end
