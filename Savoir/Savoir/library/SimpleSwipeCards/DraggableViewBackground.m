//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"

@implementation DraggableViewBackground{
    NSInteger maxCardsIndex; //%%% Total number of available cards;
    NSInteger currentCardIndex; //%%% Index of the current card;
    CardView *prevCard;
    CardView *currCard;
    CardView *nextCard;
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
    maxCardsIndex = 4;
    currentCardIndex = 0;
    prevCard = nil;
    nextCard = [self createDraggableView:@"1"];
    currCard = [self createDraggableView:@"0"];
    currCard.hidden = false;
}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(CardView *)createDraggableView:(NSString *)strTitle
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
//    float width = CGRectGetWidth(self.frame);
//    float height = CGRectGetHeight(self.frame);

    CardView *draggableView = [[[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self.parentViewController options:nil] objectAtIndex:0];
    [draggableView setupViewWithDelegate:self AndTitle:strTitle];
//    [draggableView setup];
    if (currCard != nil)
        [self insertSubview:draggableView belowSubview:currCard];
    else
        [self addSubview:draggableView];
    [draggableView setTranslatesAutoresizingMaskIntoConstraints:false];
    
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20.f];
    
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-20.f];
    
    NSLayoutConstraint *topHorizontal = [NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.f];
    
    NSLayoutConstraint *bottomVertical = [NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-20.f];
    
    [self addConstraints:@[leadingConstraint, trailingConstraint, topHorizontal, bottomVertical]];
    
    //    [cardView addBlur];
    [draggableView addShadow];
    [draggableView setNeedsDisplay];
    
    draggableView.hidden = true;

    return draggableView;
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateActionLeft:(UIView *)card
{
    prevCard.hidden=false;
    nextCard.hidden=true;
}
-(void)updateActionRight:(UIView *)card
{
    prevCard.hidden=true;
    nextCard.hidden=false;
}
-(Boolean)canPerformSwipeLeft
{
    if (currentCardIndex != 0)
        return YES;
    else
        return NO;
}
-(Boolean)canPerformSwipeRight
{
    if (currentCardIndex != maxCardsIndex - 1)
        return YES;
    else
        return NO;
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    currCard = prevCard;
    currentCardIndex -= 1;
    nextCard.hidden = true;
    [nextCard removeFromSuperview];
    nextCard = [self createDraggableView:[NSString stringWithFormat:@"%ld", currentCardIndex + 1]];
    
    if (currentCardIndex > 0)
        prevCard = [self createDraggableView:[NSString stringWithFormat:@"%ld", currentCardIndex - 1]];
    else
        prevCard = nil;
}

#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    currCard = nextCard;
    currentCardIndex += 1;
    prevCard.hidden = true;
    [prevCard removeFromSuperview];
    prevCard = [self createDraggableView:[NSString stringWithFormat:@"%ld", currentCardIndex - 1]];
    
    if (currentCardIndex < maxCardsIndex-1)
        nextCard = [self createDraggableView:[NSString stringWithFormat:@"%ld", currentCardIndex + 1]];
    else
        nextCard = nil;
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
}

@end
