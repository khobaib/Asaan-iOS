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


-(void)order{
    static GTLServiceStoreendpoint *storeService=nil;
    
    if(!storeService){
        storeService=[[GTLServiceStoreendpoint alloc]init];
        storeService.retryEnabled=YES;
    }
    
    NSString *orderString=[NSString stringWithFormat:@"<CHECKREQUESTS><ADDCHECK EXTCHECKID=\"Nirav\" READYTIME=\"4:45PM\" NOTE=\"Please make it spicy - no Peanuts Please\" ORDERMODE=\"@ORDER_MODE\" ><ITEMREQUESTS><ADDITEM QTY=\"1\" ITEMID=\"7007\" FOR=\"Nirav\" ><MODITEM ITEMID=\"90204\" /></ADDITEM><ADDITEM QTY=\"1\" ITEMID=\"7007\" FOR=\"Khobaib\" ><MODITEM QTY=\"1\" ITEMID=\"90204\" /><MODITEM QTY=\"1\" ITEMID=\"90201\" /><MODITEM QTY=\"1\" ITEMID=\"90302\" /><MODITEM QTY=\"1\" ITEMID=\"91501\" /></ADDITEM></ITEMREQUESTS></ADDCHECK></CHECKREQUESTS>"];
    
  
    
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForPlaceOrderWithStoreId:[self.item.storeId intValue] orderMode:1 order:orderString];
   
    
   //[query setCustomParameter:@"hmHAJvHvKYmilfOqgUnc22tf/RL5GLmPbcFBg02d6wm+ZB1o3f7RKYqmB31+DGoH9Ad3s3WP99n587qDZ5tm+w==" forKey:@"asaan-auth-token"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[@"asaan-auth-token"]=[PFUser currentUser][@"authToken"];
 
    [query setAdditionalHTTPHeaders:dic];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    [storeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreMenuItem *object,NSError *error){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSLog(@"%@",[error userInfo]);
    }];

    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex ==1){
     
        [self order];
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
