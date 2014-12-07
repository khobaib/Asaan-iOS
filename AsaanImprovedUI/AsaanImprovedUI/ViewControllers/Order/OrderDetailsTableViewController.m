//
//  OrderDetailsTableViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "OrderDetailsTableViewController.h"
#import "MenuTableViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"

@interface OrderDetailsTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *partySize;
@property (weak, nonatomic) IBOutlet UILabel *orderTime;

@property (nonatomic) NSInteger minOrderTime;
@property (nonatomic) NSInteger timeIncrementInterval;
@property (nonatomic) NSInteger timeDecrementInterval;
@property (nonatomic) NSInteger minPartySize;
@property (nonatomic) NSInteger currPartySize;
@property (nonatomic) NSDate *currOrderTime;

@end

@implementation OrderDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.minPartySize = self.currPartySize = 1;
    self.partySize.text = [NSString stringWithFormat:@"%d", self.currPartySize];
    self.minOrderTime = 3600;
    self.timeIncrementInterval = 900; // 15 min
    self.timeDecrementInterval = -900; // 15 min
    
    NSDate *currentTime = [NSDate date];
    NSDate *minOrderDate = [currentTime dateByAddingTimeInterval:self.minOrderTime];
    self.currOrderTime = minOrderDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.orderTime.text = [dateFormatter stringFromDate: self.currOrderTime];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)decPartySize:(id)sender
{
    if (self.currPartySize > self.minPartySize)
        self.partySize.text = [NSString stringWithFormat:@"%d", --self.currPartySize];
}
- (IBAction)decOrderTime:(id)sender
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.timeDecrementInterval
                                                  sinceDate:self.currOrderTime];
    
    NSDate *minOrderTime = [[NSDate alloc] initWithTimeInterval:self.minOrderTime
                                                      sinceDate:currentTime];
    self.currOrderTime = [newTime laterDate:minOrderTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.orderTime.text = [dateFormatter stringFromDate: self.currOrderTime];
}
- (IBAction)incPartySize:(id)sender
{
    self.partySize.text = [NSString stringWithFormat:@"%d", ++self.currPartySize];
}
- (IBAction)incOrderTime:(id)sender
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.timeIncrementInterval
                                                 sinceDate:self.currOrderTime];
    
    NSDate *minOrderTime = [[NSDate alloc] initWithTimeInterval:self.minOrderTime
                                                      sinceDate:currentTime];
    self.currOrderTime = [newTime laterDate:minOrderTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.orderTime.text = [dateFormatter stringFromDate: self.currOrderTime];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueOrderToMenu"])
    {
        MenuTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
        [controller setSavedUserAddress:self.savedUserAddress];
        [controller setSavedUserCard:self.savedUserCard];
        [controller setOrderType:self.orderType];
        [controller setPartySize:self.currPartySize];
        [controller setOrderTime:self.currOrderTime];
    }
}

@end
