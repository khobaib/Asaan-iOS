//
//  DropdownView.h
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DropdownViewDelegate <NSObject>

@optional
- (void)dropdownViewActionForSelectedRow:(int)row sender:(id)sender;

@end

@interface DropdownView : UIView

@property (nonatomic, weak) id <DropdownViewDelegate> delegate;
@property (nonatomic, strong) UIColor* listBackgroundColor;
@property (nonatomic, strong) UIColor* titleColor;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) BOOL enabledTitle;
@property (nonatomic, assign) BOOL enabledCheckmark;

- (void)refresh;    // to unlink all previous views and setup from start. You have to setup all values after calling this method.
- (void)setData:(NSArray *)data;        // to change existing data
- (void)setDefaultSelection:(int)defaultSelection;

@end
