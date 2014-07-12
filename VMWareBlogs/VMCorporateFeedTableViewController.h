//
//  VMCorporateFeedTableViewController.h
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 7/11/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMCorporateSynchronousFeedUpdater.h"

@interface VMCorporateFeedTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, VMCorporateSynchronousFeedUpdaterDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end
