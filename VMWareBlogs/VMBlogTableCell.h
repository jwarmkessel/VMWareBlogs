//
//  VMBlogTableCell.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/20/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMBlogTableCell : UITableViewCell

@property (nonatomic, strong)UITextView *title;
@property (nonatomic, strong)UILabel *descr;
@property (nonatomic, strong)UILabel *order;
@property (nonatomic, strong)NSString *reuseID;
@property (nonatomic, strong)UIImageView *rssImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

