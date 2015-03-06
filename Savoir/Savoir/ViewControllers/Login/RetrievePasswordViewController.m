//
//  RetrievePasswordViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 11/15/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "RetrievePasswordViewController.h"
#import "UIColor+SavoirGoldColor.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "InlineCalls.h"

@interface RetrievePasswordViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *lblMessage;
    @property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@end

@implementation RetrievePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIColor *color = [UIColor lightTextColor];
    _txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"name@example.com" attributes:@{NSForegroundColorAttributeName: color}];
    _txtEmail.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _txtEmail) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Sending password retrieval email ...";
        hud.hidden = NO;
        [PFUser requestPasswordResetForEmailInBackground:_txtEmail.text];
        _lblMessage.text = @"Email sent. Please check your mailbox.";
        hud.hidden = YES;
        [NSThread sleepForTimeInterval:1];
        [self performSegueWithIdentifier:@"segueUnwindToLogin" sender:textField];
    }
    return YES;
}

- (IBAction)txtEmailEditingDidEnd:(id)sender {
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
