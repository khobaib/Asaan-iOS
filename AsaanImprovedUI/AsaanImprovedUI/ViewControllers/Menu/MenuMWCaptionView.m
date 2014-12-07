//
//  MenuMWCaptionView.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MenuMWCaptionView.h"

#import "UIColor+AsaanGoldColor.h"

#define trim(string) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
#define enableLabel(label, title, enable) if (title && ![title isEqualToString:@""]) {  label.text = title; enable = YES; }

static const CGFloat labelPadding = 10;
static const CGFloat labelGap = 8;
static const CGFloat priceLabelWidth = 85;
static const CGFloat priceLabelHeight = 20;
static const CGFloat likeImageWidth = 25;
static const CGFloat likeImageHeight = 20;
static const CGFloat likeLabelWidth = priceLabelWidth - likeImageWidth - labelGap;
static const CGFloat likeLabelHeight = 16;
static const CGFloat orderButtonHeight = 30;

@interface MenuMWCaptionView () <UIGestureRecognizerDelegate>

@end

@implementation MenuMWCaptionView {
    
    UILabel *_titleLabel;
    UILabel *_descriptionLabel;
    UILabel *_todaysOrdersLabel;
    UILabel *_likesLabel;
    UIImageView *_likeImageView;
    UILabel *_priceLabel;
    UILabel *_mostOrderedLabel;
    UIButton *_orderButton;
    
    BOOL _enabledTitleLabel;
    BOOL _enabledDescriptionLabel;
    BOOL _enabledTodaysOrdersLabel;
    BOOL _enabledLikesLabel;
    BOOL _enabledLikeImageView;
    BOOL _enabledPriceLabel;
    BOOL _enabledMostOrderedLabel;
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    // **************** Setup Short Description Label **************** //
    if (_enabledTitleLabel) {
        _titleLabel.frame = CGRectMake(labelPadding, 0,
                                       self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                       [self calculateHeightOfTextLabel:_titleLabel bound:self.bounds.size].height);
    }
    else {
        [_titleLabel removeFromSuperview];
    }
    
    
    
    // **************** Setup Long Description Label **************** //
    if (_enabledDescriptionLabel) {
        _descriptionLabel.frame = CGRectMake(labelPadding, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + labelGap,
                                             self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                             [self calculateHeightOfTextLabel:_descriptionLabel bound:self.bounds.size].height);
    }
    else {
        [_descriptionLabel removeFromSuperview];
    }
    
    
    
    // **************** Setup Today's Orders Label **************** //
    if (_enabledTodaysOrdersLabel) {
        _todaysOrdersLabel.frame = CGRectMake(labelPadding, _descriptionLabel.frame.origin.y + _descriptionLabel.frame.size.height + labelGap,
                                              self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                              [self calculateHeightOfTextLabel:_todaysOrdersLabel bound:self.bounds.size].height);
    }
    else {
        [_todaysOrdersLabel removeFromSuperview];
    }
    
    
    
    // **************** Setup Most Ordered Label **************** //
    if (_enabledMostOrderedLabel) {
        _mostOrderedLabel.frame = CGRectMake(labelPadding, _todaysOrdersLabel.frame.origin.y + _todaysOrdersLabel.frame.size.height + labelGap,
                                             self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                             [self calculateHeightOfTextLabel:_mostOrderedLabel bound:self.bounds.size].height);
    }
    else {
        [_mostOrderedLabel removeFromSuperview];
    }
    
    
    
    // **************** Setup Order Button **************** //
    if (self.enabledOrderButton) {
        _orderButton.frame = CGRectMake(labelPadding, _mostOrderedLabel.frame.origin.y + _mostOrderedLabel.frame.size.height + labelGap,
                                        self.bounds.size.width - labelPadding * 2,
                                        orderButtonHeight);
    }
    else {
        [_orderButton removeFromSuperview];
    }
    
    
    // **************** Setup Price Label **************** //
    if (_enabledPriceLabel) {
        _priceLabel.frame = CGRectMake(self.bounds.size.width-labelPadding - priceLabelWidth, 0,
                                       priceLabelWidth,
                                       priceLabelHeight);
    }
    else {
        [_priceLabel removeFromSuperview];
    }
    
    // **************** Setup Like Image **************** //
    if (_enabledLikeImageView) {
        _likeImageView.frame = CGRectMake(self.bounds.size.width-labelPadding - priceLabelWidth, _priceLabel.frame.origin.y + _priceLabel.frame.size.height + labelGap * 2,
                                          likeImageWidth,
                                          likeImageHeight);
    }
    else {
        [_likeImageView removeFromSuperview];
    }
    
    // **************** Setup Price Label **************** //
    if (_enabledLikesLabel) {
        _likesLabel.frame = CGRectMake(self.bounds.size.width-labelPadding - likeLabelWidth, _priceLabel.frame.origin.y + _priceLabel.frame.size.height + labelGap * 2,
                                       likeLabelWidth,
                                       likeLabelHeight);
    }
    else {
        [_likesLabel removeFromSuperview];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    
    CGFloat col1ViewHeight = 0;

    // **************** Setup Short Description Label **************** //
    if (_enabledTitleLabel) {
        col1ViewHeight += [self calculateHeightOfTextLabel:_titleLabel bound:size].height;
        col1ViewHeight += labelGap;
    }
    
    
    
    // **************** Setup Long Description Label **************** //
    if (_enabledDescriptionLabel) {
        col1ViewHeight += [self calculateHeightOfTextLabel:_descriptionLabel bound:size].height;
        col1ViewHeight += labelGap;
    }
    
    
    
    // **************** Setup Today's OrderLabel Label **************** //
    if (_enabledTodaysOrdersLabel) {
        col1ViewHeight += [self calculateHeightOfTextLabel:_todaysOrdersLabel bound:size].height;
        col1ViewHeight += labelGap;
    }
    
    
    // **************** Setup Most Ordered Label **************** //
    if (_enabledMostOrderedLabel) {
        col1ViewHeight += [self calculateHeightOfTextLabel:_mostOrderedLabel bound:size].height;
    }
    
    
    // **************** Setup Order Button **************** //
    if (self.enabledOrderButton) {
        
        col1ViewHeight += labelGap;
        col1ViewHeight += orderButtonHeight;
    }
    
    col1ViewHeight += (labelPadding * 2);
    
    
    CGFloat col2ViewHeight = 0;
    if (_enabledPriceLabel) {
        
        col2ViewHeight += [self calculateHeightOfTextLabel:_priceLabel bound:size].height;
        col2ViewHeight += labelGap;
    }
    
    if (_enabledLikesLabel || _enabledLikeImageView) {
        col2ViewHeight += labelGap;
        col2ViewHeight += [self calculateHeightOfTextLabel:_likesLabel bound:size].height;
    }
    
    col2ViewHeight += (labelPadding * 2);
    
    return CGSizeMake(size.width, col1ViewHeight > col2ViewHeight ? col1ViewHeight : col2ViewHeight);
}

- (void)setupCaption {
    
    self.userInteractionEnabled = YES;
    

    // **************** Setup Short Description Label **************** //
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _titleLabel.opaque = NO;
    _titleLabel.backgroundColor = [UIColor clearColor];
    
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    _titleLabel.text = self.textTitle ? self.textTitle : @"";
    
    [self addSubview:_titleLabel];
    
    
    // **************** Setup Long Description Label **************** //
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _descriptionLabel.opaque = NO;
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    
    _descriptionLabel.textAlignment = NSTextAlignmentLeft;
    _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.textColor = [UIColor whiteColor];
    _descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    _descriptionLabel.text = self.textDescription ? self.textDescription : @"";
    
    [self addSubview:_descriptionLabel];
    
    
    // **************** Setup Today's OrderLabel Label **************** //
    _todaysOrdersLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _todaysOrdersLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _todaysOrdersLabel.opaque = NO;
    _todaysOrdersLabel.backgroundColor = [UIColor clearColor];
    
    _todaysOrdersLabel.textAlignment = NSTextAlignmentLeft;
    _todaysOrdersLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    _todaysOrdersLabel.numberOfLines = 0;
    _todaysOrdersLabel.textColor = [UIColor whiteColor];
    _todaysOrdersLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    _todaysOrdersLabel.text = self.textTodaysOrders ? self.textTodaysOrders : @"";
    
    [self addSubview:_todaysOrdersLabel];
    
    
    // **************** Setup Most Ordered Label **************** //
    _mostOrderedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _mostOrderedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _mostOrderedLabel.opaque = NO;
    _mostOrderedLabel.backgroundColor = [UIColor clearColor];
    
    _mostOrderedLabel.textAlignment = NSTextAlignmentLeft;
    _mostOrderedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    _mostOrderedLabel.numberOfLines = 0;
    _mostOrderedLabel.textColor = [UIColor whiteColor];
    _mostOrderedLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    
    _mostOrderedLabel.text = self.textMostOrdered ? self.textMostOrdered : @"";
    
    [self addSubview:_mostOrderedLabel];
    
    
    // **************** Setup Price Label **************** //
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLabel.opaque = NO;
    _priceLabel.backgroundColor = [UIColor clearColor];
    
    _priceLabel.textAlignment = NSTextAlignmentRight;
    _priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    _priceLabel.numberOfLines = 1;
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    _priceLabel.text = self.textPrice ? self.textPrice : @"";
    
    [self addSubview:_priceLabel];
    
    
    // **************** Setup Like ImageView **************** //
    _likeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:_likeImageView];
    
    
    // **************** Setup Like Label **************** //
    _likesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _likesLabel.opaque = NO;
    _likesLabel.backgroundColor = [UIColor clearColor];
    
    _likesLabel.textAlignment = NSTextAlignmentRight;
    _likesLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    _likesLabel.numberOfLines = 1;
    _likesLabel.textColor = [UIColor whiteColor];
    _likesLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    _likesLabel.text = self.textPrice ? self.textPrice : @"";
    
    [self addSubview:_likesLabel];
    
    
    // **************** Setup Order Button **************** //
    _orderButton = [[UIButton alloc] initWithFrame:CGRectZero];
    
    _orderButton.opaque = NO;
    _orderButton.backgroundColor = [UIColor clearColor];
    [_orderButton setTitle:@"Add to Order" forState:UIControlStateNormal];
    [_orderButton setTitleColor:[UIColor goldColor] forState:UIControlStateNormal];
    [_orderButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_orderButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [_orderButton addTarget:self action:@selector(tappedOrderButton:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *layer = _orderButton.layer;
    layer.borderColor = [UIColor goldColor].CGColor;
    layer.borderWidth = 2;
    layer.cornerRadius = 5;
    
    [self addSubview:_orderButton];
}

#pragma mark -
#pragma mark === Private Methods ===
#pragma mark -

- (CGSize)calculateHeightOfTextLabel:(UILabel *)label bound:(CGSize)size {
    
    CGFloat maxHeight = 9999;
    if (label.numberOfLines > 0)
        maxHeight = _titleLabel.font.lineHeight * _titleLabel.numberOfLines;

    CGSize textSize;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        textSize = [label.text boundingRectWithSize:CGSizeMake(size.width - labelPadding * 2, maxHeight)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:label.font}
                                                          context:nil
                    ].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        textSize = [label.text sizeWithFont:label.font
                                        constrainedToSize:CGSizeMake(size.width - labelPadding * 2, maxHeight)
                                            lineBreakMode:label.lineBreakMode];
#pragma clang diagnostic pop
    }
    
    return textSize;
}

#pragma mark -
#pragma mark === Actions ===
#pragma mark -

- (IBAction)tappedOrderButton:(id)sender
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuMWCaptionView:didClickedOrderButtonAtIndex:)]) {
        [self.delegate menuMWCaptionView:self didClickedOrderButtonAtIndex:self.index];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuMWCaptionView:didClickedOrderButton:)]) {
        [self.delegate menuMWCaptionView:self didClickedOrderButton:sender];
    }
}

#pragma mark -
#pragma mark === Setter Methods ===
#pragma mark -

- (void)setTextTitle:(NSString *)textTitle {
    
    enableLabel(_titleLabel, trim(textTitle), _enabledTitleLabel);
}

- (void)setTextDescription:(NSString *)textDescription {

    enableLabel(_descriptionLabel, trim(textDescription), _enabledDescriptionLabel);
}

- (void)setTextLikes:(NSString *)textLikes {
    
    enableLabel(_likesLabel, trim(textLikes), _enabledLikesLabel);
}

- (void)setTextMostOrdered:(NSString *)textMostOrdered {

    enableLabel(_mostOrderedLabel, trim(textMostOrdered), _enabledMostOrderedLabel);
}

- (void)setTextPrice:(NSString *)textPrice {

    enableLabel(_priceLabel, trim(textPrice), _enabledPriceLabel);
}

- (void)setTextTodaysOrders:(NSString *)textTodaysOrders {

    enableLabel(_todaysOrdersLabel, trim(textTodaysOrders), _enabledTodaysOrdersLabel);
}

- (void)setImageLike:(UIImage *)imageLike {
    
    if (imageLike) {
        _enabledLikeImageView = YES;
        _likeImageView.image = imageLike;
    }
    
}

@end
