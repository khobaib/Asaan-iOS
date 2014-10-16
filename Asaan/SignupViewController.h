//
//  SignupViewController.h
//  Asaan
//
//  Created by MC MINI on 9/9/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController<UITextFieldDelegate>{
    UIDatePicker *birthdayPicker;
}

@property IBOutlet UITextField *birthdate;
@property IBOutlet UITextField *firstName;
@property IBOutlet UITextField *lastName;
@property IBOutlet UITextField *email;
@property IBOutlet UITextField *password;
@property IBOutlet UITextField *phoneno;

@end
