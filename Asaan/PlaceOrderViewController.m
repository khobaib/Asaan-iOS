//
//  PlaceOrderViewController.m
//  Asaan
//
//  Created by MC MINI on 10/26/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "PlaceOrderViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "Order.h"
#import "DatabaseHelper.h"
#import "CheckoutOrderViewController.h"


@interface PlaceOrderViewController ()

@end

@implementation PlaceOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.stepper.minimumValue=1;
    self.stepper.maximumValue=10;
    [self setValueOnUI];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setValueOnUI{
    self.itemName.text=self.item.shortDescription;
    self.price.text=[NSString stringWithFormat:@"$%.2f",[self.item.price floatValue]/100.0];
    self.quantity.text=@"1";
    
}

-(IBAction)steperAction:(id)sender{
    UIStepper *steper=(UIStepper *)sender;
    double value = [steper value];
    
    [self.quantity setText:[NSString stringWithFormat:@"%d", (int)value]];
}


-(IBAction)placeorder:(id)sender{
    
    if([DatabaseHelper saveOrder:self.item quantityStr:self.quantity.text noteStr:self.specialPropertyLabel.text]){
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Go to checkout?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES",nil];
        [alert show];
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Some problem occure.Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    

    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex ==1){
     
        CheckoutOrderViewController *chekout=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"placeorder"];
        
        [self.navigationController pushViewController:chekout animated:YES];
       
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark -keyboard show height


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    int height=[UIScreen mainScreen].bounds.size.height;
    
    
    if(height==480){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.holderview.frame;
            f.origin.y = -60; //set the -35.0f to your required value
            self.holderview.frame = f;
        }];
        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.holderview.frame;
            f.origin.y = -40; //set the -35.0f to your required value
            self.holderview.frame = f;
        }];
        
        
    }
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.holderview.frame;
        f.origin.y = 0.0;
        self.holderview.frame = f;
    }];
}


@end
