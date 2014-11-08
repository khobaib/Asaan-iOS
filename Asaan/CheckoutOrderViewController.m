//
//  CheckoutOrderViewController.m
//  Asaan
//
//  Created by MC MINI on 10/29/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "CheckoutOrderViewController.h"
#import "Order.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "LoginViewController.h"

@interface CheckoutOrderViewController ()

@end

@implementation CheckoutOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableData=[DatabaseHelper getAllOrders];
    totalSum=[self getTotal];
    
    self.total.text=[NSString stringWithFormat:@"$%.2f",totalSum];
    
}

-(float)getTotal{
    float sum=0.00;
    
    for(int i=0;i<tableData.count;i++){
        Order *order=[tableData objectAtIndex:i];
        sum+=[order.quantity intValue]*[order.price floatValue]/100;
    }
    
    return sum;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return tableData.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"orderListCell" forIndexPath:indexPath];
    
    
    Order *order=[tableData objectAtIndex:indexPath.row];
    
 
    NSLog( @"%@ %@ %@",order.note,order.quantity,order.price);
    
    UILabel *name=(UILabel *)[cell viewWithTag:801];
    UILabel *sDiscription=(UILabel *)[cell viewWithTag:802];
    UILabel *price=(UILabel *)[cell viewWithTag:803];
    UILabel *quantity=(UILabel *)[cell viewWithTag:804];
    UILabel *total=(UILabel *)[cell viewWithTag:805];
    
 
    UIStepper *steper=(UIStepper *)[cell viewWithTag:806];
    steper.value=[order.quantity intValue];
    
    name.text=order.shortDescriptionProperty;
    sDiscription.text=order.note;
    price.text=[NSString stringWithFormat:@"$%.2f",[order .price floatValue]/100.00];
    quantity.text=[NSString stringWithFormat:@"%d",[order.quantity intValue]];
    
    float totalmoney=[order.quantity floatValue]*[order.price floatValue]/100.00;
    total.text=[NSString stringWithFormat:@"$%.2f",totalmoney];
    
    return cell;
}



-(IBAction)steperAction:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    Order *order=[tableData objectAtIndex:indexPath.row];

    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    UIStepper *steper=(UIStepper *)sender;
    double value = [steper value];
    
    UILabel *lable=(UILabel *)[cell viewWithTag:804];
    
    UILabel *total=(UILabel *)[cell viewWithTag:805];
    
    total.text=[NSString stringWithFormat:@"$%.2f",value*[order.price floatValue]/100];
    
    [lable setText:[NSString stringWithFormat:@"%d", (int)value]];
    if([order.quantity floatValue]>value){
        order.quantity=[NSNumber numberWithInt:[order.quantity intValue]-1];
        totalSum-=[order.price floatValue]/100;
    }else{
     
        order.quantity=[NSNumber numberWithInt:[order.quantity intValue]+1];
        totalSum+=[order.price floatValue]/100;

    }
    
    self.total.text=[NSString stringWithFormat:@"$%.2f",totalSum];

    
}

-(IBAction)order:(id)sender{
    static GTLServiceStoreendpoint *storeService=nil;
    
    if([PFUser currentUser]==nil){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Asaan" message:@"To place order you have to login first." delegate:nil cancelButtonTitle:@"Cancle" otherButtonTitles: nil];
        [alert show];

        LoginViewController *loginview=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"login"];
        
        [self.navigationController pushViewController:loginview animated:YES];
        
        
        return;
    }
    
    if(!storeService){
        storeService=[[GTLServiceStoreendpoint alloc]init];
        storeService.retryEnabled=YES;
    }
    
    NSString *str = @"<ITEMREQUESTS>";
    for(int i=0;i<tableData.count;i++){
        Order *order=[tableData objectAtIndex:i];
        NSString *itemString=[NSString stringWithFormat:@"<ADDITEM QTY=\"%@\" ITEMID=\"%@\" FOR=\"%@\" />",order.quantity,order.menuItemPOSId,order.username];
        
        str=[str stringByAppendingString:itemString];
    }
    
    str=[str stringByAppendingString:@"</ITEMREQUESTS>"];
    
    NSString *deliveryString=[NSString stringWithFormat:@"<DELIVERY DELIVERYACCT=\"123ABC\" DELIVERYNOTE=\"BEWARE OF DOG\" ADDRESS1=\"123 Main street\" ADDRESS2=\"APT 123\" ADDRESS3=\"Back Door\" CITY=\"DENVER\" STATE=\"CO\" POSTALCODE=\"12345\" CROSSSTREET=\"MAIN AND 1st\" />"];
    
    NSString *contactString=[NSString stringWithFormat:@"<CONTACT FIRSTNAME=\"JOHN\" LASTNAME=\"SMITH\" PHONE1=\"303-123-4567\" PHONE2=\"8012345678\" COMPANY=\"TEST CO\" DEPT=\"DEPT 123\" />"];
    
    NSString *orderString=[NSString stringWithFormat:@"<CHECKREQUESTS><ADDCHECK EXTCHECKID=\"PARA\" READYTIME=\"\" NOTE=\"\" ORDERMODE=\"@ORDER_MODE\">%@%@%@</ADDCHECK></CHECKREQUESTS>",contactString,deliveryString,str];
    
    
    NSLog(@"%@",orderString);
    
    
    Order *order=[tableData objectAtIndex:0];
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForPlaceOrderWithStoreId:[order.storeId intValue] orderMode:1 order:orderString];
    
    
    //[query setCustomParameter:@"hmHAJvHvKYmilfOqgUnc22tf/RL5GLmPbcFBg02d6wm+ZB1o3f7RKYqmB31+DGoH9Ad3s3WP99n587qDZ5tm+w==" forKey:@"asaan-auth-token"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[@"asaan-auth-token"]=[PFUser currentUser][@"authToken"];
    
    [query setAdditionalHTTPHeaders:dic];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    
    [storeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreMenuItem *object,NSError *error){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSLog(@"%@",object);
        if(error==nil){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Asaan" message:@"Your order place is successfull." delegate:nil cancelButtonTitle:@"Cancle" otherButtonTitles: nil];
            [alert show];
            [DatabaseHelper deletAllObjectsfromEntity:@"Order"];
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Asaan" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"Cancle" otherButtonTitles: nil];
            [alert show];
        }
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

@end
