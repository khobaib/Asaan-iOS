//
//  SubMenuCell.h
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 11/29/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropdownView;
@interface SubMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet DropdownView *dropdownView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
