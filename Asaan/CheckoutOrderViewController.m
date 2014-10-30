//
//  CheckoutOrderViewController.m
//  Asaan
//
//  Created by MC MINI on 10/29/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "CheckoutOrderViewController.h"
#import "Order.h"

@interface CheckoutOrderViewController ()

@end

@implementation CheckoutOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableData=[DatabaseHelper getAllOrders];
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
    UILabel *total=(UILabel *)[cell viewWithTag:405];
    
    
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
    
    

    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    UIStepper *steper=(UIStepper *)sender;
    double value = [steper value];
    
    UILabel *lable=(UILabel *)[cell viewWithTag:804];
    [lable setText:[NSString stringWithFormat:@"%d", (int)value]];
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
