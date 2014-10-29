//
//  CheckoutOrderViewController.m
//  Asaan
//
//  Created by MC MINI on 10/29/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "CheckoutOrderViewController.h"

@interface CheckoutOrderViewController ()

@end

@implementation CheckoutOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 5;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"orderListCell" forIndexPath:indexPath];
    
    return cell;
}



-(IBAction)steperAction:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    

    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    UIStepper *steper=(UIStepper *)sender;
    double value = [steper value];
    
    UILabel *lable=(UILabel *)[cell viewWithTag:501];
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
