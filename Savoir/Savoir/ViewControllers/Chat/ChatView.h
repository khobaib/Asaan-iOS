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

#import "JSQMessages.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView : JSQMessagesViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic) Boolean presentedFromNotification;

@property (nonatomic) long long roomOrStoreId;
@property (nonatomic) long long storeId;
@property (nonatomic) Boolean isStore;

- (id)initWith:(long long)roomOrStoreId isStore:(Boolean)isStore currentStoreId:(long long)storeid;

- (void) refreshMessageView;

@end
