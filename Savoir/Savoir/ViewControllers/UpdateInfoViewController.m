//
//  UpdateInfoViewController.m
//  Savoir
//
//  Created by Hasan Ibna Akbar on 1/4/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "UpdateInfoViewController.h"
#import "AppDelegate.h"

@interface UpdateInfoViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITextField * txtFldFirstName;
@property (strong, nonatomic) IBOutlet UITextField * txtFldLastName;
@property (strong, nonatomic) IBOutlet UITextField * txtFldEmail;
@property (strong, nonatomic) IBOutlet UITextField * txtFldPhone;
@property (strong, nonatomic) IBOutlet UITextField * txtFldPaymentInfo;
@property (strong, nonatomic) IBOutlet UITextField * txtFldFacebookProfile;

@property (strong, nonatomic) IBOutlet UISlider * sldrTip;

@property (strong, nonatomic) IBOutlet UILabel * lblSldrValue;

@end

@implementation UpdateInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    
    //
    [_txtFldFirstName setDelegate:self];
    [_txtFldLastName setDelegate:self];
    [_txtFldEmail setDelegate:self];
    [_txtFldPhone setDelegate:self];
    [_txtFldPaymentInfo setDelegate:self];
    [_txtFldFacebookProfile setDelegate:self];
    
    //
    [_txtFldFirstName setTextColor:[UIColor whiteColor]];
    [_txtFldLastName setTextColor:[UIColor whiteColor]];
    [_txtFldEmail setTextColor:[UIColor whiteColor]];
    [_txtFldPhone setTextColor:[UIColor whiteColor]];
    [_txtFldPaymentInfo setTextColor:[UIColor whiteColor]];
    [_txtFldFacebookProfile setTextColor:[UIColor whiteColor]];
    
    //
    [_txtFldFirstName setKeyboardType:UIKeyboardTypeDefault];
    [_txtFldLastName setKeyboardType:UIKeyboardTypeDefault];
    [_txtFldEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    [_txtFldPhone setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [_txtFldPaymentInfo setKeyboardType:UIKeyboardTypeDefault];
    [_txtFldFacebookProfile setKeyboardType:UIKeyboardTypeDefault];
    
    _sldrTip.minimumValue = 18;
    _sldrTip.maximumValue = 50;
    _sldrTip.continuous = YES;
    _sldrTip.value = round(_sldrTip.value);
    
    _lblSldrValue.text = [NSString stringWithFormat:@"%d%%", (int) _sldrTip.value];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark

- (IBAction) sldrTipChanged:(id) sender
{
    _sldrTip.value = round(_sldrTip.value);
    
    _lblSldrValue.text = [NSString stringWithFormat:@"%d%%", (int) _sldrTip.value];
}

#pragma mark

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark

- (void) textFieldDidBeginEditing:(UITextField *) textField
{
    
}

- (void) textFieldDidEndEditing:(UITextField *) textField
{
    
}

- (BOOL) textFieldShouldReturn:(UITextField *) textField
{
    [textField resignFirstResponder];
    
    return NO;
}

@end
