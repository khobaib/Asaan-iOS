//
//  AsaanUtilities.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 11/15/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "AsaanUtilities.h"

@implementation AsaanUtilities

+ (BOOL) validateEmail:(NSString *)emailID {
    
    if (!emailID || [emailID isEqualToString:@""]) {
        
        return false;
    }
    
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailID];
}

@end
