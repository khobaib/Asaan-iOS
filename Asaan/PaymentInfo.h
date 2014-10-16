//
//  PaymentInfo.h
//  Asaan
//
//  Created by MC MINI on 9/21/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTKView.h"

@interface PaymentInfo : UIViewController<PTKViewDelegate,UITextFieldDelegate>{
    BOOL isCardValid;
}

@property IBOutlet PTKView *payment;

@end
