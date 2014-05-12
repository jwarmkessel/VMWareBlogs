//
//  VMArticleOptions.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMArticleOptions : UIView

@property (nonatomic, assign, getter=isHidden) BOOL isHidden;

- (id)initWithFrame:(CGRect)frame height:(float)height;
- (void)toggleDropDown;
@end
