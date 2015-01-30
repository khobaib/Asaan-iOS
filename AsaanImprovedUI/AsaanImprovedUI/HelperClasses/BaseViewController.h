//
//  BaseViewController.h
//  AsaanImprovedUI
//
//  Created by MC MINI on 11/11/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>{
    UITextField *activeField;
    UITextView *activeTextView;
}
    @property(weak, nonatomic) UIScrollView* baseScrollView;

@end
