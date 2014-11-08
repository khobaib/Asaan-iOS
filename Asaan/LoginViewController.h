//
//  LoginViewController.h
//  Asaan
//
//  Created by MC MINI on 9/24/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <GooglePlus/GooglePlus.h>

@interface LoginViewController : UIViewController<UIAlertViewDelegate,GPPSignInDelegate>{
    MBProgressHUD *hud;

}

@property IBOutlet UITextField *emailField;
@property IBOutlet UITextField *passwordFild;

@end
