//
//  PaymentInfo.m
//  Asaan
//
//  Created by MC MINI on 9/21/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "PaymentInfo.h"
#include "InviteFriendsViewController.h"
#import "Stripe.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>


@interface PaymentInfo ()

@end

@implementation PaymentInfo

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
    
    self.payment.delegate=self;
    
    //PTKView *paymentView = [[PTKView alloc] initWithFrame:CGRectMake(15, 100, 290, 55)];
    //paymentView.delegate = self;
    //self.payment = paymentView;
    //[self.view addSubview:paymentView];
    isCardValid=NO;
    
    [self actionBarInit];
}


-(void)actionBarInit{
    UIPageControl *pagecontrol=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 50, 37)];
    pagecontrol.numberOfPages=3;
    pagecontrol.currentPageIndicatorTintColor=[UIColor colorWithRed:(187.0/255.0) green:(137.0/255.0) blue:(33.0/255.0) alpha:1.0f];
    pagecontrol.pageIndicatorTintColor=[UIColor whiteColor];
    pagecontrol.userInteractionEnabled=NO;
    pagecontrol.currentPage=1;

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"nextSinguppage.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=btn;
    

    
    
    UIButton *imgbtn=[[UIButton alloc]initWithFrame:CGRectMake(-10, 0, 125, 40)];
    [imgbtn setImage:[UIImage imageNamed:@"asaanTopLogo.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *lbtn=[[UIBarButtonItem alloc]initWithCustomView:imgbtn];
    UIBarButtonItem *mbtn=[[UIBarButtonItem alloc]initWithCustomView:pagecontrol];
    
    [self.navigationItem setLeftBarButtonItems:@[lbtn,mbtn]];}

-(void)nextPressed:(id)sender{
    InviteFriendsViewController *paytmentInfo=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"Signup3"];
    [self.navigationController pushViewController:paytmentInfo animated:YES];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    return [textField resignFirstResponder];
}


- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid{
 
    isCardValid=valid;
}

-(IBAction)addCard:(id)sender{
    if(!isCardValid){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"The card number you have enterd is not a valid card number" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    STPCard *card = [[STPCard alloc] init];
    card.number = self.payment.card.number;
    card.expMonth = self.payment.card.expMonth;
    card.expYear = self.payment.card.expYear;
    card.cvc = self.payment.card.cvc;
    

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error) {
            // handle the error as you did previously
            
            UIAlertView *alert1=[[UIAlertView alloc]initWithTitle:@"Error" message:[error.userInfo description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert1 show];
        } else {
            PFObject *tokenOb=[PFObject objectWithClassName:@"UserStripeCard"];
            
            [self addPfObject:tokenOb forKey:@"address_city" value:token.card.addressCity];

            [self addPfObject:tokenOb forKey:@"address_country" value:token.card.addressCountry];

            [self addPfObject:tokenOb forKey:@"address_line1" value:token.card.addressLine1];

            [self addPfObject:tokenOb forKey:@"address_line2" value:token.card.addressLine2];

            [self addPfObject:tokenOb forKey:@"address_state" value:token.card.addressState];

            [self addPfObject:tokenOb forKey:@"address_zip" value:token.card.addressZip];

            [self addPfObject:tokenOb forKey:@"country" value:token.card.country];
            [self addPfObject:tokenOb forKey:@"cvc_check" value:token.card.cvc];
            [self addPfObject:tokenOb forKey:@"exp_year" value:[NSNumber numberWithInt:token.card.expYear]];
            [self addPfObject:tokenOb forKey:@"exp_month" value:[NSNumber numberWithInt:token.card.expMonth]];
            [self addPfObject:tokenOb forKey:@"fingerprint" value:token.card.fingerprint];
            [self addPfObject:tokenOb forKey:@"last4" value:token.card.last4];
            [self addPfObject:tokenOb forKey:@"name" value:token.card.name];
            [self addPfObject:tokenOb forKey:@"stripeCardid" value:token.card.number];
            [self addPfObject:tokenOb forKey:@"user" value:[PFUser currentUser]];

            
         /*   tokenOb[@"address_city"]=token.card.addressCity;
            tokenOb[@"address_country"]=token.card.addressCountry;
            tokenOb[@"address_line1"]=token.card.addressLine1;
            tokenOb[@"address_line2"]=token.card.addressLine2;
            tokenOb[@"address_state"]=token.card.addressState;
            tokenOb[@"address_zip"]=token.card.addressZip;
            tokenOb[@"brand"]=token.card.type;
            tokenOb[@"country"]=token.card.country;
            tokenOb[@"cvc_check"]=token.card.cvc;
            tokenOb[@"exp_year"]=[NSNumber numberWithInt:token.card.expYear] ;
            tokenOb[@"exp_month"]=[NSNumber numberWithInt:token.card.expMonth];
            tokenOb[@"fingerprint"]=token.card.fingerprint;

            tokenOb[@"last4"]=token.card.last4;

            tokenOb[@"name"]=token.card.name;

            tokenOb[@"stripeCardid"]=token.card.number;
            tokenOb[@"user"]=[PFUser currentUser];*/
            
           [tokenOb saveEventually:^(BOOL success,NSError *error){
               
                if(success){
                    NSLog(@"done");
                }else{
                    NSLog(@"%@",[error userInfo]);
                }
           }];

            // submit the token to your payment backend as you did previously
        }
    }];

    
}

-(void)addPfObject:(PFObject *)object forKey:(NSString *)key value:(id)value{
    if(value==nil){
        object[key]=[NSNull null];
        NSLog(@"null");
    }else{
        object[key]=value;
        NSLog(@"%@",value);
    }
}


-(IBAction)Skip:(id)sender{
    InviteFriendsViewController *paytmentInfo=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"Signup3"];
    [self.navigationController pushViewController:paytmentInfo animated:YES];
}


-(void)addCardToServer:(STPCard *)card token:(NSString *)token{

    //PFObject *card=[PFObject objectWithClassName:@""];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
