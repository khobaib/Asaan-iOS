//
//  SignupViewController.m
//  Asaan
//
//  Created by MC MINI on 9/9/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "SignupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PaymentInfo.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
@interface SignupViewController ()

@end

@implementation SignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden=NO;
    [self initBirthdatePicker];
    [self actionBarInit];
    
}

#pragma mark -UIelement init

-(void)initBirthdatePicker{
    birthdayPicker = [[UIDatePicker alloc] init];
    birthdayPicker.datePickerMode=UIDatePickerModeDate;
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 50, 37)];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onPaymentMethodSelection)];
    [accessoryView setItems:[NSArray arrayWithObject:doneButton]];
    
    self.birthdate.inputView = birthdayPicker;
    self.birthdate.inputAccessoryView = accessoryView;
}

-(void)actionBarInit{
    UIPageControl *pagecontrol=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 50, 37)];
    pagecontrol.numberOfPages=3;
    pagecontrol.currentPageIndicatorTintColor=[UIColor colorWithRed:(187.0/255.0) green:(137.0/255.0) blue:(33.0/255.0) alpha:1.0f];
    pagecontrol.pageIndicatorTintColor=[UIColor whiteColor];
    pagecontrol.userInteractionEnabled=NO;

    
    
    //self.navigationItem.titleView =pagecontrol;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"nextSinguppage.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=btn;
    

 
    UIButton *imgbtn=[[UIButton alloc]initWithFrame:CGRectMake(-10, 0, 125, 40)];
    [imgbtn setImage:[UIImage imageNamed:@"asaanTopLogo.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *lbtn=[[UIBarButtonItem alloc]initWithCustomView:imgbtn];
    UIBarButtonItem *mbtn=[[UIBarButtonItem alloc]initWithCustomView:pagecontrol];
    
    [self.navigationItem setLeftBarButtonItems:@[lbtn,mbtn]];
    
}


- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

                         
  - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
                             
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        self.imageView.image = chosenImage;
      image=chosenImage;
                             
        [picker dismissViewControllerAnimated:YES completion:NULL];
                             
}


-(void)nextPressed:(id)sender{
    
  //  PaymentInfo *paytmentInfo=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"Signup2"];
    //[self.navigationController pushViewController:paytmentInfo animated:YES];
    
   // return;
    
    
    NSString *firstName=self.firstName.text;
    NSString *lastName=self.lastName.text;
    NSString *password=self.password.text;
    NSString *phoneNo=self.phoneno.text;
    NSString *email=self.email.text;
    NSString *birthdayString=self.birthdate.text;
    
    if([firstName isEqualToString:@""] || [lastName isEqualToString:@""] || [password isEqualToString:@""]|| [phoneNo isEqualToString:@""] || [email isEqualToString:@""]||[birthdayString isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Enter All the information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
     
        return;
    }
    
    PFUser *user=[PFUser user];
    user.email=email;
    user.password=password;
    user.username=[NSString stringWithFormat:@"%@%@",firstName,lastName];
    user[@"phone"]=phoneNo;
    user[@"birthDate"]=birthdayPicker.date;
    user[@"firstName"]=firstName;
    user[@"lastName"]=lastName;
    if(image!=nil){
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *name=[NSString stringWithFormat:@"%@.png",user.username];
        PFFile *imageFile = [PFFile fileWithName:name data:imageData];
        user[@"picture"]=imageFile;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        hud.hidden=YES;
        if (!error) {
            // Hooray! Let them use the app now.
            PaymentInfo *paytmentInfo=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"Signup2"];
            [self.navigationController pushViewController:paytmentInfo animated:YES];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
    }];
    
    
   
    
}



-(void) onPaymentMethodSelection{

    [self.birthdate resignFirstResponder];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init] ;
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    self.birthdate.text=[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:birthdayPicker.date]];
    
}


#pragma mark - KeyboardInit

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    return [textField resignFirstResponder];
}



- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    if([self.birthdate isFirstResponder]){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view.frame;
            f.origin.y = -60; //set the -35.0f to your required value
            self.view.frame = f;
        }];
    }
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f+self.navigationController.navigationBar.frame.size.height+20;
        self.view.frame = f;
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
