//
//  UpdateProfileTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/30/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "UpdateProfileTableViewController.h"
#import "AppDelegate.h"
#import "SHSPhoneTextField.h"
#import <Parse/Parse.h>
#import "InlineCalls.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "UtilCalls.h"

@interface UpdateProfileTableViewController ()<UINavigationControllerDelegate,
UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView * imgPhoto;
@property (strong, nonatomic) IBOutlet UITextField * txtFldFirstName;
@property (strong, nonatomic) IBOutlet UITextField * txtFldLastName;
@property (strong, nonatomic) IBOutlet UITextField * txtFldEmail;
@property (strong, nonatomic) IBOutlet SHSPhoneTextField * txtFldPhone;

@property (strong, nonatomic) IBOutlet UISlider * sldrTip;

@property (strong, nonatomic) IBOutlet UILabel * lblSldrValue;

@property (weak, nonatomic) IBOutlet UITextField *lblPaymentInfo;
@property (strong, nonatomic) UITapGestureRecognizer * tapToRemoveKeyboard;
@property (strong, nonatomic) UITapGestureRecognizer * tapImage;

@end

@implementation UpdateProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIColor *color = [UIColor lightTextColor];
    self.txtFldFirstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"John" attributes:@{NSForegroundColorAttributeName: color}];
    self.txtFldLastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Smith" attributes:@{NSForegroundColorAttributeName: color}];
    self.txtFldEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"email@example.com" attributes:@{NSForegroundColorAttributeName: color}];
    self.txtFldPhone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"(***)***-****" attributes:@{NSForegroundColorAttributeName: color}];
    
    self.tapToRemoveKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToRemoveKeyboardDetected)];
    self.tapToRemoveKeyboard.numberOfTapsRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:self.tapToRemoveKeyboard];
    self.tapToRemoveKeyboard.cancelsTouchesInView = NO;
    
    self.tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    self.tapImage.numberOfTapsRequired = 1;
    [_imgPhoto setUserInteractionEnabled:YES];
    [_imgPhoto addGestureRecognizer:self.tapImage];
    
    _imgPhoto.layer.cornerRadius = self.imgPhoto.frame.size.width / 2;
    _imgPhoto.clipsToBounds = YES;
    _imgPhoto.layer.borderWidth = 3.0f;
    _imgPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [_txtFldPhone.formatter setDefaultOutputPattern:@"(###) ###-####"];
    _txtFldPhone.formatter.prefix = @"+1 ";
    
    _sldrTip.minimumValue = 18;
    _sldrTip.maximumValue = 50;
    _sldrTip.continuous = YES;
    _sldrTip.value = round(_sldrTip.value);
    
    _lblSldrValue.text = [NSString stringWithFormat:@"%d%%", (int) _sldrTip.value];
    
    //
    PFUser * user = [PFUser currentUser];
    
    if (user != nil)
    {
        if (!IsEmpty(user[@"firstName"]))
            _txtFldFirstName.text = user[@"firstName"];
        if (!IsEmpty(user[@"lastName"]))
            _txtFldLastName.text = user[@"lastName"];
        if (!IsEmpty(user[@"email"]))
            _txtFldEmail.text = user[@"email"];
        if (!IsEmpty(user[@"phone"]))
            _txtFldPhone.text = user[@"phone"];
        if (!IsEmpty(user[@"tip"]))
        {
            _lblSldrValue.text = [NSString stringWithFormat:@"%@%%", user[@"tip"]];
            NSString *tipStr = user[@"tip"];
            int tip = tipStr.intValue;
            _sldrTip.value = tip;
        }
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = YES;
    
    NSString *profilePhotoUrl=user[@"profilePhotoUrl"];
    
    if (!IsEmpty(profilePhotoUrl))
    {
        [_imgPhoto sd_setImageWithURL:[NSURL URLWithString:profilePhotoUrl]];
        hud.hidden = YES;
    }
    else
    {
        PFFile * file = user[@"picture"];
        
        if (file != nil)
        {
            hud.hidden = YES;
            [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
             {
                 hud.hidden = YES;
                 if (!error)
                 {
                     _imgPhoto.image = [UIImage imageWithData:imageData];
                 }
             }];
        }
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Prevent keyboard from showing by default
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark === UITextFieldDelegate ===
#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    UITextField *next = theTextField.nextTextField;
    if (next) {
        [next becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
    
    return YES;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 5)
        [self performSegueWithIdentifier:@"segueUpdateProfileToAddPayment" sender:self];
        //segueUpdateProfileToAddPayment
}

#pragma mark

- (BOOL) isValidForm
{
    if (IsEmpty(_txtFldFirstName.text))
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter first name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    if (IsEmpty(_txtFldLastName.text))
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter last name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    if (IsEmpty(_txtFldEmail.text))
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    if (IsEmpty(_txtFldPhone.text) || _txtFldPhone.text.length < 10)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    NSString * filterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];
    
    if (![emailTest evaluateWithObject:_txtFldEmail.text])
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    return YES;
}

#pragma mark

- (IBAction) sldrTipChanged:(id) sender
{
    _sldrTip.value = round(_sldrTip.value);
    
    _lblSldrValue.text = [NSString stringWithFormat:@"%d%%", (int) _sldrTip.value];
}

- (IBAction) onPressSave:(id) sender
{
    if (![self isValidForm])
        return;
    
    __block MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFUser * user = [PFUser currentUser];
    user[@"firstName"] = _txtFldFirstName.text;
    user[@"lastName"] = _txtFldLastName.text;
    user[@"email"] = _txtFldEmail.text;
    user[@"phone"] = _txtFldPhone.text;
    user[@"tip"] = [NSString stringWithFormat:@"%ld", (long)_sldrTip.value];
    
    [user saveInBackgroundWithBlock:^(BOOL complete, NSError * error)
     {
         AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
         appDelegate.globalObjectHolder.currentUser.firstName = _txtFldFirstName.text;
         appDelegate.globalObjectHolder.currentUser.lastName = _txtFldLastName.text;
         appDelegate.globalObjectHolder.currentUser.email = _txtFldEmail.text;
         appDelegate.globalObjectHolder.currentUser.phone = _txtFldPhone.text;
         appDelegate.globalObjectHolder.currentUser.defaultTip = [NSNumber numberWithLong:(long)_sldrTip.value];
         
         [hud hide:YES];
         if (!error)
         {
             UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Profile successfully saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
         else
         {
             UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
     }];
}

- (void) tapDetected
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)tapToRemoveKeyboardDetected
{
    UIView* view = self.tapToRemoveKeyboard.view;
    CGPoint loc = [self.tapToRemoveKeyboard locationInView:view];
    UIView* subview = [view hitTest:loc withEvent:nil];
    if ([subview isEqual:self.txtFldEmail] == false &&
        [subview isEqual:self.txtFldFirstName] == false &&
        [subview isEqual:self.txtFldLastName] == false &&
        [subview isEqual:self.txtFldPhone] == false)
    {
        [self.view endEditing:YES];
    }
}

#pragma mark

- (void) imagePickerController:(UIImagePickerController *) picker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if (chosenImage != nil)
    {
        self.imgPhoto.image = chosenImage;
        NSData * imageData = UIImagePNGRepresentation(chosenImage);
        PFUser * user = [PFUser currentUser];
        NSString * name = [NSString stringWithFormat:@"%@.png",user.username];
        PFFile * imageFile = [PFFile fileWithName:name data:imageData];
        user[@"picture"] = imageFile;
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *) picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
