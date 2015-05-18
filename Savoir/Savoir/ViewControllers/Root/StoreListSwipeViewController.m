//
//  StoreListSwipeViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 5/13/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "StoreListSwipeViewController.h"
#import "DraggableViewBackground.h"
#import "CardView.h"

@interface StoreListSwipeViewController ()
@property (weak, nonatomic) IBOutlet DraggableViewBackground *draggableViewBackground;
@property (weak, nonatomic) IBOutlet CardView *cardView;

@end

@implementation StoreListSwipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.draggableViewBackground.parentViewController = self;
    [self.draggableViewBackground setupView];
//    self.cardSwipeView = [[[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil] objectAtIndex:0];
//    [self.draggableViewBackground addSubview:self.cardSwipeView];
//    [self.cardSwipeView setTranslatesAutoresizingMaskIntoConstraints:false];
//    
//    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.cardSwipeView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.draggableViewBackground attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.f];
//    
//    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.cardSwipeView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.draggableViewBackground attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.f];
//    
//    NSLayoutConstraint *topHorizontal = [NSLayoutConstraint constraintWithItem:self.cardSwipeView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.draggableViewBackground attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
//    
//    NSLayoutConstraint *bottomVertical = [NSLayoutConstraint constraintWithItem:self.cardSwipeView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.draggableViewBackground attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f];
//    
//    [self.draggableViewBackground addConstraints:@[leadingConstraint, trailingConstraint, topHorizontal, bottomVertical]];
    
//    [self.cardSwipeView layoutIfNeeded];
//    [self.draggableViewBackground layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)prevCardClicked:(id)sender {
}
- (IBAction)nextCardClicked:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
