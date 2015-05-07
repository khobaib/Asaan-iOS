//
//  OrderTimeTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/28/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "OrderTimeTableViewController.h"
#import "AppDelegate.h"
#import "MenuTableViewController.h"
#import "UtilCalls.h"

@interface OrderTimeTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (weak, nonatomic) IBOutlet UILabel *partySize;

@property (nonatomic) long minOrderTime;
@property (nonatomic) long timeIncrementInterval;
@property (nonatomic) long timeDecrementInterval;
@property (nonatomic) int minPartySize;
@property (nonatomic) int currPartySize;
@property (nonatomic) NSDate *currOrderTime;

@end

@implementation OrderTimeTableViewController
@synthesize selectedStore = _selectedStore;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.minPartySize = self.currPartySize = 1;
    self.partySize.text = [NSString stringWithFormat:@"%d", self.currPartySize];
    self.minOrderTime = [UtilCalls ORDER_PREP_TIME];
    self.timeIncrementInterval = 900; // 15 min
    self.timeDecrementInterval = -900; // 15 min
    
    NSDate *currentTime = [self getDateRoundedTo15Mins:[NSDate date]];
    NSDate *minOrderDate = [currentTime dateByAddingTimeInterval:self.minOrderTime];
    self.currOrderTime = minOrderDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.orderTime.text = [dateFormatter stringFromDate: self.currOrderTime];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [UtilCalls setupStaticHeaderViewForTable:self.tableView WithTitle:self.selectedStore.name AndSubTitle:@"Please select your party size and desired time."];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

#pragma mark - Action Buttons
- (IBAction)decOrderTime:(id)sender
{
    NSDate *currentTime = [self getDateRoundedTo15Mins:[NSDate date]];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.timeDecrementInterval
                                                 sinceDate:self.currOrderTime];
    
    NSDate *minOrderTime = [[NSDate alloc] initWithTimeInterval:self.minOrderTime
                                                      sinceDate:currentTime];
    self.currOrderTime = [newTime laterDate:minOrderTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.orderTime.text = [dateFormatter stringFromDate: self.currOrderTime];
}
- (IBAction)incOrderTime:(id)sender
{
    NSDate *currentTime = [self getDateRoundedTo15Mins:[NSDate date]];
    NSDate *newTime = [[NSDate alloc] initWithTimeInterval:self.timeIncrementInterval
                                                 sinceDate:self.currOrderTime];
    
    NSDate *minOrderTime = [[NSDate alloc] initWithTimeInterval:self.minOrderTime
                                                      sinceDate:currentTime];
    self.currOrderTime = [newTime laterDate:minOrderTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.orderTime.text = [dateFormatter stringFromDate: self.currOrderTime];
}
- (IBAction)decPartySize:(id)sender
{
    if (self.currPartySize > self.minPartySize)
        self.partySize.text = [NSString stringWithFormat:@"%d", --self.currPartySize];
}
- (IBAction)incPartySize:(id)sender
{
    self.partySize.text = [NSString stringWithFormat:@"%d", ++self.currPartySize];
}

-(NSDate *)getDateRoundedTo15Mins:(NSDate *)date
{
    NSDateComponents *time = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    NSInteger minutes = [time minute];
    NSInteger newMinutes = minutes;
    if (0 < minutes && minutes <= 15)
        newMinutes = 15;
    else if (15 < minutes && minutes <= 30)
        newMinutes = 30;
    else if (15 < minutes && minutes <= 30)
        newMinutes = 45;
    else
        newMinutes = 60;
    
    [time setMinute: newMinutes];
    return [[NSCalendar currentCalendar] dateFromComponents:time];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"segueOrderTimeToMenu"])
    {
        MenuTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
        [controller setOrderType:self.orderType];
        [controller setPartySize:self.currPartySize];
        [controller setOrderTime:self.currOrderTime];
        [controller setBMenuIsInOrderMode:YES];
    }
}

@end
