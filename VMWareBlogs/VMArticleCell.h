//
//  VMArticleCell.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/16/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMArticleCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *customBackgroundView;
@property (strong, nonatomic) IBOutlet UITextView *titleTextView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end
