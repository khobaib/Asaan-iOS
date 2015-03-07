//
//  InlineCalls.h
//  Savoir
//
//  Created by Nirav Saraiya on 11/14/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#ifndef Savoir_InlineCalls_h
#define Savoir_InlineCalls_h

#import <CoreLocation/CoreLocation.h>

static inline Boolean IsEmpty(NSString *string) {
    
    if (string && ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return false;
    }
    
    return true;
    
//    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    return string == nil
//    || ([string length] == 0);
}


static inline double DEG2RAD(double degrees) {
    return degrees * M_PI / 180;
}

static inline double RAD2DEG(double radians) {
    return radians * 180 / M_PI;
}

#endif
