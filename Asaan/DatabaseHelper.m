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

@implementation DatabaseHelper
+(BOOL)saveUpdateStores:(NSArray *)resturantList{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext= [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Store" inManagedObjectContext:managedObjectContext]];
    
    for(int i=0;i<resturantList.count;i++){
        NSMutableDictionary *dic=[resturantList objectAtIndex:i];
        
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"storeId == %@",[NSNumber numberWithInteger:[dic[@"id"] integerValue]]];
        
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
        
        [self dicToStore:dic store:store];
    }
    
    
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        
        return NO;
    }else{
        
               
        return YES;
    }
    
    

}

+(void)dicToStore:(NSDictionary *)dic store:(Store*)store{
    
    store.storeId=[NSNumber numberWithInteger:[dic[@"id"] integerValue]];
    store.name=dic[@"name"];
    store.storeDescription=dic[@"description"];
    store.beaconid=dic[@"beaconId"];
    store.phone=dic[@"phone"];
    store.isActive=dic[@"isActive"];
    store.priceRange=[NSNumber numberWithInt:[dic[@"priceRange"] intValue]];
    store.bssid=dic[@"bssid"];
    store.ssid=dic[@"ssid"];
    store.address=dic[@"address"];
    store.city=dic[@"city"];
    store.state=dic[@"state"];
    store.zip=dic[@"zip"];
    store.type=dic[@"type"];
    store.subtype=dic[@"subType"];
    store.lat=dic[@"lat"];
    store.lon=dic[@"lng"];
    store.websiteurl=dic[@"webSiteUrl"];
    store.fburl=dic[@"fbUrl"];
    
    store.twitterUrl=dic[@"twitterUrl"];

    store.rewardSrate=dic[@"rewardsRate"];
    store.hourse=dic[@"hours"];
    store.createddate=[NSNumber numberWithInt:[dic[@"createdDate"] intValue]];
    store.modifiedDate=[NSNumber numberWithInt:[dic[@"modifiedDate"] intValue]];
   
 
}



+(NSArray *)getAllStores{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext= [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Store" inManagedObjectContext:managedObjectContext]];
     NSError *error = nil;
    return  [managedObjectContext executeFetchRequest:request error:&error];
}


@end
