//
//  CardView.h
//  Savoir
//
//  Created by Nirav Saraiya on 5/15/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "DraggableView.h"

@protocol CardViewDelegate <NSObject>
@optional
- (void)nameTap;
- (void)coverPhotoTap;
- (void)profilePhotoTap;
@end

@interface CardView : DraggableView

@property (nonatomic, weak) IBOutlet id<CardViewDelegate> cardViewDelegate;

- (void)addBlur;
- (void)removeBlur;
- (void)addShadow;
- (void)removeShadow;

- (void)setupViewWithDelegate:(id<CardViewDelegate, DraggableViewDelegate>)delegate AndTitle:(NSString *)strTitle;


@end
