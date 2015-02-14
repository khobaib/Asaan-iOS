//
//  StoreListTableViewCell.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 1/17/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "StoreListTableViewCell.h"

@implementation StoreListTableViewCell

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    
    self.callButton.tag = tag;
    self.chatButton.tag = tag;
    self.menuButton.tag = tag;
    self.orderOnlineButton.tag = tag;
    self.reserveButton.tag = tag;
    
    self.restaurantLabel.text = nil;
    self.trophyLabel.text = nil;
    self.cuisineLabel.text = nil;
    self.visitLabel.text = nil;
    self.likeLabel.text = nil;
    self.statsView.hidden = true;
    self.visitorsImageView.hidden = true;
    self.likesImageView.hidden = true;
}

@end