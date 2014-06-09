//
//  VMBlogFeedViewController.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AwesomeMenu.h>
#import "VMArticleEntityUpdater.h"

@interface VMBlogFeedViewController : UITableViewController <NSFetchedResultsControllerDelegate, VMArticleEntityUpdaterDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSMutableArray *blogArray;
@property (nonatomic, strong) VMArticleEntityUpdater *updater;

@end
