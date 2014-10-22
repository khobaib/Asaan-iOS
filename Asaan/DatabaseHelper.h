//
//  DatabaseHelper.h
//  Asaan
//
//  Created by MC MINI on 10/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseHelper : NSObject

+(BOOL)saveUpdateStores:(NSArray *)stores;

+(NSArray *)getAllStores;

@end
