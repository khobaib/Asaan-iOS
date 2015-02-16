//
//  InlineCalls.h
//  Savoir
//
//  Created by Nirav Saraiya on 11/14/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#ifndef Savoir_InlineCalls_h
#define Savoir_InlineCalls_h

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
