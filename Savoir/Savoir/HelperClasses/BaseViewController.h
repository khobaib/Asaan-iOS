//
//  BaseViewController.h
//  Savoir
//
//  Created by MC MINI on 11/11/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
{
    UITextField * activeField;
    UITextView * activeTextView;
    UITextField * activePTKField;
}

@property(weak, nonatomic) UIScrollView * baseScrollView;

@end
