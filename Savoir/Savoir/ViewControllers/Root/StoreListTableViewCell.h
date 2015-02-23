//
//  StoreListTableViewCell.h
//  Savoir
//
//  Created by Hasan Ibna Akbar on 1/17/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *visitorsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *likesImageView;
@property (weak, nonatomic) IBOutlet UIView *statsView;

@property (weak, nonatomic) IBOutlet UILabel *restaurantLabel;
@property (weak, nonatomic) IBOutlet UILabel *trophyLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuisineLabel;
@property (weak, nonatomic) IBOutlet UILabel *visitLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *orderOnlineButton;
@property (weak, nonatomic) IBOutlet UIButton *reserveButton;

@end
