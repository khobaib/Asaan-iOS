//
//  MenuMWCaptionView.h
//  Savoir
//
//  Created by Hasan Ibna Akbar on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MWCaptionView.h"

@class MenuMWCaptionView;
@protocol MenuMWCaptionViewDelegate <NSObject>

@optional
- (void)menuMWCaptionView:(MenuMWCaptionView *)menuMWCaptionView didClickedOrderButton:(UIButton *)sender;
- (void)menuMWCaptionView:(MenuMWCaptionView *)menuMWCaptionView didClickedOrderButtonAtIndex:(NSUInteger)index;

@end

@interface MenuMWCaptionView : MWCaptionView

@property (assign, nonatomic) NSUInteger index;

@property (strong, nonatomic) NSString *textTitle;
@property (strong, nonatomic) NSString *textDescription;
@property (strong, nonatomic) NSString *textTodaysOrders;
@property (strong, nonatomic) NSString *textLikes;
@property (strong, nonatomic) UIImage *imageLike;
@property (strong, nonatomic) NSString *textPrice;
@property (strong, nonatomic) NSString *textMostOrdered;
@property (assign, nonatomic) BOOL enabledOrderButton;
@property (strong, nonatomic) UIColor *orderButtonTextColor;

@property (weak, nonatomic) id<MenuMWCaptionViewDelegate> delegate;

@end
