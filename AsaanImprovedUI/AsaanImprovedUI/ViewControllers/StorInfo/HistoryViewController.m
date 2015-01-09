//
//  HistoryViewController.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 12/16/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController () <UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *historyListTableView;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoreOrderHistoryCell" forIndexPath:indexPath];
    
    UILabel *txtName=(UILabel *)[cell viewWithTag:101];
    if (indexPath.row == 0) {
        txtName.text = @"NOV 21, 2014";
    }
    else if (indexPath.row == 1) {
        txtName.text = @"NOV 29, 2014";
    }
    else if (indexPath.row == 2) {
        txtName.text = @"DEC 13, 2014";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

@end
