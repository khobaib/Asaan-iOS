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
#import "ProgressHUD.h"

#import "ChatConstants.h"
#import "messages.h"
#import "utilities.h"

#import "GroupView.h"
#import "ChatView.h"

#import "UtilCalls.h"
#import "ChatTabBarController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupView()
{
//	NSMutableArray *chatrooms;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation GroupView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_group"]];
		self.tabBarItem.title = @"Groups";
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
    self.title = @"Groups";
    self.tabBarItem.title = @"Groups";
    
//    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
    
//    [UtilCalls slidingMenuSetupWith:self withItem:self.revealBarButtonItem];
	//---------------------------------------------------------------------------------------------------------------------------------------------
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self
//																			 action:@selector(actionNew)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.chatrooms = [[NSMutableArray alloc] init];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self loadChatRooms];
	}
	else LoginUser(self);
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadChatRooms
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFQuery *query = [PFQuery queryWithClassName:PF_CHATROOMS_CLASS_NAME];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[self.chatrooms removeAllObjects];
			[self.chatrooms addObjectsFromArray:objects];
			[self.tableView reloadData];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionNew
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a name for your group" message:nil delegate:self
										  cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
}

#pragma mark - UIAlertViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != alertView.cancelButtonIndex)
	{
		UITextField *textField = [alertView textFieldAtIndex:0];
		if ([textField.text length] != 0)
		{
			PFObject *object = [PFObject objectWithClassName:PF_CHATROOMS_CLASS_NAME];
			object[PF_CHATROOMS_NAME] = textField.text;
			[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
			{
				if (error == nil)
				{
					[self loadChatRooms];
				}
				else [ProgressHUD showError:@"Network error."];
			}];
		}
	}
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
	return [self.chatrooms count];
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

	PFObject *chatroom = self.chatrooms[indexPath.row];
	cell.textLabel.text = [[chatroom[PF_CHATROOMS_NAME] componentsSeparatedByString:@"$$"] objectAtIndex:0];
	if (cell.detailTextLabel.text == nil) cell.detailTextLabel.text = @" ";
	cell.detailTextLabel.textColor = [UIColor lightGrayColor];

	PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
	[query whereKey:PF_CHAT_ROOMID equalTo:chatroom.objectId];
	[query orderByDescending:PF_CHAT_CREATEDAT];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if ([objects count] != 0)
		{
			PFObject *chat = [objects firstObject];
			NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:chat.createdAt];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d messages (%@)", (int) [objects count], TimeElapsed(seconds)];
		}
		else cell.detailTextLabel.text = @"No message";
	}];

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFObject *chatroom = self.chatrooms[indexPath.row];
	NSString *roomId = chatroom.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CreateMessageItem([PFUser currentUser], roomId, chatroom[PF_CHATROOMS_NAME]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
    if (self.navigationController.parentViewController && [self.navigationController.parentViewController isKindOfClass:ChatTabBarController.class]) {
        
        ChatTabBarController *tabbarController = (ChatTabBarController *)self.navigationController.parentViewController;
        tabbarController.chatView.roomId = roomId;
        
        tabbarController.title = [[chatroom[PF_CHATROOMS_NAME] componentsSeparatedByString:@"$$"] objectAtIndex:0];
        tabbarController.chatView.title = [[chatroom[PF_CHATROOMS_NAME] componentsSeparatedByString:@"$$"] objectAtIndex:0];
        tabbarController.selectedIndex = 1;
    }
    
//	ChatView *chatView = [[ChatView alloc] initWith:roomId title:[[chatroom[PF_CHATROOMS_NAME] componentsSeparatedByString:@"$$"] objectAtIndex:0]];
//	chatView.hidesBottomBarWhenPushed = YES;
//	[self.navigationController pushViewController:chatView animated:YES];
}

@end
