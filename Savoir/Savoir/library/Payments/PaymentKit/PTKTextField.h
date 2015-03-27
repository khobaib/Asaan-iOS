//
//  PTKTextField.h
//  PaymentKit Example
//
//  Created by Michaël Villar on 3/20/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PTKTextField;

@protocol PTKTextFieldDelegate <UITextFieldDelegate>

@optional

- (void) pkTextFieldDidBackSpaceWhileTextIsEmpty:(PTKTextField *) textField;
//- (void) pkTextFieldDidBeginEditing:(PTKTextField *) textField; //<--
//- (void) pkTextFieldDidEndEditing:(PTKTextField *) textField; //<--

@end

@interface PTKTextField : UITextField //<UITextFieldDelegate> //<--

+ (NSString*)textByRemovingUselessSpacesFromString:(NSString*)string;

@property (nonatomic, weak) id<PTKTextFieldDelegate> delegate;

@end

