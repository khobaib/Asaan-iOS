//
//  SignupProfileViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/10/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UserInfo.h"

@interface SignupProfileViewController : BaseViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UserInfo* userInfo;

@end
