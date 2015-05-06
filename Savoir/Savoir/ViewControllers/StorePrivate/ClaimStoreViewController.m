//
//  ClaimStoreViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/10/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ClaimStoreViewController.h"
#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "PhoneSearchViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "InlineCalls.h"
#import "Extension.h"
#import "UIAlertView+Blocks.h"
#import "UIView+Toast.h"

@interface ClaimStoreViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (strong, nonatomic) NSMutableArray *allUsers;

@end

@implementation ClaimStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.allUsers = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnSave:(id)sender
{
    if (self.allUsers.count == 0)
    {
        [self.view makeToast:@"Cannot save an empty employee list."];
        return;
    }
    GTLStoreendpointStoreChatMemberArray *memberArray = [[GTLStoreendpointStoreChatMemberArray alloc]init];
    
    NSMutableArray *allTeamMembers = [[NSMutableArray alloc]init];
    for (GTLStoreendpointChatUser *chatUser in self.allUsers)
    {
        GTLStoreendpointStoreChatTeam *teamMember = [[GTLStoreendpointStoreChatTeam alloc]init];
        teamMember.storeId = self.selectedStore.identifier;
        teamMember.storeName = self.selectedStore.name;
        teamMember.userId = chatUser.userId;
        [allTeamMembers addObject:teamMember];
    }
    memberArray.storeChatMembers = allTeamMembers;
    
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForReplaceStoreChatGroupWithObject:memberArray];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
     {
         if (error)
         {
             NSString *str = @"Something went wrong - your employees could not be saved. We are really sorry. Please try again. If this failure persists please contact Savoir Customer Support.";
             [UtilCalls handleGAEServerError:error Message:str Title:@"Savoir Error" Silent:false];
         }
         else
         {
             NSString *str = @"Your employees have been saved. If this is your first time, Welcome! An Savoir representative will contact you shortly to verify your request and assist you with onboarding.";
             [UIAlertView showWithTitle:@"Thank you" message:str cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
              {
                  [weakSelf performSegueWithIdentifier:@"segueunwindClaimStoreToStoreList" sender:weakSelf];
              }];
         }
     }];

}

- (IBAction)btnEditTable:(id)sender
{
    if (self.btnEdit.tag == 0) // start editing
    {
        [self setEditing:YES animated:YES];
        self.btnEdit.title = @"Done";
        self.btnEdit.tag = 1;
        self.btnAdd.enabled = NO;
    }
    else
    {
        [self setEditing:NO animated:YES];
        self.btnEdit.title = @"Edit";
        self.btnEdit.tag = 0;
        self.btnAdd.enabled = YES;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

- (void) setChatUser:(GTLUserendpointChatUser *)currentuser
{
    if (currentuser)
    {
        for (GTLStoreendpointChatUser *chatUser in self.allUsers)
            if ([chatUser.phone isEqualToString:currentuser.phone])
                return;
        GTLStoreendpointChatUser *chatUser = [[GTLStoreendpointChatUser alloc]init];
        chatUser.name = currentuser.name;
        chatUser.phone = currentuser.phone;
        chatUser.profilePhotoUrl = currentuser.profilePhotoUrl;
        chatUser.userId = currentuser.userId;
        chatUser.objectId = currentuser.objectId;

        [self.allUsers addObject:chatUser];
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark  === UITableViewDataSource ===
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Display a message when the table is empty
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.allUsers.count == 0)
    {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No employees have been added yet.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return self.allUsers.count;
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    if (self.selectedStore != nil)
        [UtilCalls setupHeaderView:headerCell WithTitle:self.selectedStore.name AndSubTitle:@"Add Employees for Chat and Waitlist Management."];
    return headerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"ChatUserCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imgProfilePhoto = (UIImageView *)[cell viewWithTag:501];
    UILabel *txtName = (UILabel *)[cell viewWithTag:502];
    UILabel *txtPhone = (UILabel *)[cell viewWithTag:503];

    // NOTE: Rounded rect
    imgProfilePhoto.layer.cornerRadius = 10.0f;
    imgProfilePhoto.clipsToBounds = YES;
//    imgProfilePhoto.layer.borderWidth = 1.0f;
//    imgProfilePhoto.layer.borderColor = [UIColor grayColor].CGColor;
    
    GTLStoreendpointChatUser *chatUser = [self.allUsers objectAtIndex:indexPath.row];
    
    if (IsEmpty(chatUser.profilePhotoUrl) == false && ![chatUser.profilePhotoUrl isEqualToString:@"undefined"])
    {
        //        [cell.itemPFImageView sd_setImageWithURL:[NSURL URLWithString:menuItemAndStats.menuItem.thumbnailUrl]];
        [imgProfilePhoto setImageWithURL:[NSURL URLWithString:chatUser.profilePhotoUrl ]
                           placeholderImage:[UIImage imageWithColor:RGBA(0.0, 0.0, 0.0, 0.5)]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      if (error) {
                                          NSLog(@"ERROR : %@", error);
                                      }
                                  }
                usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    else {
        imgProfilePhoto.image = [UIImage imageNamed:@"no_image"];
    }
    
    txtName.text = chatUser.name;
    txtPhone.text = chatUser.phone;
    
    return cell;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.allUsers removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueClaimStoreToSearchByPhone"])
    {
        PhoneSearchViewController *controller = [segue destinationViewController];
        controller.receiver = self;
    }
}

@end
