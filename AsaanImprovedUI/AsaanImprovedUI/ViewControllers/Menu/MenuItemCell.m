//
//  MenuItemCell.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 11/29/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MenuItemCell.h"

#import <ParseUI/ParseUI.h>

@implementation MenuItemCell

// Need to implement layoutSubiews and set the preferred max layout width of the multi-line label or
// the cell height does not get correctly calculated when the device changes orientation.
//
// Credit to this GitHub example project and StackOverflow answer for providing the missing details:
//
// https://github.com/smileyborg/TableViewCellWithAutoLayout
// http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.frame);
    self.statisticLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.statisticLabel.frame);
    self.likeCountLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.likeCountLabel.frame);
    self.priceLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.priceLabel.frame);
    self.statusLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.statusLabel.frame);
}

@end
