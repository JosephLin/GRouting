//
//  GRAnnotationView.m
//  GRouting
//
//  Created by Joseph Lin on 9/7/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "GRAnnotationView.h"
#import "GRAnnotation.h"
#import "UIColor+Utilities.h"

static CGRect kContentRect = {5, 0, 20, 20};


@interface GRAnnotationView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end



@implementation GRAnnotationView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];

    self.titleLabel.frame = CGRectInset(kContentRect, 2, 2);
    [self addSubview:self.titleLabel];
    
    if ([self.annotation isKindOfClass:[GRAnnotation class]])
    {
        GRAnnotation* theAnnotation = self.annotation;
        self.titleLabel.text = theAnnotation.symbol;
        
        [self setNeedsDisplay];
    }
}

- (UILabel*)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.2;
    }
    return _titleLabel;
}

- (void)drawRect:(CGRect)rect
{
    [self.image drawInRect:rect];
    
    if ([self.annotation isKindOfClass:[GRAnnotation class]])
    {
        GRAnnotation* theAnnotation = self.annotation;
        
        if (theAnnotation.symbolColorCode)
        {
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            UIColor* color = [UIColor colorFromHexString:theAnnotation.symbolColorCode];
            [color setFill];

            CGRect circleRect = CGRectInset(kContentRect, 2, 2);
            CGContextFillEllipseInRect(context, circleRect);            
        }
    }
}

//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        [[NSBundle mainBundle] loadNibNamed:@"GRAnnotationView" owner:self options:nil];
//        [self addSubview:self.view];
//    }
//    return self;
//}
//
//- (void) awakeFromNib
//{
//    [super awakeFromNib];
//    
//    [[NSBundle mainBundle] loadNibNamed:@"GRAnnotationView" owner:self options:nil];
//    [self addSubview:self.view];
//}



@end
