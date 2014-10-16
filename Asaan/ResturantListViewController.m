//
//  ResturantListViewController.m
//  Asaan
//
//  Created by MC MINI on 9/23/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "ResturantListViewController.h"
#define METERS_PER_MILE 1609.344


@interface ResturantListViewController ()

@end

@implementation ResturantListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self goToLocation];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
    resturantList=[[NSMutableArray alloc]init];
    
    [self fetchRestrurant];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
 
}

-(void)fetchRestrurant{
    PFQuery *query = [PFQuery queryWithClassName:@"Store"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            [resturantList addObjectsFromArray:objects];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)goToLocation{
   
    CLLocationCoordinate2D location = [[[self.mapView userLocation] location] coordinate];
    
    NSLog(@"zoom to %f",location.latitude);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 0.6*METERS_PER_MILE, 0.6*METERS_PER_MILE);
    
    [self.mapView setRegion:viewRegion animated:YES];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return resturantList.count;
    
}


- (void)addcellBackground:(UITableViewCell *)cell {
    UIView *selectedView = [[UIView alloc]initWithFrame:cell.frame];
    
    selectedView.backgroundColor=[UIColor colorWithRed:(103.0/255.0) green:(103.0/255.0) blue:(103.0/255.0) alpha:1];
    
    UIView *viewTop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 79)];
    
    viewTop.backgroundColor = [UIColor grayColor];
    [selectedView addSubview:viewTop];
    
    cell.selectedBackgroundView =  selectedView;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"resturantListCell"];

    [self addcellBackground:cell];
    
    
    UILabel *name=(UILabel *)[cell viewWithTag:301];
    UILabel *desctiprionText=(UILabel *)[cell viewWithTag:302];
    
    PFObject *resturant=[resturantList objectAtIndex:indexPath.row];
    
    [self addShadowToText:name withText:resturant[@"name"]];
    [self addShadowToText:desctiprionText withText:resturant[@"cuisineType"]];
    return cell;
}

- (void)addShadowToText:(UILabel *)textView withText:(NSString *)text{
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = NSMakeRange(0, [attString length]);
    
    [attString addAttribute:NSFontAttributeName value:textView.font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:textView.textColor range:range];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor grayColor];
    shadow.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [attString addAttribute:NSShadowAttributeName value:shadow range:range];
    
    textView.attributedText = attString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"log");
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


@end
