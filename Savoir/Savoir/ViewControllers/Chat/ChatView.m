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
#import "UIColor+SavoirBackgroundColor.h"
#import "UIColor+SavoirGoldColor.h"
#import "InlineCalls.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
	NSTimer *timer;
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


@property (nonatomic) long roomOrStoreId;
@property (nonatomic) long storeId;
@property (nonatomic) Boolean isStore;

- (void) showIndividualRoomMessagesForStore:(long)roomOrStoreId isStore:(Boolean)isStore currentStoreId:(long)storeid;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatView

// Added by bdpothik
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(long)roomOrStoreId isStore:(Boolean)isStore currentStoreId:(long)storeid
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
    self.roomOrStoreId = roomOrStoreId;
    self.isStore = isStore;
    self.storeId = storeid;
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
    
    self.view.backgroundColor = [UIColor asaanBackgroundColor];
    self.collectionView.backgroundColor = [UIColor asaanBackgroundColor];
    self.inputToolbar.tintColor = [UIColor goldColor];
//    self.inputToolbar.backgroundColor = [UIColor asaanBackgroundColor];
    self.inputToolbar.barTintColor = [UIColor asaanBackgroundColor];
    
    if (self.isStore == true)
        self.inputToolbar.hidden = true;
    else
        self.inputToolbar.hidden = false;

	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];

	avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:30.0];

    users = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    serverMessages = [[NSMutableArray alloc] init];
    avatars = [[NSMutableDictionary alloc] init];
    [self loadMessagesForSend:false];
}

- (void) showIndividualRoomMessagesForStore:(long)roomOrStoreId isStore:(Boolean)isStore currentStoreId:(long)storeid
{
    if (roomOrStoreId != self.roomOrStoreId || isStore != self.isStore)
    {
        ChatView *chatView = [[ChatView alloc] initWith:roomOrStoreId isStore:isStore currentStoreId:self.storeId];
        chatView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatView animated:YES];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	self.collectionView.collectionViewLayout.springinessEnabled = YES;
//	timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(loadMessagesForSend:false) userInfo:nil repeats:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.notificationUtils.bReceivedChatNotification = false;
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
- (void)loadMessagesForSend:(Boolean)forSend
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (isLoading == NO)
    {
        isLoading = YES;
		GTLStoreendpointChatMessage *message_last = [serverMessages lastObject];
        
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetChatMessagesForStoreOrRoomWithRoomOrStoreId:weakSelf.roomOrStoreId modifiedDate:message_last.createdDate.longLongValue isStore:weakSelf.isStore firstPosition:0 maxResult:50];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
        [query setAdditionalHTTPHeaders:dic];
       
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatMessagesAndUsers *object,NSError *error)
         {
             if (!error)
             {
                self.automaticallyScrollsToMostRecentMessage = NO;
                 
                messagesAndUsers = object;
                 NSInteger position = 0;
                for (GTLStoreendpointChatMessage *message in [object.chatMessages reverseObjectEnumerator])
                {
                    [self addMessage:message forSend:forSend];
                    position++;
                }
                if ([object.chatMessages count] != 0)
                {
                    self.automaticallyScrollsToMostRecentMessage = YES;
                    [self finishReceivingMessage];
                }
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
- (void)addMessage:(GTLStoreendpointChatMessage *)object forSend:(Boolean)forSend
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
    GTLStoreendpointChatUser *chatUser;
    for (GTLStoreendpointChatUser *user in messagesAndUsers.chatUsers)
        if (object.userId.longLongValue == user.userId.longLongValue)
        {
            chatUser = user;
            [users addObject:user];
            break;
        }
    [serverMessages addObject:object];
	if (object.fileMessage == nil)
	{
		JSQMessage *message = [[JSQMessage alloc] initWithSenderId:chatUser.objectId senderDisplayName:chatUser.name
																	  date:[NSDate dateWithTimeIntervalSince1970:object.createdDate.longLongValue/1000] text:object.txtMessage];
		[messages addObject:message];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (object.fileMessage != nil)
	{
		JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
		mediaItem.appliesMediaViewMaskAsOutgoing = [chatUser.objectId isEqualToString:self.senderId];
		JSQMessage *message =
			[[JSQMessage alloc] initWithSenderId:chatUser.objectId senderDisplayName:chatUser.name date:[NSDate dateWithTimeIntervalSince1970:object.createdDate.longLongValue/1000] media:mediaItem];
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
                if(forSend == true)
                    [self.collectionView reloadData];
            }
        }];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSString *)text Picture:(PFFile *)pictureFile
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    GTLStoreendpointChatMessage *newMessage = [[GTLStoreendpointChatMessage alloc]init];
    
    if (self.isStore == false)
        newMessage.roomId = [NSNumber numberWithLong:self.roomOrStoreId];
    
    newMessage.txtMessage = text;
    newMessage.fileMessage = pictureFile.url;

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
             [weakSelf loadMessagesForSend:true];
             
             if (IsEmpty(text) == true)
                 SendPushNotification(self.roomOrStoreId, self.storeId, @"You have a message.");
             else
                 SendPushNotification(self.roomOrStoreId, self.storeId, text);
             
             [self finishSendingMessage];
         }
         else
         {
             NSLog(@"queryForSaveChatMessageWithObject error:%ld, %@", error.code, error.debugDescription);
             [ProgressHUD showError:@"Network error."];
         }
     }];
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
//    NSLog(@"numberOfItemsInSection %u", (unsigned int)[messages count]);
//    NSLog(@"%@",[NSThread callStackSymbols]);
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//    NSLog(@"cellForItemAtIndexPath %u", (unsigned int)indexPath.item);
//    if (indexPath.item == 0)
//        NSLog(@"%@",[NSThread callStackSymbols]);

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
    [self showIndividualRoomMessagesForStore:message.roomId.longLongValue isStore:false currentStoreId:self.storeId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapMessageBubbleAtIndexPath");
    GTLStoreendpointChatMessage *message = [serverMessages objectAtIndex:indexPath.row];
    [self showIndividualRoomMessagesForStore:message.roomId.longLongValue isStore:false currentStoreId:self.storeId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
    GTLStoreendpointChatMessage *message = [serverMessages objectAtIndex:indexPath.row];
    [self showIndividualRoomMessagesForStore:message.roomId.longLongValue isStore:false currentStoreId:self.storeId];
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
    PFFile *filePicture = nil;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (picture != nil)
    {
        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil)
                 [ProgressHUD showError:@"Picture save error."];
             else
                 [self sendMessage:@"[Picture message]" Picture:filePicture];

         }];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

@end
