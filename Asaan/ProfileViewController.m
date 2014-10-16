//
//  AccountViewController.m
//  Asaan
//
//  Created by MC MINI on 9/9/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "ProfileViewController.h"
#import "Stripe.h"
#import "ResturantListViewController.h"
#import "UIImageView+WebCache.h"
@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    self.navigationController.navigationBarHidden=NO;
    [self setDataOnUI];
    // Do any additional setup after loading the view.
}

-(void)setDataOnUI{
    PFUser *user=[PFUser currentUser];
    self.nameLable.text=[NSString stringWithFormat:@"%@ %@",user[@"firstName"],user[@"lastName"]];
    self.emailLable.text=user.email;
    if(user[@"phone"]){
        self.phoneLable.text=user[@"phone"];
    }
    PFFile *file=user[@"picture"];
    if(file!=nil){
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                self.profileImage.image = [UIImage imageWithData:imageData];
            }
        }];
    }
    NSString *str=user[@"profilePhotoUrl"];
    NSLog(@"log %@",str);
    if(str!=nil){
        [self.profileImage sd_setImageWithURL:[NSURL URLWithString:str]];
    }
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)addCard:(id)sender{
    
    alert=[[UIAlertView alloc]initWithTitle:@"Inter card Info" message:@"" delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"Done", nil];
    
    
    self.paymentView = [[PTKView alloc] initWithFrame:CGRectMake(0, 0, 290, 55)];
    self.paymentView.delegate = self;
    
    [alert setValue:self.paymentView forKey:@"accessoryView"];
    
    [alert show];
}

-(IBAction)inviteFriends:(id)sender{
    [self performSegueWithIdentifier:@"inviteFriends" sender:self];
}

- (void) paymentView:(PTKView*)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"Card number: %@", card.number);
    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
    NSLog(@"Card cvc: %@", card.cvc);
    NSLog(@"Address zip: %@", card.addressZip);
    
    // self.navigationItem.rightBarButtonItem.enabled = valid;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld",(long)buttonIndex);
    if(buttonIndex==1){
        if (![self.paymentView isValid]) {
            return;
        }
        
        STPCard *card = [[STPCard alloc] init];
        card.number = self.paymentView.card.number;
        card.expMonth = self.paymentView.card.expMonth;
        card.expYear = self.paymentView.card.expYear;
        card.cvc = self.paymentView.card.cvc;
        
        NSLog(@"loged");
        [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
            if (error) {
                // handle the error as you did previously
            
                UIAlertView *alert1=[[UIAlertView alloc]initWithTitle:@"Error" message:[error.userInfo description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert1 show];
            } else {
                NSLog(@"%@",token.tokenId);
                // submit the token to your payment backend as you did previously
            }
        }];
    }
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
