//
//  SlidingMenuViewController.h
//  Savoir
//
//  Created by Hasan Ibna Akbar on 1/4/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBadgedCell.h"

@interface SMTableViewCell1 : TDBadgedCell

@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;

@end

@interface SlidingMenuViewController : UITableViewController

@end
