//
//  MenuViewController.m
//  Asaan
//
//  Created by MC MINI on 10/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "MenuViewController.h"
#import "MBProgressHUD.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.menuData=[[NSMutableArray alloc]init];
    self.menuPage=[[NSMutableArray alloc]init];
    
    self.menuData=[@[@"Pen",@"Book",@"hand",@"food",@"pot",@"joint",@"mobile",@"latitude",@"uhaha",@"meu meu",@"meu"] mutableCopy];
    
    self.horizontalScroller.contentSize=CGSizeMake(120*self.menuData.count, self.horizontalScroller.frame.size.height);
    
    for(int i=0;i<self.menuData.count;i++){
        [self.menuPage addObject:[NSNull null]];
    }
    
    [self loadVisibleMenu];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages that are now on screen
    
    [self loadVisibleMenu];
}

- (void)loadMenu:(NSInteger)page {
    if (page < 0 || page >= self.menuData.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // 1
    UIView *pageView = [self.menuPage objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        // 2
        CGRect frame =CGRectMake(120*page, 0.0, 120, 140);
        
        
        
        
        
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(4, 4, 100, 40)];
        lable.text=@"new";//[self.menuData objectAtIndex:page];
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
        [self.menuData replaceObjectAtIndex:page withObject:view];
    }
}


-(void)similarProductTap:(id)sender{
    
    UITapGestureRecognizer *tap=(UITapGestureRecognizer *)sender;
    
    UIView *view=tap.view;

    view.backgroundColor=[UIColor whiteColor];
    
    
    
}

- (void)purgeMenu:(NSInteger)page {
    if (page < 0 || page >= self.menuData.count) {
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
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        //[self purgeSimilarProduct:i];
    }
    
    // Load pages in our range
    for (NSInteger i=0; i<=self.menuData.count; i++) {
        [self loadMenu:i];
    }
    
    // Purge anything after the last page
    for (NSInteger i=lastPage+1; i<self.menuPage.count; i++) {
        //[self purgeSimilarProduct:i];
    }
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

@end
