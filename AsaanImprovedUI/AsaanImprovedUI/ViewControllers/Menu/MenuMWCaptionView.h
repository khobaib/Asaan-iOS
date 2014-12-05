//
//  MenuMWCaptionView.h
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MWCaptionView.h"

@interface MenuMWCaptionView : MWCaptionView

@property (strong, nonatomic) IBOutlet NSString *textTitle;
@property (strong, nonatomic) IBOutlet NSString *textDescription;
@property (strong, nonatomic) IBOutlet NSString *textTodaysOrders;
@property (strong, nonatomic) IBOutlet NSString *textLikes;
@property (strong, nonatomic) IBOutlet UIImage *imageLike;
@property (strong, nonatomic) IBOutlet NSString *textPrice;
@property (strong, nonatomic) IBOutlet NSString *textMostOrdered;

@end
