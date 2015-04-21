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
#import "ChatConstants.h"
#import "pushnotification.h"
#import "AppDelegate.h"
#import "GTLStoreendpoint.h"
#import "UtilCalls.h"
#import "Constants.h"
#import "InStoreOrderDetails.h"
#import "InlineCalls.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserAssign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [PFUser currentUser];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserAssign save error.");
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserResign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [NSNull null];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserResign save error.");
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification(long long roomId, long long storeId, NSString *text)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetChatUsersForRoomWithRoomId:roomId];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointChatUserArray *object,NSError *error)
     {
         if (error == nil)
         {
             NSMutableArray *userObjectIds = [[NSMutableArray alloc]init];
             PFUser *user = [PFUser currentUser];
             for (GTLStoreendpointChatUser *chatUser in object.chatUsers)
                 if ([chatUser.objectId isEqualToString:user.objectId] == false)
                     [userObjectIds addObject:chatUser.objectId];
             
             PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
             [query whereKey:PF_USER_OBJECTID containedIn:userObjectIds];
             
             PFQuery *queryInstallation = [PFInstallation query];
             [queryInstallation whereKey:PF_INSTALLATION_USER matchesQuery:query];
             
             NSDictionary *pushContent = @{@"alert": text, @"TYPE":@"CHAT", @"CHAT_ROOMID":[NSString stringWithFormat:@"%lld", roomId], @"CHAT_STOREID":[NSString stringWithFormat:@"%lld", storeId]};
             
             PFPush *push = [[PFPush alloc] init];
             [push setQuery:queryInstallation];
//             [push setMessage:text];
             [push setData:pushContent];
             [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (error != nil)
                  {
                      NSLog(@"SendPushNotification send error:%ld, %@.", (long)error.code, error.debugDescription);
                  }
              }];
         }
         else
         {
             NSLog(@"queryForGetChatUsersForRoomWithRoomId error:%ld, %@.", (long)error.code, error.debugDescription);
         }
     }];
}