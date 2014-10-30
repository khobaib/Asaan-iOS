//
//  ResturantListViewController.m
//  Asaan
//
//  Created by MC MINI on 9/23/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "ResturantListViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Store.h"
#import "AppDelegate.h"
#import "DatabaseHelper.h"
#import "GTLStoreendpoint.h"
#import "GTMHTTPFetcher.h"
#import "ResturantDetailViewController.h"
#import "DataCommunicator.h"

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
    
     NSDate *saveDate=[[NSUserDefaults standardUserDefaults]objectForKey:@"resturantListUpdateTime"];
    

    
    if(saveDate==nil){
        [self fetchResturantwitGTLquery];
    }else{
        int i = -[saveDate timeIntervalSinceNow]/3600;
        
        NSLog(@"%d",i);

        if(i>24){
            [self fetchResturantwitGTLquery];
            
        }else{
            isServerData=NO;
            resturantList=[[DatabaseHelper getAllStores]mutableCopy];
            
          
            
        }

    }
    
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 50; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    

}

- (void)locationManager:(CLLocationManager *)manager  didUpdateLocations:(NSArray *)locations{
    NSLog(@"%@",[locations lastObject]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
 
}


-(void)fetchResturantwitGTLquery{

    static GTLServiceStoreendpoint *storeService=nil;
    
    if(!storeService){
        storeService=[[GTLServiceStoreendpoint alloc]init];
        storeService.retryEnabled=YES;
      

    }
    
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoresWithFirstPosition:0 maxResult:10];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [storeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreCollection *object,NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if(!error){
            

            resturantList=[object.items mutableCopy];
              isServerData=YES;
            [self.tableView reloadData];
            
            if([DatabaseHelper saveUpdateStores:resturantList]){
                NSDate *currentdate=[NSDate date] ;
                

                
                [[NSUserDefaults standardUserDefaults]setObject:currentdate forKey:@"resturantListUpdateTime"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            

        }else{
            NSLog(@"%@",[error userInfo]);
        }
        
    }];
    
}



-(void)fetchRestrurant{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [manager POST:@"https://asaan-server.appspot.com/_ah/api/storeendpoint/v1/storecollection" parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject){
        
        NSDictionary *dic=(NSDictionary *)responseObject;
        

        
        resturantList=dic[@"items"];
        
        isServerData=YES;
        [self.tableView reloadData];
        
        if([DatabaseHelper saveUpdateStores:resturantList]){
            NSDate *currentdate=[NSDate date] ;
            
            NSLog(@"%@",currentdate);

            [[NSUserDefaults standardUserDefaults]setObject:currentdate forKey:@"resturantListUpdateTime"];
            [[NSUserDefaults standardUserDefaults] synchronize];

        }
        
   
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"%@",[error userInfo]);
        
    }];
    
   
}


-(void)goToLocation{
   
    CLLocationCoordinate2D location = [[[self.mapView userLocation] location] coordinate];
    
    NSLog(@"zoom to %f",location.latitude);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 0.6*METERS_PER_MILE, 0.6*METERS_PER_MILE);
    
    [self.mapView setRegion:viewRegion animated:YES];

}


#pragma mark table datasoource delegat

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    

    return resturantList.count;
    
}




// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"resturantListCell"];

    [self addcellBackground:cell];
    
    
    UILabel *name=(UILabel *)[cell viewWithTag:301];
    UILabel *desctiprionText=(UILabel *)[cell viewWithTag:302];
    
    if(isServerData){
        GTLStoreendpointStore *store=[resturantList objectAtIndex:indexPath.row];
    
        if(store.name!=nil ){
            [self addShadowToText:name withText:store.name];
           
        }
        if (store.descriptionProperty!=nil) {
            
             [self addShadowToText:desctiprionText withText:store.descriptionProperty];
        }

    }else{
        
        Store *store=[resturantList objectAtIndex:indexPath.row];
        
        if(!(store.name==nil)){
            [self addShadowToText:name withText:store.name];
        }
        
        if(store.storeDescription!=nil){
         
            [self addShadowToText:desctiprionText withText:store.storeDescription];

        }

       
    }
    
  
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark -tableUIhelper

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

- (void)addcellBackground:(UITableViewCell *)cell {
    UIView *selectedView = [[UIView alloc]initWithFrame:cell.frame];
    
    selectedView.backgroundColor=[UIColor colorWithRed:(103.0/255.0) green:(103.0/255.0) blue:(103.0/255.0) alpha:1];
    
    UIView *viewTop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 79)];
    
    viewTop.backgroundColor = [UIColor grayColor];
    [selectedView addSubview:viewTop];
    
    cell.selectedBackgroundView =  selectedView;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if([sender isKindOfClass:[UIButton class]]){
        return;
    }
    
  
    
    NSIndexPath *indexPath=[self.tableView indexPathForSelectedRow];
    
    
    [DataCommunicator setSelectedStore:[resturantList objectAtIndex:indexPath.row]];
    

 
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}



@end
