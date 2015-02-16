//
//  SignupProfileViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 11/10/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "SignupProfileViewController.h"
#import "UIColor+SavoirGoldColor.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "InlineCalls.h"
#import "UIImageView+WebCache.h"
#import "SHSPhoneTextField.h"

@interface SignupProfileViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet SHSPhoneTextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIScrollView *signupProfileScrollView;

@end

@implementation SignupProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    [super setBaseScrollView:_signupProfileScrollView];
    
    self.btnPhoto.layer.cornerRadius = self.btnPhoto.frame.size.width / 2;
    self.btnPhoto.clipsToBounds = YES;
    self.btnPhoto.layer.borderWidth = 3.0f;
    self.btnPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // NOTE: Rounded rect
    // self.profileImageView.layer.cornerRadius = 10.0f;
    
    UIColor *color = [UIColor lightTextColor];
    _txtLastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Smith" attributes:@{NSForegroundColorAttributeName: color}];
    _txtFirstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"John" attributes:@{NSForegroundColorAttributeName: color}];
    _txtPhone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"(***) ***-****" attributes:@{NSForegroundColorAttributeName: color}];
    [_txtPhone.formatter setDefaultOutputPattern:@"(###) ###-####"];
    _txtPhone.formatter.prefix = @"+1 ";
    
    PFUser *user = [PFUser currentUser];
    if (user != nil){
        if (!IsEmpty(user[@"firstName"]))
            _txtFirstName.text = user[@"firstName"];
        if (!IsEmpty(user[@"lastName"]))
            _txtLastName.text = user[@"lastName"];
        if (!IsEmpty(user[@"phone"]))
            _txtPhone.text = user[@"phone"];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = YES;

    NSString *profilePhotoUrl=user[@"profilePhotoUrl"];

    if(!IsEmpty(profilePhotoUrl)){
        [_btnPhoto.imageView sd_setImageWithURL:[NSURL URLWithString:profilePhotoUrl]];
    } else {
        PFFile *file=user[@"picture"];
        if(file!=nil){
            hud.hidden = YES;
            [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                hud.hidden = NO;
               if (!error) {
                    _btnPhoto.imageView.image = [UIImage imageWithData:imageData];
                }
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (IBAction)btnPhotoClick:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if (chosenImage != nil){
        _btnPhoto.imageView.image = chosenImage;
        NSData *imageData = UIImagePNGRepresentation(chosenImage);
        PFUser *user = [PFUser currentUser];
        NSString *name=[NSString stringWithFormat:@"%@.png",user.username];
        PFFile *imageFile = [PFFile fileWithName:name data:imageData];
        user[@"picture"]=imageFile;
    }
}

- (IBAction)btnSaveClick:(id)sender {
    if (IsEmpty(_txtFirstName.text) || IsEmpty(_txtLastName.text) || IsEmpty(_txtPhone.text) || _txtPhone.text.length < 10)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter name and phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        PFUser *user=[PFUser currentUser];
        user[@"phone"]=_txtPhone.text;
        user[@"firstName"]=_txtFirstName.text;
        user[@"lastName"]=_txtLastName.text;
        
        [user saveInBackground];
        [self performSegueWithIdentifier:@"segueSignupProfileToStoreList" sender:self];
    }
}

@end