//
//  VMArticleTableViewController.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/16/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VMArticleTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSMutableArray *listViewList;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end
