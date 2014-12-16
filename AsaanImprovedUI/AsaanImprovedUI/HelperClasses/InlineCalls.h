//
//  InlineCalls.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/14/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#ifndef AsaanImprovedUI_InlineCalls_h
#define AsaanImprovedUI_InlineCalls_h

static inline Boolean IsEmpty(NSString *string) {
    
    if (string && ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return false;
    }
    
    return true;
    
//    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    return string == nil
//    || ([string length] == 0);
}

#endif
