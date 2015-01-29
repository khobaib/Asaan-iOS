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
#import "camera.h"
#import "pushnotification.h"

#import "ChatView.h"
#import "SDWebImageManager.h"
#import "Constants.h"
#import "UtilCalls.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
//	NSTimer *timer;
	BOOL isLoading;

	NSMutableArray *users;
	NSMutableArray *messages;
    NSMutableArray *serverMessages;
	NSMutableDictionary *avatars;

	JSQMessagesBubbleImage *bubbleImageOutgoing;
	JSQMessagesBubbleImage *bubbleImageIncoming;

	JSQMessagesAvatarImage *avatarImageBlank;
    GTLStoreendpointChatMessagesAndUsers *messagesAndUsers;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatView

// Added by bdpothik
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_messages"]];
//        self.tabBarItem.title = @"Group";
    }
    return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(long)Id_ title:(NSString *)title_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
    self.roomOrMembershipId = Id_;
//    self.title = title_;//@"Chat";
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
//    self.title = @"Groups";

	PFUser *user = [PFUser currentUser];
	self.senderId = user.objectId;
    self.senderDisplayName = [NSString stringWithFormat:@"%@ %@",user[PF_USER_FIRSTNAME], user[PF_USER_LASTNAME]];

	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

	avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:30.0];
}

- (void)setRoomOrStoreChatMembershipId:(long)roomOrStoreChatMemberId isStore:(Boolean)isStore
{
    NSLog(@"hh");
    if (roomOrStoreChatMemberId != self.roomOrMembershipId)
    {
        self.roomOrMembershipId = roomOrStoreChatMemberId;
        self.isStore = isStore;
        NSLog(@"hhg");
        
        users = [[NSMutableArray alloc] init];
        messages = [[NSMutableArray alloc] init];
        serverMessages = [[NSMutableArray alloc] init];
        avatars = [[NSMutableDictionary alloc] init];
        
        [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
        [self.collectionView reloadData];
        
        isLoading = NO;
        [self loadMessages];
        
        if (isStore == true)
            self.inputToolbar.hidden = true;
        else
            self.inputToolbar.hidden = false;
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
    self.tabBarItem.title = @"Message";
	self.collectionView.collectionViewLayout.springinessEnabled = YES;
//	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
//	[timer invalidate];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (isLoading == NO)
    {
        isLoading = YES;
		JSQMessage *message_last = [messages lastObject];
        
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetChatMessagesForStoreOrRoomWithRoomOrStoreId:weakSelf.roomOrMembershipId modifiedDate:message_last.date.timeIntervalSince1970 isStore:weakSelf.isStore firstPosition:0 maxResult:50];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
        [query setAdditionalHTTPHeaders:dic];
       
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatMessagesAndUsers *object,NSError *error)
         {
             if (!error)
             {
                self.automaticallyScrollsToMostRecentMessage = NO;
                 
                messagesAndUsers = object;
                for (GTLStoreendpointChatMessage *message in [object.chatMessages reverseObjectEnumerator])
                    [self addMessage:message];
                if ([object.chatMessages count] != 0)
                {
                    [self finishReceivingMessage];
                    [self scrollToBottomAnimated:NO];
                }
                self.automaticallyScrollsToMostRecentMessage = YES;
             }
             else
             {
                 NSLog(@"queryForGetChatRoomsAndMembershipsForUser error:%ld, %@", error.code, error.debugDescription);
                 [ProgressHUD showError:@"Network error."];
             }
             isLoading = NO;
         }];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addMessage:(GTLStoreendpointChatMessage *)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
    GTLStoreendpointChatUser *chatUser;
    for (GTLStoreendpointChatUser *user in messagesAndUsers.chatUsers)
        if (object.userId.longValue == user.userId.longValue)
        {
            chatUser = user;
            [users addObject:user];
            break;
        }
    [serverMessages addObject:object];
	if (object.fileMessage == nil)
	{
		JSQMessage *message = [[JSQMessage alloc] initWithSenderId:chatUser.objectId senderDisplayName:chatUser.name
																	  date:[NSDate dateWithTimeIntervalSince1970:object.createdDate.longValue] text:object.txtMessage];
		[messages addObject:message];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (object.fileMessage != nil)
	{
		JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
		mediaItem.appliesMediaViewMaskAsOutgoing = [chatUser.objectId isEqualToString:self.senderId];
		JSQMessage *message =
			[[JSQMessage alloc] initWithSenderId:chatUser.objectId senderDisplayName:chatUser.name date:[NSDate dateWithTimeIntervalSince1970:object.createdDate.longValue] media:mediaItem];
		[messages addObject:message];
		//-----------------------------------------------------------------------------------------------------------------------------------------
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:object.fileMessage] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize)
        {
            // progress tracking code
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
        {
            if (error == nil)
            {
                mediaItem.image = image;
                [self.collectionView reloadData];
            }
        }];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSString *)text Picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFFile *filePicture = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (picture != nil)
	{
		filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
		[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error != nil) [ProgressHUD showError:@"Picture save error."];
		}];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
    GTLStoreendpointChatMessage *newMessage = [[GTLStoreendpointChatMessage alloc]init];
    
    if (self.isStore == false)
        newMessage.roomId = [NSNumber numberWithLong:self.roomOrMembershipId];
    
    newMessage.txtMessage = text;
    newMessage.fileMessage = filePicture.url;

    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveChatMessageWithObject:newMessage];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatMessage *object,NSError *error)
     {
         if (error == nil)
         {
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             [weakSelf loadMessages];
         }
         else
         {
             NSLog(@"queryForSaveChatMessageWithObject error:%ld, %@", error.code, error.debugDescription);
             [ProgressHUD showError:@"Network error."];
         }
     }];

    //---------------------------------------------------------------------------------------------------------------------------------------------
	SendPushNotification(self.roomOrMembershipId, text);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self finishSendingMessage];
}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self sendMessage:text Picture:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressAccessoryButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
											   otherButtonTitles:@"Take photo", @"Choose existing photo", nil];
	[action showInView:self.view];
}

#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return messages[indexPath.item];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
			 messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return bubbleImageOutgoing;
	}
	return bubbleImageIncoming;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
					avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	GTLStoreendpointChatUser *user = users[indexPath.item];
	if (avatars[user.objectId] == nil)
	{
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:user.profilePhotoUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progress tracking code
         } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (error == nil)
             {
                 avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:30.0];
                 [self.collectionView reloadData];
             }
         }];
		return avatarImageBlank;
	}
	else return avatars[user.objectId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = messages[indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return nil;
	}

	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = messages[indexPath.item-1];
		if ([previousMessage.senderId isEqualToString:message.senderId])
		{
			return nil;
		}
	}
	return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return 0;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = messages[indexPath.item-1];
		if ([previousMessage.senderId isEqualToString:message.senderId])
		{
			return 0;
		}
	}
	return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0;
}

#pragma mark - Responding to collection view tap events

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapLoadEarlierMessagesButton");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
		   atIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapAvatarImageView");
    GTLStoreendpointChatMessage *message = [serverMessages objectAtIndex:indexPath.row];
    [self setRoomOrStoreChatMembershipId:message.roomId.longValue isStore:false];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapMessageBubbleAtIndexPath");
    GTLStoreendpointChatMessage *message = [serverMessages objectAtIndex:indexPath.row];
    [self setRoomOrStoreChatMembershipId:message.roomId.longValue isStore:false];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
    GTLStoreendpointChatMessage *message = [serverMessages objectAtIndex:indexPath.row];
    [self setRoomOrStoreChatMembershipId:message.roomId.longValue isStore:false];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		if (buttonIndex == 0)	ShouldStartCamera(self, YES);
		if (buttonIndex == 1)	ShouldStartPhotoLibrary(self, YES);
	}
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *picture = info[UIImagePickerControllerEditedImage];
	[self sendMessage:@"[Picture message]" Picture:picture];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

@end
