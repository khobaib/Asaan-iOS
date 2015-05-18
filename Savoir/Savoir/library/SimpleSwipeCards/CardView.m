//
//  CardView.m
//  Savoir
//
//  Created by Nirav Saraiya on 5/15/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "CardView.h"

#define CORNER_RATIO 0.015


@interface CardView()
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIView *cpMask;
@property (weak, nonatomic) IBOutlet UIImageView *storeImageView;
@property (weak, nonatomic) IBOutlet UILabel *txtTitle;
@property (weak, nonatomic) IBOutlet UIImageView *yelpImageView;
@property (weak, nonatomic) IBOutlet UILabel *txtReviewCount;
@property (weak, nonatomic) IBOutlet UILabel *txtCuisine;
@property (weak, nonatomic) IBOutlet UILabel *txtTrophy;
@property (weak, nonatomic) IBOutlet UILabel *txtDistance;
@property (weak, nonatomic) IBOutlet UIView *callView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *promoView;
@property (weak, nonatomic) IBOutlet UIView *distanceView;
@property (weak, nonatomic) IBOutlet UIView *yelpView;

@end

@implementation CardView {
    UIVisualEffectView *visualEffectView;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    self.layer.cornerRadius = self.frame.size.width * CORNER_RATIO;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0;
    self.layer.shadowOffset = CGSizeMake(1, 1);
    [self setupPhotos];
}

- (void)addShadow
{
    self.layer.shadowOpacity = 0.15;
}

- (void)removeShadow
{
    self.layer.shadowOpacity = 0;
}

- (void)setupViewWithDelegate:(id<CardViewDelegate, DraggableViewDelegate>)delegate AndTitle:(NSString *)strTitle
{
    self.cardViewDelegate = delegate;
    self.txtTitle.text = strTitle;
    [super setup];
    super.delegate = delegate;
    
    UITapGestureRecognizer *callTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callViewTapDetected)];
    callTap.numberOfTapsRequired = 1;
    [self.callView setUserInteractionEnabled:YES];
    [self.callView addGestureRecognizer:callTap];
    
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuViewTapDetected)];
    menuTap.numberOfTapsRequired = 1;
    [self.menuView setUserInteractionEnabled:YES];
    [self.menuView addGestureRecognizer:menuTap];
    
    UITapGestureRecognizer *promoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promoViewTapDetected)];
    promoTap.numberOfTapsRequired = 1;
    [self.promoView setUserInteractionEnabled:YES];
    [self.promoView addGestureRecognizer:promoTap];
    
    UITapGestureRecognizer *yelpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yelpTapDetected)];
    yelpTap.numberOfTapsRequired = 1;
    [self.yelpView setUserInteractionEnabled:YES];
    [self.yelpView addGestureRecognizer:yelpTap];
    
    UITapGestureRecognizer *mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapDetected)];
    mapTap.numberOfTapsRequired = 1;
    [self.distanceView setUserInteractionEnabled:YES];
    [self.distanceView addGestureRecognizer:mapTap];
    
    UITapGestureRecognizer *selfTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTapDetected)];
    selfTap.numberOfTapsRequired = 1;
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:selfTap];
}
- (IBAction)bookmarkTapDetected:(id)sender
{
    NSLog(@"bookmarkTapDetected");
}

- (IBAction)sendTapDetected:(id)sender
{
    NSLog(@"sendTapDetected");
}

-(void)callViewTapDetected
{
    NSLog(@"callViewTapDetected");
}

-(void)menuViewTapDetected
{
    NSLog(@"menuViewTapDetected");
}

-(void)promoViewTapDetected
{
    NSLog(@"promoViewTapDetected");
}

-(void)yelpTapDetected
{
    NSLog(@"yelpTapDetected");
}

-(void)mapTapDetected
{
    NSLog(@"mapTapDetected");
}

-(void)selfTapDetected
{
    NSLog(@"selfTapDetected");
}

-(void)setupPhotos
{
    CGFloat cornerRadius = self.layer.cornerRadius;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.cpMask.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.cpMask.bounds;
    maskLayer.path = maskPath.CGPath;
    self.cpMask.layer.mask = maskLayer;
    self.cpMask.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = self.cpMask.frame;
    visualEffectView.alpha = 0;
//    [self.storeImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.storeImageView.image = [UIImage imageNamed:@"startup7"];
    
    self.callView.layer.cornerRadius = 4;
    self.callView.layer.shadowRadius = 3;
    self.callView.layer.shadowOpacity = 0.2;
    self.callView.layer.shadowOffset = CGSizeMake(1, 1);
    
    self.menuView.layer.cornerRadius = 4;
    self.menuView.layer.shadowRadius = 3;
    self.menuView.layer.shadowOpacity = 0.2;
    self.menuView.layer.shadowOffset = CGSizeMake(1, 1);
    
    self.promoView.layer.cornerRadius = 4;
    self.promoView.layer.shadowRadius = 3;
    self.promoView.layer.shadowOpacity = 0.2;
    self.promoView.layer.shadowOffset = CGSizeMake(1, 1);
}

-(void)titleLabelTap{
    if (self.cardViewDelegate != nil && [self.cardViewDelegate respondsToSelector:@selector(nameTap)]) {
        [self.cardViewDelegate nameTap];
    }
}

-(void)coverPhotoTap{
    if (self.cardViewDelegate != nil && [self.cardViewDelegate respondsToSelector:@selector(coverPhotoTap)]) {
        [self.cardViewDelegate coverPhotoTap];
    }
}

-(void)profilePhotoTap{
    if (self.cardViewDelegate != nil && [self.cardViewDelegate respondsToSelector:@selector(profilePhotoTap)]) {
        [self.cardViewDelegate profilePhotoTap];
    }
}


-(void)addBlur
{
    visualEffectView.alpha = 1;
}

-(void)removeBlur
{
    visualEffectView.alpha = 0;
}


@end
