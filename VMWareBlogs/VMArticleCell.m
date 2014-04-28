//
//  VMTestViewCell.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/16/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation VMArticleCell
@synthesize titleTextView;
@synthesize descriptionTextView;
@synthesize imageView;
@synthesize customBackgroundView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    
    frame.origin.x = 10;
    frame.size.width -= 2 * 10;
    [super setFrame:frame];
    
    // border radius
    [self.customBackgroundView.layer setCornerRadius:5.0f];
    [self.customBackgroundView setBackgroundColor:[UIColor whiteColor]];
    
    // border
//    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
//    [self.layer setBorderWidth:1.5f];
    
    // drop shadow
//    [self.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.layer setShadowOpacity:0.8];
//    [self.layer setShadowRadius:3.0];
//    [self.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.titleTextView.textColor = [UIColor whiteColor];
    [self.descriptionTextView setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.imageView.bounds;
    gradient.colors = [NSArray arrayWithObjects: (id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    
    [self.imageView.layer insertSublayer:gradient atIndex:0];
    
    self.descriptionTextView.scrollEnabled = NO;
    self.descriptionTextView.selectable = NO;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
