//
//  VMBlogTableCell.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/20/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMBlogTableCell.h"

@implementation VMBlogTableCell

@synthesize title, descr, order, rssImage, reuseID;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        reuseID = reuseIdentifier;
        
        //First the order
        order = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 10.0f, 255.0f, 50.0f)];
        [title setTextColor:[UIColor grayColor]];
        
        title = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, 200.0f, 80.0f)];
        [title setTextColor:[UIColor blackColor]];
        
        descr = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 100.0f, 255.0f, 50.0f)];
        [descr setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
        
        [self.contentView addSubview:order];
        [self.contentView addSubview:title];
        [self.contentView addSubview:descr];
        
        rssImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 51.0f, 320.0f, 148.0f)];
        
        [self.contentView addSubview:title];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
