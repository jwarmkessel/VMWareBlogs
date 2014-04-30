//
//  VMRecentlyReadTableViewController.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/29/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMRecentlyReadTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end
