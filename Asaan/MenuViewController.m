//
//  MenuViewController.m
//  Asaan
//
//  Created by MC MINI on 10/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "MenuViewController.h"
#import "MBProgressHUD.h"
#import "MenuSectionHolder.h"
#import "PlaceOrderViewController.h"
#import "DataCommunicator.h"
#import "Store.h"
@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    menuLevel0Array=[[NSMutableArray alloc]init];
    menuPage=[[NSMutableArray alloc]init];
    headerArray=[[NSMutableArray alloc]init];
    tableDataArray=[[NSMutableArray alloc]init];
    
    id str=[DataCommunicator getSelectedStore];
    
    self.store=[Store gtlStoreFromID:str];
    
    [self fetchMenu];
  //  self.menuArray=[@[@"Pen",@"Book",@"hand",@"food",@"pot",@"joint",@"mobile",@"latitude",@"uhaha",@"meu meu",@"meu"] mutableCopy];
    
 }



-(void)fetchMenu{
    
    static GTLServiceStoreendpoint *storeService=nil;
    
    if(!storeService){
        storeService=[[GTLServiceStoreendpoint alloc]init];
        storeService.retryEnabled=YES;
        
        
    }

    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreMenuHierarchyAndItemsWithStoreId:[self.store.identifier intValue] menuType:0 maxResult:50];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [storeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointMenusAndMenuItems *object,NSError *error){
       
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if(error==nil){
            
            menuHierarchyCollectionObject=object;

            
            for (int i=0; i<object.menusAndSubmenus.count; i++) {
                GTLStoreendpointStoreMenuHierarchy *menu=[object.menusAndSubmenus objectAtIndex:i];
                
                if([menu.level intValue]==0){

                    [menuLevel0Array addObject:menu];
                }
            }
            
            [self setMenuWidth];
           
            
            for(int i=0;i<menuLevel0Array.count;i++){
                [menuPage addObject:[NSNull null]];
            }
             GTLStoreendpointStoreMenuHierarchy *menu=[object.menusAndSubmenus objectAtIndex:0];
            
            menuPosID=menu.menuPOSId;
            
            [self loadVisibleMenu];
            
            [self changeDatasetForMenu];

        }else{
            NSLog(@"%@",[error userInfo]);
        }
        
    }];
    
    
    
    
   
}


-(void)setMenuWidth{
    
    CGFloat screenWidth=[UIScreen mainScreen].bounds.size.width;
    
     CGFloat temp=screenWidth/menuLevel0Array.count;
    if(temp<120.0){
        menuWidth=120;
    }else{
        menuWidth=temp;
    }
    

    
     self.horizontalScroller.contentSize=CGSizeMake(menuWidth*menuLevel0Array.count, self.horizontalScroller.frame.size.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages that are now on screen
    
    [self loadVisibleMenu];
}

- (void)loadMenu:(NSInteger)page {
    if (page < 0 || page >=menuLevel0Array.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // 1
    UIView *pageView = [menuPage objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
      
        GTLStoreendpointStoreMenuHierarchy *menu =[menuLevel0Array objectAtIndex:page];
        pageView=[[UIView alloc]initWithFrame:CGRectMake(menuWidth*page, 0, menuWidth, 50)];
        
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(4, 4, menuWidth-10, 40)];
        lable.text=menu.name;
        lable.numberOfLines=2;
        [lable setFont:[UIFont systemFontOfSize:12]];
        lable.textAlignment=NSTextAlignmentCenter;
        // lable.textColor=[UIColor whiteColor];
        lable.backgroundColor=[UIColor whiteColor];
        
        
        
        //[view setBackgroundColor:[TextStyling appColor]];
       
        [pageView addSubview:lable];
    
        pageView.backgroundColor=[UIColor grayColor];
        
        pageView.tag=page;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(similarProductTap:)];
        singleTap.numberOfTapsRequired = 1;
        
        [pageView addGestureRecognizer:singleTap];
        [self.horizontalScroller addSubview:pageView];
        // 4
        [menuPage replaceObjectAtIndex:page withObject:pageView];
    }else{
        
    }
}


-(void)similarProductTap:(id)sender{
    
    UITapGestureRecognizer *tap=(UITapGestureRecognizer *)sender;
    
    UIView *view=tap.view;

    view.backgroundColor=[UIColor whiteColor];
    
    
    
}

- (void)purgeMenu:(NSInteger)page {
    if (page < 0 || page >= menuLevel0Array.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [menuPage objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [menuPage replaceObjectAtIndex:page withObject:[NSNull null]];
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
    for (NSInteger i=0; i<=menuPage.count; i++) {
        [self loadMenu:i];
    }
    
    // Purge anything after the last page
    for (NSInteger i=lastPage+1; i<menuPage.count; i++) {
        //[self purgeMenu:i];
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -uitableview delegate function


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MenuSectionHolder *section=[headerArray objectAtIndex:indexPath.section];
    GTLStoreendpointStoreMenuItem *item=[section.items objectAtIndex:indexPath.row];
    
    PlaceOrderViewController *povc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"orderview"];
    
    
    povc.item=item;
    
    [self.navigationController pushViewController:povc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return headerArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    MenuSectionHolder *sectionOb=[headerArray objectAtIndex:section];
    return sectionOb.items.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
      MenuSectionHolder *holder=[headerArray objectAtIndex:indexPath.section];
    
     GTLStoreendpointStoreMenuItem *item=[holder.items objectAtIndex:indexPath.row];
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"menu" forIndexPath:indexPath];
    
    UILabel *name=(UILabel *)[cell viewWithTag:201];
    UILabel *price=(UILabel *)[cell viewWithTag:203];
    UILabel *longdescription=(UILabel *)[cell viewWithTag:202];
    
    name.text=item.shortDescription;
    longdescription.text=item.longDescription;
    price.text=[NSString stringWithFormat:@"$%.2f",item.price.floatValue/100];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    view=[[UIView alloc]initWithFrame:CGRectMake(5, 5, 150, 30)];
    view.backgroundColor=[UIColor redColor];
    
    UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    
    MenuSectionHolder *holder=[headerArray objectAtIndex:section];
    
    lable.text=holder.headerMenu.shortDescription;
    
    [view addSubview:lable];
    
    return view;
}



#pragma mark -Init array for ui data

-(void)removeDataFromArray{
    [menuLevel0Array removeAllObjects];
    [menuPage removeAllObjects];
    [tableDataArray removeAllObjects];
    [headerArray removeAllObjects];
}


-(void)changeDatasetForMenu{
    [self removeDataFromArray];
    
    NSArray *array = menuHierarchyCollectionObject.menuItems;
    for(int i=0;i<array.count;i++){
        
        GTLStoreendpointStoreMenuItem *item=[array objectAtIndex:i];
        
        if([item.level intValue]==1 && item.menuPOSId==menuPosID){
            MenuSectionHolder *section=[[MenuSectionHolder alloc]init];
            section.headerMenu=item;
            
            for(int j=0;j<array.count;j++){
                 GTLStoreendpointStoreMenuItem *item2=[array objectAtIndex:j];
                
                
                if([item2.subMenuPOSId intValue]==[item.subMenuPOSId intValue] && [item2.level intValue]==2){
                    [section.items addObject:item2];
                }
                
            }
            [headerArray addObject:section];
        }
    }
    
    
    [self.tableView reloadData];
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
