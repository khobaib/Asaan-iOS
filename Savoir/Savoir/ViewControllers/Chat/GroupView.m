//
// Copyright (c) 2014 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "GTLStoreendpoint.h"
#import "ProgressHUD.h"

#import "ChatConstants.h"
#import "utilities.h"

#import "GroupView.h"
#import "ChatView.h"

#import "Constants.h"
#import "UtilCalls.h"
#import "UIColor+SavoirBackgroundColor.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupView()
	@property (strong, nonatomic) NSMutableArray *chatRoomsAndMemberships;
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation GroupView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
    self.title = @"Groups";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor asaanBackgroundColor];
    self.tableView.backgroundColor = [UIColor asaanBackgroundColor];
    self.tableView.allowsSelectionDuringEditing = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.chatRoomsAndMemberships = [[NSMutableArray alloc] init];
    if ([PFUser currentUser] != nil)
    {
        [self loadChatRooms];
    }
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadChatRooms
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.chatRoomsAndMemberships removeAllObjects];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointChatRoomsAndStoreChatMemberships *usersRoomsAndStores = appDelegate.globalObjectHolder.usersRoomsAndStores;
    for (GTLStoreendpointStoreChatTeam *member in usersRoomsAndStores.storeChatMemberships)
        [self.chatRoomsAndMemberships addObject:member];

    for (GTLStoreendpointChatRoom *room in usersRoomsAndStores.chatRooms)
        [self.chatRoomsAndMemberships addObject:room];

    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UtilCalls getSlidingMenuBarButtonSetupWith:self];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)showChatRoomForStore:(long)storeId WithName:(NSString *)storeName
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (storeId == 0)
        return;
    
    int row = 0;
    for (id object in self.chatRoomsAndMemberships)
    {
        if ([object isKindOfClass:[GTLStoreendpointChatRoom class]])
        {
            GTLStoreendpointChatRoom *room = object;
            if (room.storeId.longLongValue == storeId)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:
                 UITableViewScrollPositionNone];
                [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                return;
            }
        }
        else if ([object isKindOfClass:[GTLStoreendpointStoreChatTeam class]])
        {
            GTLStoreendpointStoreChatTeam *team = object;
            if (team.storeId.longLongValue == storeId)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:
                 UITableViewScrollPositionNone];
                [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                return;
            }
        }
        row++;
    }
    // Create a new Chat room for this user and store
    GTLStoreendpointChatRoom *newRoom = [[GTLStoreendpointChatRoom alloc]init];
    newRoom.name = storeName;
    newRoom.storeId = [NSNumber numberWithLong:storeId];
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveChatRoomWithObject:newRoom];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatRoom *object,NSError *error)
     {
         if (!error)
         {
             [weakSelf.chatRoomsAndMemberships insertObject:object atIndex:0];
             [weakSelf.tableView reloadData];
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
             
             [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:
              UITableViewScrollPositionNone];
             [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
             return;
         }
         else
             NSLog(@"queryForSaveChatRoomWithObject error:%ld, %@", (long)error.code, error.debugDescription);
     }];
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.notificationUtils.bReceivedChatNotification = false;
}

#pragma mark - Backend actions

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionNew
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a name for your group" message:nil delegate:self
//										  cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//	[alert show];
}

#pragma mark - UIAlertViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//	if (buttonIndex != alertView.cancelButtonIndex)
//	{
//		UITextField *textField = [alertView textFieldAtIndex:0];
//		if ([textField.text length] != 0)
//		{
//			PFObject *object = [PFObject objectWithClassName:PF_CHATROOMS_CLASS_NAME];
//			object[PF_CHATROOMS_NAME] = textField.text;
//			[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//			{
//				if (error == nil)
//				{
//					[self loadChatRooms];
//				}
//				else [ProgressHUD showError:@"Network error."];
//			}];
//		}
//	}
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [self.chatRoomsAndMemberships count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 50;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupChatCell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"GroupChatCell"];
    cell.backgroundColor = [UIColor asaanBackgroundColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    id object = self.chatRoomsAndMemberships[indexPath.row];
    if ([object isKindOfClass:[GTLStoreendpointChatRoom class]])
    {
        GTLStoreendpointChatRoom *room = object;
        cell.textLabel.text = room.name;
    }
    else if ([object isKindOfClass:[GTLStoreendpointStoreChatTeam class]])
    {
        GTLStoreendpointStoreChatTeam *storeChatMember = object;
        cell.textLabel.text = storeChatMember.storeName;
    }

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    long roomOrMembershipId = 0;
    NSString *title;
	//---------------------------------------------------------------------------------------------------------------------------------------------
    id object = self.chatRoomsAndMemberships[indexPath.row];
    Boolean isStore = false;
    if ([object isKindOfClass:[GTLStoreendpointChatRoom class]])
    {
        GTLStoreendpointChatRoom *room = object;
        roomOrMembershipId = room.identifier.longLongValue;
        title = room.name;
    }
    else if ([object isKindOfClass:[GTLStoreendpointStoreChatTeam class]])
    {
        GTLStoreendpointStoreChatTeam *storeChatMember = object;
        roomOrMembershipId = storeChatMember.storeId.longLongValue;
        title = storeChatMember.storeName;
        isStore = true;
    }
    
    ChatView *chatView = [[ChatView alloc] initWith:roomOrMembershipId isStore:isStore];
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];

//	ChatView *chatView = [[ChatView alloc] initWith:roomId title:[[chatroom[PF_CHATROOMS_NAME] componentsSeparatedByString:@"$$"] objectAtIndex:0]];
//	chatView.hidesBottomBarWhenPushed = YES;
//	[self.navigationController pushViewController:chatView animated:YES];
}

@end
