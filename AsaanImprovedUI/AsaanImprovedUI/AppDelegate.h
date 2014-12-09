//
//  AppDelegate.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/6/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GTLStoreendpoint.h"
#import "GTLUserendpoint.h"
#import "GlobalObjectHolder.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) GTLServiceStoreendpoint *gtlStoreService;
@property (readonly, strong, nonatomic) GTLServiceUserendpoint *gtlUserService;
@property (readonly, strong, nonatomic) GlobalObjectHolder *globalObjectHolder;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

