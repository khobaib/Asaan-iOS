//
//  MenuMWCaptionView.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "MenuMWCaptionView.h"

static const CGFloat labelPadding = 10;
static const CGFloat labelGap = 8;
static const CGFloat priceLabelWidth = 85;
static const CGFloat priceLabelHeight = 20;
static const CGFloat likeImageWidth = 25;
static const CGFloat likeImageHeight = 20;
static const CGFloat likeLabelWidth = priceLabelWidth - likeImageWidth - labelGap;
static const CGFloat likeLabelHeight = 16;

@implementation MenuMWCaptionView {

    UILabel *_titleLabel;
    UILabel *_descriptionLabel;
    UILabel *_todaysOrdersLabels;
    UILabel *_likesLabel;
    UIImageView *_likeImageView;
    UILabel *_priceLabel;
    UILabel *_mostOrderedLabel;
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    // **************** Setup Short Description Label **************** //
    _titleLabel.frame = CGRectMake(labelPadding, 0,
                                   self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                   [self calculateHeightOfTextLabel:_titleLabel bound:self.bounds.size].height);
    
    
    
    // **************** Setup Long Description Label **************** //
    _descriptionLabel.frame = CGRectMake(labelPadding, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + labelGap,
                                   self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                   [self calculateHeightOfTextLabel:_descriptionLabel bound:self.bounds.size].height);
    
    
    
    // **************** Setup Today's Orders Label **************** //
    _todaysOrdersLabels.frame = CGRectMake(labelPadding, _descriptionLabel.frame.origin.y + _descriptionLabel.frame.size.height + labelGap,
                                         self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                           [self calculateHeightOfTextLabel:_todaysOrdersLabels bound:self.bounds.size].height);
    
    
    
    // **************** Setup Most Ordered Label **************** //
    _mostOrderedLabel.frame = CGRectMake(labelPadding, _todaysOrdersLabels.frame.origin.y + _todaysOrdersLabels.frame.size.height + labelGap,
                                           self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                           [self calculateHeightOfTextLabel:_mostOrderedLabel bound:self.bounds.size].height);
    
    
    
    // **************** Setup Price Label **************** //
    _priceLabel.frame = CGRectMake(self.bounds.size.width-labelPadding - priceLabelWidth, 0,
                                                                           priceLabelWidth,
                                   priceLabelHeight);
    
    // **************** Setup Like Image **************** //
    _likeImageView.frame = CGRectMake(self.bounds.size.width-labelPadding - priceLabelWidth, _priceLabel.frame.origin.y + _priceLabel.frame.size.height + labelGap * 2,
                                   likeImageWidth,
                                   likeImageHeight);
    
    // **************** Setup Price Label **************** //
    _likesLabel.frame = CGRectMake(self.bounds.size.width-labelPadding - likeLabelWidth, _priceLabel.frame.origin.y + _priceLabel.frame.size.height + labelGap * 2,
                                   likeLabelWidth,
                                   likeLabelHeight);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    
    CGFloat viewHeight = 0;

    // **************** Setup Short Description Label **************** //
    viewHeight += [self calculateHeightOfTextLabel:_titleLabel bound:size].height;
    viewHeight += labelGap;
    
    
    
    // **************** Setup Long Description Label **************** //
    viewHeight += [self calculateHeightOfTextLabel:_descriptionLabel bound:size].height;
    viewHeight += labelGap;
    
    
    
    // **************** Setup Today's OrderLabel Label **************** //
    viewHeight += [self calculateHeightOfTextLabel:_todaysOrdersLabels bound:size].height;
    viewHeight += labelGap;
    
    
    // **************** Setup Most Ordered Label **************** //
    viewHeight += [self calculateHeightOfTextLabel:_mostOrderedLabel bound:size].height;
    
    viewHeight += (labelPadding * 2);
    
    return CGSizeMake(size.width, viewHeight);
}

- (void)setupCaption {
    

    // **************** Setup Short Description Label **************** //
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding, 0,
                                                                      self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                                                      self.bounds.size.height))];
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
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding, 0,
                                                                           self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                                                           self.bounds.size.height))];
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
    _todaysOrdersLabels = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding, 0,
                                                                                 self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                                                                 self.bounds.size.height))];
    _todaysOrdersLabels.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _todaysOrdersLabels.opaque = NO;
    _todaysOrdersLabels.backgroundColor = [UIColor clearColor];
    
    _todaysOrdersLabels.textAlignment = NSTextAlignmentLeft;
    _todaysOrdersLabels.lineBreakMode = NSLineBreakByWordWrapping;
    
    _todaysOrdersLabels.numberOfLines = 0;
    _todaysOrdersLabels.textColor = [UIColor whiteColor];
    _todaysOrdersLabels.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    _todaysOrdersLabels.text = self.textTodaysOrders ? self.textTodaysOrders : @"";
    
    [self addSubview:_todaysOrdersLabels];
    
    
    // **************** Setup Most Ordered Label **************** //
    _mostOrderedLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding, 0,
                                                                                 self.bounds.size.width - labelPadding * 2 - priceLabelWidth - labelGap,
                                                                                 self.bounds.size.height))];
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
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(self.bounds.size.width-labelPadding - priceLabelWidth, 0,
                                                                           priceLabelWidth,
                                                                           priceLabelHeight))];
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
    _likeImageView = [[UIImageView alloc] initWithFrame:CGRectIntegral(CGRectMake(self.bounds.size.width-labelPadding - priceLabelWidth, 0,
                                                                                  likeImageWidth,
                                                                                  likeImageHeight))];
    
    [self addSubview:_likeImageView];
    
    
    // **************** Setup Like Label **************** //
    _likesLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(self.bounds.size.width-labelPadding - likeLabelWidth, 0, likeLabelWidth, likeLabelHeight))];
    _likesLabel.opaque = NO;
    _likesLabel.backgroundColor = [UIColor clearColor];
    
    _likesLabel.textAlignment = NSTextAlignmentRight;
    _likesLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    _likesLabel.numberOfLines = 1;
    _likesLabel.textColor = [UIColor whiteColor];
    _likesLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    _likesLabel.text = self.textPrice ? self.textPrice : @"";
    
    [self addSubview:_likesLabel];
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
#pragma mark === Setter Methods ===
#pragma mark -

- (void)setTextTitle:(NSString *)textTitle {

    _titleLabel.text = textTitle;
}

- (void)setTextDescription:(NSString *)textDescription {

    _descriptionLabel.text = textDescription;
}

- (void)setTextLikes:(NSString *)textLikes {
    
    _likesLabel.text = textLikes;
}

- (void)setTextMostOrdered:(NSString *)textMostOrdered {

    _mostOrderedLabel.text = textMostOrdered;
}

- (void)setTextPrice:(NSString *)textPrice {

    _priceLabel.text = textPrice;
}

- (void)setTextTodaysOrders:(NSString *)textTodaysOrders {

    _todaysOrdersLabels.text = textTodaysOrders;
}

- (void)setImageLike:(UIImage *)imageLike {
    
    _likeImageView.image = imageLike;
}

@end
