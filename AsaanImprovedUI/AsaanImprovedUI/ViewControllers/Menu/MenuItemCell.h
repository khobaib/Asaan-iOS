//
//  MenuItemCell.h
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuItemCell;
@protocol MenuItemCellDelegate <NSObject>

- (void)menuItemCell:(MenuItemCell *)menuItemCell didClickedItemImage:(UIImageView *)sender;

@end

@interface MenuItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *todaysOrdersLabels;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *mostOrderedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;

@property (weak, nonatomic) IBOutlet id<MenuItemCellDelegate> delegate;

@property (strong, nonatomic) NSIndexPath *indexPath;

@end
