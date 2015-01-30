//
//  BaseViewController.m
//  AsaanImprovedUI
//
//  Created by MC MINI on 11/11/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "BaseViewController.h"
#import "UITextField+Extender.h"

@interface BaseViewController ()
    @property(nonatomic) CGRect frameRect;
    @property(nonatomic) Boolean isKeyboardShowing;
    @property(nonatomic) CGFloat keyboardHeight;
    @property(nonatomic) UITapGestureRecognizer *tap;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize: size withTransitionCoordinator:coordinator];
    _frameRect.size = size;
    _baseScrollView.contentSize = _frameRect.size;
    NSLog(@"viewWillTransitionToSize");
}
- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
    _frameRect = self.view.frame;
    _baseScrollView.contentSize = _frameRect.size;
    NSLog(@"didRotateFromInterfaceOrientation");
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    _frameRect = self.view.frame;
    _baseScrollView.contentSize = _frameRect.size;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [self.view endEditing:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _baseScrollView.contentSize = _frameRect.size;
    [_baseScrollView layoutSubviews];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    activeTextView = textView;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    activeTextView = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    UITextField *next = theTextField.nextTextField;
    if (next) {
        [next becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
    
    return YES;
}

- (void)resizeScrollbarToFitKeyboard
{
    UIEdgeInsets contentInsets;
    contentInsets = UIEdgeInsetsMake(0.0, 0.0, _keyboardHeight, 0.0);
    
    _baseScrollView.contentInset = contentInsets;
    _baseScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = _frameRect;
    aRect.size.height -= _keyboardHeight;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [_baseScrollView scrollRectToVisible:activeField.frame animated:YES];
    }
    
    if (!CGRectContainsPoint(aRect, activeTextView.frame.origin) ) {
        [_baseScrollView scrollRectToVisible:activeTextView.frame animated:YES];
    }
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
    [self.view removeGestureRecognizer:_tap];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    _tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:_tap];
    _isKeyboardShowing = true;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"keyboardWasShown kbSize.height = %f, width = %f", kbSize.height, kbSize.width);
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    _keyboardHeight = kbSize.height;
    
    if (UIDeviceOrientationIsLandscape(orientation) == true && SYSTEM_VERSION_LESS_THAN(@"8.0"))
        _keyboardHeight = kbSize.width;
    
    [self resizeScrollbarToFitKeyboard];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    _isKeyboardShowing = false;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _baseScrollView.contentInset = contentInsets;
    _baseScrollView.scrollIndicatorInsets = contentInsets;
    NSLog(@"keyboardWillBeHidden");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
