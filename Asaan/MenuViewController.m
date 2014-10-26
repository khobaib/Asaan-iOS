//
//  MenuViewController.m
//  Asaan
//
//  Created by MC MINI on 10/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "MenuViewController.h"
#import "MBProgressHUD.h"
#import "GTLStoreendpoint.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.menuArray=[[NSMutableArray alloc]init];
    self.menuPage=[[NSMutableArray alloc]init];
    
    [self fetchMenu];
  //  self.menuArray=[@[@"Pen",@"Book",@"hand",@"food",@"pot",@"joint",@"mobile",@"latitude",@"uhaha",@"meu meu",@"meu"] mutableCopy];
    
 }



-(void)fetchMenu{
    
    static GTLServiceStoreendpoint *storeService=nil;
    
    if(!storeService){
        storeService=[[GTLServiceStoreendpoint alloc]init];
        storeService.retryEnabled=YES;
        
        
    }

    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreMenuItemsWithStoreId:1 firstPosition:0 maxResult:10];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [storeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreMenuItemCollection *object,NSError *error){
       
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if(error==nil){
            

            
            self.menuArray=[object.items mutableCopy];
            
            self.horizontalScroller.contentSize=CGSizeMake(120*self.menuArray.count, self.horizontalScroller.frame.size.height);
            
            for(int i=0;i<self.menuArray.count;i++){
                [self.menuPage addObject:[NSNull null]];
            }
            
            [self loadVisibleMenu];

        }else{
            NSLog(@"%@",[error userInfo]);
        }
        
    }];
    
    
    
    
   
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages that are now on screen
    
    [self loadVisibleMenu];
}

- (void)loadMenu:(NSInteger)page {
    if (page < 0 || page >= self.menuArray.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // 1
    UIView *pageView = [self.menuPage objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        // 2
        CGRect frame =CGRectMake(120*page, 0.0, 120, 140);
        
        
        
        GTLStoreendpointStoreMenuItem *menu =[self.menuArray objectAtIndex:page];
        
        
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(4, 4, 100, 40)];
        lable.text=menu.menuName;
        lable.numberOfLines=2;
        [lable setFont:[UIFont systemFontOfSize:12]];
        lable.textAlignment=NSTextAlignmentCenter;
        // lable.textColor=[UIColor whiteColor];
        lable.backgroundColor=[UIColor whiteColor];
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(frame.origin.x+5, frame.origin.y+5, frame.size.width-10, frame.size.height-10)];
        //  UIColor *color= [UIColor colorWithRed:(78.0/255.0)  green:(46.0/255.0) blue:(40.0/255.0) alpha:1.0f];
        
        
        
        //[view setBackgroundColor:[TextStyling appColor]];
       
        [view addSubview:lable];
        
        view.tag=page;
        view.backgroundColor=[UIColor grayColor];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(similarProductTap:)];
        singleTap.numberOfTapsRequired = 1;
        
        [view addGestureRecognizer:singleTap];
        [self.horizontalScroller addSubview:view];
        // 4
        [self.menuPage replaceObjectAtIndex:page withObject:view];
    }else{
        
    }
}


-(void)similarProductTap:(id)sender{
    
    UITapGestureRecognizer *tap=(UITapGestureRecognizer *)sender;
    
    UIView *view=tap.view;

    view.backgroundColor=[UIColor whiteColor];
    
    
    
}

- (void)purgeMenu:(NSInteger)page {
    if (page < 0 || page >= self.menuArray.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.menuPage objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.menuPage replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)loadVisibleMenu {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.horizontalScroller.frame.size.width;
    NSInteger page = (NSInteger)floor((self.horizontalScroller.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    
    // Work out which pages you want to load
    NSInteger firstPage = page - 5;
    NSInteger lastPage = page + 5;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
       // [self purgeMenu:i];
    }
    
    // Load pages in our range
    for (NSInteger i=0; i<=self.menuPage.count; i++) {
        [self loadMenu:i];
    }
    
    // Purge anything after the last page
    for (NSInteger i=lastPage+1; i<self.menuPage.count; i++) {
        //[self purgeMenu:i];
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -uitableview delegate function


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    return 5;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"menu" forIndexPath:indexPath];
    
    UILabel *lable=(UILabel *)[cell viewWithTag:201];
    
    lable.text=@"hehe";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
}// Default is 1 if not implemented

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    view=[[UIView alloc]initWithFrame:CGRectMake(5, 5, 150, 30)];
    view.backgroundColor=[UIColor redColor];
    
    UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    lable.text=@"Amar Soup";
    
    [view addSubview:lable];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section    // fixed font style. use custom view (UILabel) if {
{
    return @"Soup";
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
