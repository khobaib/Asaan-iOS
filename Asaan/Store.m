//
//  Store.m
//  Asaan
//
//  Created by MC MINI on 10/22/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "Store.h"


@implementation Store

@dynamic address;
@dynamic backgroundimagethumbnilurl;
@dynamic backgroundimageurl;
@dynamic beaconid;
@dynamic bssid;
@dynamic city;
@dynamic createddate;
@dynamic fburl;
@dynamic gplusurl;
@dynamic hourse;
@dynamic lat;
@dynamic lon;
@dynamic modifiedDate;
@dynamic name;
@dynamic phone;
@dynamic priceRange;
@dynamic rewardDescription;
@dynamic rewardSrate;
@dynamic isActive;
@dynamic ssid;
@dynamic state;
@dynamic storeDescription;
@dynamic storeId;
@dynamic subtype;
@dynamic trophies;
@dynamic twitterUrl;
@dynamic type;
@dynamic websiteurl;
@dynamic zip;


+(GTLStoreendpointStore *)gtlStoreFromStore:(Store *)store{
    GTLStoreendpointStore *gtlStore=[[GTLStoreendpointStore alloc]init];
    gtlStore.address=store.address;
    gtlStore.backgroundImageUrl=store.backgroundimageurl;
    gtlStore.backgroundThumbnailUrl=store.backgroundimagethumbnilurl;
    gtlStore.bssid=store.bssid;
    gtlStore.city=store.city;
    gtlStore.createdDate=store.createddate;
    gtlStore.fbUrl=store.fburl;
    gtlStore.gplusUrl=store.gplusurl;
    gtlStore.hours=store.hourse;
    gtlStore.lat=store.lat;
    gtlStore.lng=store.lon;
    gtlStore.modifiedDate=store.modifiedDate;
    gtlStore.name=store.name;
    gtlStore.phone=store.phone;
    gtlStore.priceRange=store.priceRange;
    gtlStore.rewardsDescription=store.rewardDescription;
    gtlStore.rewardsRate=store.rewardSrate;
    gtlStore.isActive=store.isActive;
    gtlStore.ssid=store.ssid;
    gtlStore.state=store.state;
    gtlStore.descriptionProperty=store.storeDescription;
    gtlStore.identifier=store.storeId;
    gtlStore.subType=store.subtype;
    //gtlStore.trophies=store.trophies;
    gtlStore.twitterUrl=store.twitterUrl;
    gtlStore.type=store.type;
    gtlStore.webSiteUrl=store.websiteurl;
    gtlStore.zip=store.zip;
    
    
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    gtlStore.beaconId = [f numberFromString:store.beaconid];
  
    
    
    return gtlStore;
}

+(GTLStoreendpointStore *)gtlStoreFromID:(id)str{
    
    GTLStoreendpointStore *store;
    if([str isKindOfClass:[GTLStoreendpointStore class]]){
        store=(GTLStoreendpointStore *)str;
    }else{
        store=[self gtlStoreFromStore:(Store *)str];
    }

    return store;
}

@end
