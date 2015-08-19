//
//  VMBlogFeedViewController.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VMSynchronousFeedUpdater.h"

@interface VMBlogFeedViewController : UITableViewController <NSFetchedResultsControllerDelegate, VMSynchronousFeedUpdaterDelegate, UISearchBarDelegate>

@property (nonatomic, strong)   NSManagedObjectContext* managedObjectContext;
@property (nonatomic)           NSNumber*               internalBlog;

@end
