//
//  VMBlogFeedViewController.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AwesomeMenu.h>

@interface VMBlogFeedViewController : UITableViewController <NSFetchedResultsControllerDelegate, AwesomeMenuDelegate>

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSMutableArray *blogArray;

@end
