//
//  VMCorpBlogViewController.m
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 8/18/15.
//  Copyright (c) 2015 Justin Warmkessel. All rights reserved.
//

#import "VMCorpBlogViewController.h"

@interface VMCorpBlogViewController ()

@end

@implementation VMCorpBlogViewController

- (void)viewDidLoad
{
    self.internalBlog = @(1);

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        
        UIImage *backgroundImage = [UIImage imageNamed:@"VMware_logo_88.png"];
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    [self.tableView reloadData];
}

@end
