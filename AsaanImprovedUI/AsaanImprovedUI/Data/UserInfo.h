//
//  UserInfo.h
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 11/15/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* phone;

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* imagePath;

@property (strong, nonatomic) NSString* creditCardNumber;

@end
