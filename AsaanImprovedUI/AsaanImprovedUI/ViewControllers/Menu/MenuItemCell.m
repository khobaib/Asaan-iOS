//
//  MenuItemCell.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MenuItemCell.h"
#import <ParseUI/ParseUI.h>

@implementation MenuItemCell

- (void)awakeFromNib {
    // Initialization code
    
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnItemImageView:)];
    tapped.numberOfTapsRequired = 1;
    
    _itemPFImageView.userInteractionEnabled = YES;
    [_itemPFImageView addGestureRecognizer:tapped];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tappedOnItemImageView:(id)sender {
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(menuItemCell:didClickedItemImage:)]) {
        
        [self.delegate menuItemCell:self didClickedItemImage:self.itemPFImageView];
    }
}

@end
