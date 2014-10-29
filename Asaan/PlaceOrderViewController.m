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
    
    
    [DatabaseHelper saveOrder:self.item quantityStr:self.quantity.text noteStr:self.specialPropertyLabel.text];

    
}


-(void)other{
    static GTLServiceStoreendpoint *storeService=nil;
    
    if(!storeService){
        storeService=[[GTLServiceStoreendpoint alloc]init];
        storeService.retryEnabled=YES;
    }
    
    NSString *orderString=[NSString stringWithFormat:@"<CHECKREQUESTS> <ADDCHECK TABLENUMBER=\"TableNumber\" EXTCHECKID=\"Asaan\" READYTIME=\"18:45\" READYDATETIME=\"\" NOTE=\"Need Extra Spicy\" ORDERMODEFEE=\"\" ORDERID=\"\" PRICEONLY=\"\" ORDERMODE=\"Delivery\"> <ITEMREQUESTS>                           <ADDITEM QTY=\"1\" ITEMID=\"7007\" FOR=\"Khobaib\" >  <MODITEM ITEMID=\"90204\" /> </ADDITEM> </ITEMREQUESTS> </ADDCHECK>                           <PAYMENTREQUESTS> DDTENDER TENDERID=\"AsaanTenderId\" AMOUNT=\"10.00\" TIP=\"1.50\" TOKEN=\"hadkahahoaasdasjdhaod\" />                           </PAYMENTREQUESTS>  </CHECKREQUESTS>"];
    
    // NSLog(@"%@",orderString);
    
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForPlaceOrderWithStoreId:[self.item.storeId intValue]  order:orderString];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [storeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreMenuItem *object,NSError *error){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSLog(@"%@",[error userInfo]);
    }];

    

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
