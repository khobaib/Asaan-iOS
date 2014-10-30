//
//  ResturantDetailViewController.m
//  Asaan
//
//  Created by MC MINI on 9/23/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "ResturantDetailViewController.h"
#import "MenuViewController.h"
#import "RateView.h"
@interface ResturantDetailViewController ()

@end

#define METERS_PER_MILE 1609.344
@implementation ResturantDetailViewController

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
    


    id str=[DataCommunicator getSelectedStore];

    self.store=[Store gtlStoreFromID:str];
    

    
    [self setValueOnUI];
    

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

}

-(void)setValueOnUI{
    self.addressLable.text=self.store.address;
    self.phoneNoLable.text=self.store.phone;
    [self goTolocation];
}

-(void)goTolocation{
 
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [self.store.lat floatValue];
    zoomLocation.longitude= [self.store.lng floatValue];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.75*METERS_PER_MILE, 0.75*METERS_PER_MILE);
    
    [self.mapView setRegion:viewRegion animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(isReview){
         UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ReviewList"];
        UIView *selectedView = [[UIView alloc]initWithFrame:cell.frame];
        
        selectedView.backgroundColor=[UIColor colorWithRed:(103.0/255.0) green:(103.0/255.0) blue:(103.0/255.0) alpha:1];
        
        UIView *viewTop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 74)];
        
        viewTop.backgroundColor = [UIColor grayColor];
        [selectedView addSubview:viewTop];
        
        cell.selectedBackgroundView =  selectedView;
        
        
        RateView *rate=(RateView *)[cell viewWithTag:405];
        [self rateview:rate rating:4];
        
        
        return cell;
        
    }else{
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"OrderList"];
        UIView *selectedView = [[UIView alloc]initWithFrame:cell.frame];
        
        selectedView.backgroundColor=[UIColor colorWithRed:(103.0/255.0) green:(103.0/255.0) blue:(103.0/255.0) alpha:1];
        
        UIView *viewTop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 79)];
        
        viewTop.backgroundColor = [UIColor grayColor];
        [selectedView addSubview:viewTop];
        
        cell.selectedBackgroundView =  selectedView;
        
        return cell;

    }
    
   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)rateview:(RateView *)starRater rating:(float)rating{
    starRater.fullSelectedImage=[UIImage imageNamed:@"starhighlighted.png"];
    starRater.notSelectedImage=[UIImage imageNamed:@"star.png"];
    starRater.maxRating=5;
    starRater.rating=rating;
    starRater.editable=NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
  

    MenuViewController *mvc=[segue destinationViewController];
    mvc.store=self.store;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


@end
