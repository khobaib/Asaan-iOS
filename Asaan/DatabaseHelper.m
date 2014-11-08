//
//  DatabaseHelper.m
//  Asaan
//
//  Created by MC MINI on 10/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "DatabaseHelper.h"
#import "AppDelegate.h"
#import "Store.h"
#import "GTLStoreendpoint.h"
#import <Parse/Parse.h>

@implementation DatabaseHelper
+(BOOL)saveUpdateStores:(NSArray *)resturantList{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext= [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Store" inManagedObjectContext:managedObjectContext]];
    
    for(int i=0;i<resturantList.count;i++){
        GTLStoreendpointStore *storegtl=[resturantList objectAtIndex:i];
        
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"storeId == %@",[NSNumber numberWithInteger:[storegtl.identifier integerValue]]];
        
        [request setPredicate:predicate];
        NSError *error = nil;
        NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
        Store *store;
        

        if(results.count>0){
            
            store=[results objectAtIndex:0];
            
        }else{
            store=[NSEntityDescription
                   insertNewObjectForEntityForName:@"Store"
                   inManagedObjectContext:managedObjectContext];
            
        }
        
        [self dicToStore:storegtl store:store];
    }
    
    
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        
        return NO;
    }else{
        
               
        return YES;
    }
    
    

}


+(BOOL)saveOrder:(GTLStoreendpointStoreMenuItem *)item quantityStr:(NSString *)quantity noteStr:(NSString *)note{
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext= [appDelegate managedObjectContext];
    
    Order *order=[NSEntityDescription
           insertNewObjectForEntityForName:@"Order"
           inManagedObjectContext:managedObjectContext];
    
    [self itemToOrder:item orderOb:order quantityStr:quantity noteStr:note];
    
    
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        
        return NO;
    }else{
        
       
        return YES;
    }

}


+(void)dicToStore:(GTLStoreendpointStore *)dic store:(Store*)store{
    
    store.storeId=dic.identifier;
    store.name=dic.name;
    store.storeDescription=dic.descriptionProperty;
    store.beaconid=[NSString stringWithFormat:@"%@",dic.beaconId];
    store.phone=dic.phone;
    store.isActive=dic.isActive;
    store.priceRange=dic.priceRange;
    store.bssid=dic.bssid;
    store.ssid=dic.ssid;
    store.address=dic.address;
    store.city=dic.city;
    store.state=dic.state;
    store.zip=dic.zip;
    store.type=dic.type;
    store.subtype=dic.subType;
    store.lat=dic.lat;
    store.lon=dic.lng;
    store.websiteurl=dic.webSiteUrl;
    store.fburl=dic.fbUrl;
    
    store.twitterUrl=dic.twitterUrl;

    store.rewardSrate=dic.rewardsRate;
    store.hourse=dic.hours;
    store.createddate=dic.createdDate;
    store.modifiedDate=dic.modifiedDate;
   
 
}


+(void)itemToOrder:(GTLStoreendpointStoreMenuItem *)item orderOb:(Order *)order quantityStr:(NSString *)quantity noteStr:(NSString *)note{
    
   
    order.menuItemPOSId=item.menuItemPOSId;
    order.menuItemPosition=item.menuItemPosition;
    order.menuPOSId=item.menuPOSId;
    order.menuName=item.menuName;
    order.subMenuPOSId=item.subMenuPOSId;
    order.shortDescriptionProperty=item.shortDescription;
    order.quantity=[NSNumber numberWithInt:[quantity intValue]];
    order.userID=[NSNumber numberWithInt:[[PFUser currentUser].objectId intValue]];
    order.note=note;
    order.username=[PFUser currentUser].username;
    order.storeId=item.storeId;
    order.price=item.price;
    
    
}

+(NSArray *)getAllStores{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext= [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Store" inManagedObjectContext:managedObjectContext]];
     NSError *error = nil;
    return  [managedObjectContext executeFetchRequest:request error:&error];
}

+(NSArray *)getAllOrders{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext= [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    return  [managedObjectContext executeFetchRequest:request error:&error];
}


+(BOOL)deletAllObjectsfromEntity:(NSString *)entity{
    
    NSLog(@"delet");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext= [appDelegate managedObjectContext];
    
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:managedObjectContext]];
    [allCars setIncludesPropertyValues:NO];
    
    NSError * error = nil;
    NSArray * cars = [managedObjectContext executeFetchRequest:allCars error:&error];
 

    for (NSManagedObject * car in cars) {
        [managedObjectContext deleteObject:car];
    }
    NSError *saveError = nil;
    if([managedObjectContext save:&saveError]){
        return YES;
    }else{
        return NO;
    }
    
  
}

@end
