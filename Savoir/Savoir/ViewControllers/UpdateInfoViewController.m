//
//  UpdateInfoViewController.m
//  Savoir
//
//  Created by Hasan Ibna Akbar on 1/4/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "UpdateInfoViewController.h"
#import "AppDelegate.h"
#import "SHSPhoneTextField.h"
#import "PTKView.h"
#import <Parse/Parse.h>
#import "InlineCalls.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"


@interface UpdateInfoViewController () <UINavigationControllerDelegate,
        UIImagePickerControllerDelegate, PTKViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView * scrViewBase;

@property (strong, nonatomic) IBOutlet UIImageView * imgPhoto;
@property (strong, nonatomic) IBOutlet UITextField * txtFldFirstName;
@property (strong, nonatomic) IBOutlet UITextField * txtFldLastName;
@property (strong, nonatomic) IBOutlet UITextField * txtFldEmail;
@property (strong, nonatomic) IBOutlet SHSPhoneTextField * txtFldPhone;
@property (strong, nonatomic) IBOutlet UITextField * txtFldFacebookProfile;

@property (strong, nonatomic) IBOutlet UISlider * sldrTip;

@property (strong, nonatomic) IBOutlet UILabel * lblSldrValue;

@property (strong, nonatomic) IBOutlet PTKView * ptkViewPayInfo;

- (IBAction) onPressSave:(id) sender;

@end

@implementation UpdateInfoViewController
{
    BOOL _isCardValid;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    
    [super setBaseScrollView:_scrViewBase];

    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [_imgPhoto setUserInteractionEnabled:YES];
    [_imgPhoto addGestureRecognizer:singleTap];
    
    _imgPhoto.layer.cornerRadius = self.imgPhoto.frame.size.width / 2;
    _imgPhoto.clipsToBounds = YES;
    _imgPhoto.layer.borderWidth = 3.0f;
    _imgPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    
    //
    [_txtFldFirstName setDelegate:self];
    [_txtFldLastName setDelegate:self];
    [_txtFldEmail setDelegate:self];
    [_txtFldPhone setDelegate:self];
    [_txtFldFacebookProfile setDelegate:self];
    
    //
    [_txtFldFirstName setKeyboardType:UIKeyboardTypeDefault];
    [_txtFldLastName setKeyboardType:UIKeyboardTypeDefault];
    [_txtFldEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    [_txtFldPhone setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [_txtFldFacebookProfile setKeyboardType:UIKeyboardTypeDefault];
    
    [_txtFldPhone.formatter setDefaultOutputPattern:@"(###) ###-####"];
    _txtFldPhone.formatter.prefix = @"+1 ";
    
    _sldrTip.minimumValue = 18;
    _sldrTip.maximumValue = 50;
    _sldrTip.continuous = YES;
    _sldrTip.value = round(_sldrTip.value);
    
    _lblSldrValue.text = [NSString stringWithFormat:@"%d%%", (int) _sldrTip.value];
    
    [_ptkViewPayInfo setDelegate:self];
    
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
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = YES;
    
    NSString *profilePhotoUrl=user[@"profilePhotoUrl"];
    
    if (!IsEmpty(profilePhotoUrl))
    {
        [_imgPhoto sd_setImageWithURL:[NSURL URLWithString:profilePhotoUrl]];
    }
    else
    {
        PFFile * file = user[@"picture"];
        
        if (file != nil)
        {
            hud.hidden = YES;
            [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
            {
                hud.hidden = NO;
                if (!error)
                {
                    _imgPhoto.image = [UIImage imageWithData:imageData];
                }
            }];
        }
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL) animated
{
    [super viewWillAppear:animated];
    
    // Prevent keyboard from showing by default
    [self.view endEditing:YES];
}

- (void) didReceiveMemoryWarning
{
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
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    return YES;
}

-(void) tapDetected
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    [self presentViewController:picker animated:YES completion:NULL];
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

#pragma mark

- (void) paymentView:(PTKView *) paymentView withCard:(PTKCard *) card isValid:(BOOL) valid
{
    _isCardValid = valid;
    
    if (valid)
    {
        [paymentView endEditing:YES];
    }
}

#pragma mark

- (IBAction) onPressSave:(id) sender
{
    if (![self isValidForm])
        return;

    PFUser * user = [PFUser currentUser];
    user[@"firstName"] = _txtFldFirstName.text;
    user[@"lastName"] = _txtFldLastName.text;
    user[@"email"] = _txtFldEmail.text;
    user[@"phone"] = _txtFldPhone.text;
    [user saveInBackground];
    
    //[self performSegueWithIdentifier:@"segueSignupProfileToStoreList" sender:self];
}

@end
