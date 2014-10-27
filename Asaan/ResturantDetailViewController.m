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

@implementation ResturantDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)segmentControlInit
{
    self.segment.selectedSegmentIndex=0;
    //UIColor *tintcolor=[UIColor colorWithRed:236.0/255.0 green:186.0/255.0 blue:16.0/255.0 alpha:1.0];
    //[[self.segment.subviews objectAtIndex:1] setTintColor:tintcolor];
    
    self.tableView.hidden=YES;
    self.containerView.hidden=NO;
    /*
    for (int i=0; i<[self.segment.subviews count]; i++)
    {
        if ([[self.segment.subviews objectAtIndex:i]isSelected] )
        {
            UIColor *tintcolor=[UIColor colorWithRed:236.0/255.0 green:186.0/255.0 blue:16.0/255.0 alpha:1.0];
            [[self.segment.subviews objectAtIndex:i] setTintColor:tintcolor];
        }
        else
        {
            [[self.segment.subviews objectAtIndex:i] setTintColor:nil];
        }
    }*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isReview=NO;

    [self segmentControlInit];
    
    [self setValueOnUI];
    

    // Do any additional setup after loading the view.
}


-(void)setValueOnUI{
    self.addressLable.text=self.store.address;
    self.phoneNoLable.text=self.store.phone;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)segmentControl:(id)sender{
    UISegmentedControl *segment=(UISegmentedControl *)sender;
    
    if(segment.selectedSegmentIndex==3){
    
        [self performSegueWithIdentifier:@"menusegu" sender:self];
        
        return;
    }
    
    if(segment.selectedSegmentIndex==0){
        self.tableView.hidden=YES;
        self.containerView.hidden=NO;
    }else{
        self.tableView.hidden=NO;
        self.containerView.hidden=YES;
        
        if(segment.selectedSegmentIndex==1){
            
            isReview=NO;
            [[self tableView]reloadData];
            
        }else if (segment.selectedSegmentIndex==2){
            
            isReview=YES;
            [[self tableView]reloadData];
        }
    }
    /*
   for (int i=0; i<[segment.subviews count]; i++)
    {
        if ([[segment.subviews objectAtIndex:i]isSelected] )
        {
            UIColor *tintcolor=[UIColor colorWithRed:236.0/255.0 green:186.0/255.0 blue:16.0/255.0 alpha:1.0];
            [[segment.subviews objectAtIndex:i] setTintColor:tintcolor];
        }
        else
        {
            [[segment.subviews objectAtIndex:i] setTintColor:nil];
        }
    }*/
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
        
        UIView *viewTop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 79)];
        
        viewTop.backgroundColor = [UIColor grayColor];
        [selectedView addSubview:viewTop];
        
        cell.selectedBackgroundView =  selectedView;
        
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
