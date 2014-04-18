//
//  VMTestViewCell.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/16/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleCell.h"

@implementation VMArticleCell
@synthesize titleTextView;
@synthesize descriptionLbl;
@synthesize imageView;

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
        
    self.backgroundColor = [UIColor whiteColor];
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
