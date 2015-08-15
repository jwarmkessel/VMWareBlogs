//
//  VMTabBarController.m
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 8/14/15.
//  Copyright (c) 2015 Justin Warmkessel. All rights reserved.
//

#import "VMTabBarController.h"

static const float kTabBarHeight = 35;

@implementation VMTabBarController

- (void)viewWillLayoutSubviews
{
    CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
    tabFrame.size.height = kTabBarHeight;
    tabFrame.origin.y = self.view.frame.size.height - kTabBarHeight;
    self.tabBar.frame = tabFrame;
}

@end
