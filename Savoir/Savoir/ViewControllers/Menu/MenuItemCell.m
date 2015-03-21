//
//  MenuItemCell.m
//  Savoir
//
//  Created by Hasan Ibna Akbar on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MenuItemCell.h"

@implementation MenuItemCell

- (void)awakeFromNib {
    // Initialization code
    
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnItemImageView:)];
    tapped.numberOfTapsRequired = 1;
    
    _itemImageView.userInteractionEnabled = YES;
    [_itemImageView addGestureRecognizer:tapped];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.frame);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tappedOnItemImageView:(id)sender {
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(menuItemCell:didClickedItemImage:)]) {
        
        [self.delegate menuItemCell:self didClickedItemImage:self.itemImageView];
    }
}

@end
