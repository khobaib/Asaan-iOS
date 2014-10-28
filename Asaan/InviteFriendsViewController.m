//
//  InviteFriendsViewController.m
//  Asaan
//
//  Created by MC MINI on 9/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import <AddressBook/AddressBook.h>
#import "ResturantListViewController.h"

@interface InviteFriendsViewController ()

@end

@implementation InviteFriendsViewController

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
    
    [self actionBarInit];
    arr=[self getContactsWithEmail];
    
    // Do any additional setup after loading the view.
}

-(void)actionBarInit{
    UIPageControl *pagecontrol=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 50, 37)];
    pagecontrol.numberOfPages=3;
    pagecontrol.currentPageIndicatorTintColor=[UIColor colorWithRed:(187.0/255.0) green:(137.0/255.0) blue:(33.0/255.0) alpha:1.0f];
    pagecontrol.pageIndicatorTintColor=[UIColor whiteColor];
    pagecontrol.userInteractionEnabled=NO;
    pagecontrol.currentPage=2;
   
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"nextSinguppage.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=btn;
    

    
    UIButton *imgbtn=[[UIButton alloc]initWithFrame:CGRectMake(-10, 0, 125, 40)];
    [imgbtn setImage:[UIImage imageNamed:@"asaanTopLogo.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *lbtn=[[UIBarButtonItem alloc]initWithCustomView:imgbtn];
    UIBarButtonItem *mbtn=[[UIBarButtonItem alloc]initWithCustomView:pagecontrol];
    
    [self.navigationItem setLeftBarButtonItems:@[lbtn,mbtn]];
}

-(void)nextPressed:(id)sender{
  
    ResturantListViewController *rlvc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"rabbi101"];
    [self.navigationController pushViewController:rlvc animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return arr.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"inviteFroemdsCell"];

   // UIImageView *imgView=(UIImageView *)[cell viewWithTag:101];
    
    NSMutableDictionary *person=[arr objectAtIndex:indexPath.row];
    UILabel *nameLable=(UILabel *) [cell viewWithTag:102];
    UIImageView *imageView=(UIImageView*)[cell viewWithTag:101];

    nameLable.text=person[@"FirstName"];
    imageView.image=person[@"image"];
    
    return cell;
}

#pragma mark - GetContacts


-(NSArray *)getContactsWithEmail
{
    
    CFErrorRef *error = nil;
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
 
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        
        NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(source);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        
        
        for (id record in allContacts){
            
              ABRecordRef person = (__bridge ABRecordRef)record;   NSMutableDictionary *contacts=[[NSMutableDictionary alloc]init];
            
          
            
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            if(ABMultiValueGetCount(multiEmails)>0){
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, 0);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                
                contacts[@"email"]=contactEmail;
                
                
                
               NSString *fname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                
               NSString *lname =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                
                if (!fname) {
                    contacts[@"FirstName"] = @"";
                }else{
                    contacts[@"FirstName"]=fname;
                }
                if (!lname) {
                    contacts[@"LastName"] = @"";
                }else{
                
                    contacts[@"LastName"]=lname;
                }
                
                // get contacts picture, if pic doesn't exists, show standart one
                
                NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
                UIImage *img = [UIImage imageWithData:imgData];
                if (! img) {
                    contacts[@"image"] = [UIImage imageNamed:@"person_placeholder.png"];
                }else{
                    contacts[@"image"]=img;
                }
                //get Phone Numbers
                
                [items addObject:contacts];
          
            }
      
        }
        return items;
        
    } else {

        return nil;

    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
