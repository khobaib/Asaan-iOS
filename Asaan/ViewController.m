//
//  ViewController.m
//  Asaan
//
//  Created by MC MINI on 9/9/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "ViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "ProfileViewController.h"
#import "SignupViewController.h"
#import <AddressBook/AddressBook.h>
#import "MBProgressHUD.h"
#import "ResturantListViewController.h"
#import "LoginViewController.h"
#import "GTLStoreendpoint.h"

@interface ViewController ()


@end

static NSString * const kClientId = @"622430232205-vjs2qkqr73saoov2vacspnctvig7nq6r.apps.googleusercontent.com";
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self GplusInit];
    
    [self askContactsPermission];
    
    int height=[UIScreen mainScreen].bounds.size.height;
    if(height==480){
        [self.image setImage:[UIImage imageNamed:@"landingpage2.png"]];
     }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        locationmanager=[[CLLocationManager alloc]init];
        //  manager.delegate = self;
        [locationmanager requestAlwaysAuthorization];
    }else{
          locationmanager=[[CLLocationManager alloc]init];
        [locationmanager startUpdatingLocation];
        [locationmanager stopUpdatingLocation];
    }
    
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.hidden=YES;
    
    self.navigationController.navigationBarHidden=YES;
    
   // [PFUser logOut];
    //[[GPPSignIn sharedInstance] signOut];
    
    [self test];
    
    
    
}


-(void)test{
    static GTLServiceStoreendpoint *storeService=nil;
    
    if(!storeService){
        storeService=[[GTLServiceStoreendpoint alloc]init];
        storeService.retryEnabled=YES;
        
        
    }
    
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreMenuItemsForMenuWithStoreId:1 menuPOSId:1];
    
  
    [storeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLObject *object,NSError *error){
        
        NSLog(@"%@",object.JSONString);
        
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=YES;

}

#pragma mark -FBLogin

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

#pragma mark -Page button

-(IBAction)Signup:(id)sender{
    SignupViewController *svc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"Signup1"];
    [self.navigationController pushViewController:svc animated:YES];
}



-(IBAction)skipe:(id)sender{
 
  //  ResturantListViewController *rvc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"rabbi101"];
    
    //[self presentViewController:rvc animated:YES completion:nil];
}

-(IBAction)login:(id)sender{
 
    LoginViewController *login=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"login"];
    [self presentSignInViewController:login];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





-(void)askContactsPermission{
    ABAddressBookRef  addressBook_ = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook_, ^(bool granted, CFErrorRef error)
                                                 {
                                                     if (granted == NO)
                                                     {
                                                         // Show an alert for no contact Access
                                                     }
                                                 });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        // The user has previously given access, good to go
    }
    else
    {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}



@end
