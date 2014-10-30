//
//  StoreOrderHistoryViewController.m
//  Asaan
//
//  Created by MC MINI on 10/30/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "StoreOrderHistoryViewController.h"

@interface StoreOrderHistoryViewController ()

@end

@implementation StoreOrderHistoryViewController

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

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    

    
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"OrderList1" forIndexPath:indexPath];
    
    
        UIView *selectedView = [[UIView alloc]initWithFrame:cell.frame];
        
        selectedView.backgroundColor=[UIColor colorWithRed:(103.0/255.0) green:(103.0/255.0) blue:(103.0/255.0) alpha:1];
        
        UIView *viewTop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 79)];
        
        viewTop.backgroundColor = [UIColor grayColor];
        [selectedView addSubview:viewTop];
        
        cell.selectedBackgroundView =  selectedView;
        
        return cell;
        
    
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
