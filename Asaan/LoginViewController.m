//
//  LoginViewController.m
//  Asaan
//
//  Created by MC MINI on 9/24/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "LoginViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "ProfileViewController.h"


@interface LoginViewController ()

@end

static NSString * const kClientId = @"622430232205-vjs2qkqr73saoov2vacspnctvig7nq6r.apps.googleusercontent.com";

@implementation LoginViewController

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
    UIColor *color = [UIColor colorWithRed:0.8f green:0.8f blue:0.8 alpha:1];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email:" attributes:@{NSForegroundColorAttributeName: color}];
    
    self.passwordFild.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password:" attributes:@{NSForegroundColorAttributeName: color}];

    
    
    
    // Do any additional setup after loading the view.
}

-(IBAction)login:(id)sender{
    NSString *email=self.emailField.text;
    NSString *pass=self.passwordFild.text;
    
    if([email isEqualToString:@""]||[pass isEqualToString:@""]){
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Enter Email And Password." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PFUser logInWithUsernameInBackground:email password:pass block:^(PFUser *user,NSError *error){
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(user){
            NSLog(@"%@",[user description]);
            [self performSegueWithIdentifier:@"profilePage" sender:self];

        }else{
            NSLog(@"%@",[error userInfo]);
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Asaan" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    return [textField resignFirstResponder];
}



- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
        self.navigationController.navigationBarHidden=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    int height=[UIScreen mainScreen].bounds.size.height;

    
    if(height==480){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view.frame;
            f.origin.y = -60; //set the -35.0f to your required value
            self.view.frame = f;
        }];
        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view.frame;
            f.origin.y = -40; //set the -35.0f to your required value
            self.view.frame = f;
        }];
        

    }
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

-(IBAction)forgetPassword:(id)sender{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Asaan" message:@"Enter your mail." delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"Done", nil];
    
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    /* Display a numerical keypad for this text field */
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    
    alertView.tag=1;
    
    [alertView show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==1 && alertView.tag==1){
     
        
        
        NSString *email=[alertView textFieldAtIndex:0].text;
        
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL success,NSError *error){
            
            if(success && (error==nil)){
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Asaan" message:@"Password reset email was sent to your mail address." delegate:nil cancelButtonTitle:@"Cancle" otherButtonTitles:@"Done", nil];
                [alertView show];
            }else{
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Asaan" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }
            
            
            
        }];

    }
    
    
}





-(IBAction)fbLogin:(id)sender{
    NSArray *permissions=@[@"public_profile", @"user_friends",@"email"];
    
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden=NO;
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            hud.hidden=YES;
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            
            
            hud.hidden=YES;
            [self _loadData];
            
        } else {
            NSLog(@"User logged in through Facebook!");
            hud.hidden=YES;
            // [self _loadData];
            
            ProfileViewController *acv=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"profile"];
            [self.navigationController pushViewController:acv animated:YES];
            
        }
    }];
    
}
- (void)_loadData {
    
    
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    
    
    
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
            
            NSDictionary *userData = (NSDictionary *)result;
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init] ;
            
            [dateFormatter setDateFormat:@"dd/MM/YYYY"];
            PFUser *user=[PFUser currentUser];
            
            user[@"firstName"]=userData[@"first_name"];
            
            user[@"lastName"]=userData[@"last_name"];
            user[@"profilePhotoUrl"]=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
            
            NSLog(@" birthday %@",userData[@"birthday"]);
            
            // user[@"birthDate"]=[dateFormatter dateFromString:userData[@"birthday"]];
            
            NSLog(@"log");
            user.email=userData[@"email"];
            
            
            [user saveInBackgroundWithBlock:^(BOOL complete,NSError *error){
                
                ProfileViewController *acv=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"profile"];
                [self.navigationController pushViewController:acv animated:YES];
                
                hud.hidden=YES;
            }];
            
        }else{
            
            hud.hidden=YES;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
    }];
}


#pragma mark -gPlus login

-(void)GplusInit{
    
    
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = kClientId;
    
    
    signIn.scopes = @[ kGTLAuthScopePlusLogin,kGTLAuthScopePlusUserinfoEmail,kGTLAuthScopePlusUserinfoProfile];
    signIn.delegate = self;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    
}

-(IBAction)gPlusLogin:(id)sender{
    NSLog(@"log");
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden=NO;
    
    [[GPPSignIn sharedInstance] authenticate];
}


- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    NSLog(@"log");
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    
    if(!error) {
        // Get the email address.
        hud.hidden=YES;
        [self FatchDatafromGplusWithAuth:auth];
        
    }else{
        hud.hidden=YES;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}



-(void)FatchDatafromGplusWithAuth:(GTMOAuth2Authentication *)auth{
    NSLog(@"%@", [GPPSignIn sharedInstance].authentication.userEmail);
    
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init] ;
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    hud.hidden=NO;
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    hud.hidden=YES;
                    GTMLoggerError(@"Error: %@", error);
                } else {
                    // Retrieve the display name and "about me" text
                    
                    
                    
                    [self loginWithParseGplus:person];
                    
                }
            }];
    
}

-(void)loginWithParseGplus:(GTLPlusPerson *)person{
    
    
    [PFUser logInWithUsernameInBackground:person.identifier password:person.ETag block:^(PFUser *user,NSError *error){
        if(error)
        {
            
            NSLog(@"%@",[error localizedDescription]);
            [self sighupWithParseGplus:person];
        }else{
            hud.hidden=YES;
            ProfileViewController *acv=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"profile"];
            [self.navigationController pushViewController:acv animated:YES];
            
            
        }
        
    }];
}
-(void)sighupWithParseGplus:(GTLPlusPerson *)person{
    PFUser *user=[PFUser user];
    user.email=[GPPSignIn sharedInstance].authentication.userEmail;
    user.password=person.ETag;
    user.username=person.identifier;
    
    NSLog(@"%@",person.ETag);
    user[@"firstName"]=person.name.givenName;
    user[@"lastName"]=person.name.familyName;
    
    user[@"profilePhotoUrl"]=[[person.image.url componentsSeparatedByString:@"?"]objectAtIndex:0];
    
    [user signUpInBackgroundWithBlock:^(BOOL issuccess,NSError *error){
        hud.hidden=YES;
        if(issuccess && !error){
            NSLog(@"registration successful");
            ProfileViewController *acv=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"profile"];
            [self.navigationController pushViewController:acv animated:YES];
            
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[[error userInfo] objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
