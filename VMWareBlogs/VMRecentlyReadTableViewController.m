//
//  VMRecentlyReadTableViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/29/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMRecentlyReadTableViewController.h"
#import "VMAppDelegate.h"
#import "Blog.h"
#import "VMArticleViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIImageView+WebCache.h>
#import "NSDate+Helper.h"

@interface VMRecentlyReadTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation VMRecentlyReadTableViewController
@synthesize managedObjectContext;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //[self.tableView setBackgroundColor:[self colorWithHexString:@"696566"]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSError *error;
    self.fetchedResultsController = nil;
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.tableView reloadData];
//    [self.tableView setEditing: YES animated: YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Blog *recentArticle = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    UITextView *titleTextView = (UITextView *)[cell viewWithTag:101];
    titleTextView.editable = NO;
    titleTextView.selectable = NO;
    titleTextView.userInteractionEnabled = NO;

    [titleTextView setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f]];
    titleTextView.text = recentArticle.title;
    [titleTextView setTextColor:[UIColor colorWithHexString:@"696566"]];
    [titleTextView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *authorAndDateLbl = (UILabel *)[cell viewWithTag:102];
    authorAndDateLbl.text = [NSString stringWithFormat:@"%@ - %@", recentArticle.author, recentArticle.pubDate];
    [authorAndDateLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
    [authorAndDateLbl setTextColor:[UIColor colorWithHexString:@"8D8D8D"]];
    [authorAndDateLbl setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:105];
    imageView.alpha = 0;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    /*
     Parameter   	Size             	Dimensions
     xlg	Extra Large	320 x 240
     lg	Large	200 x 150
     sm	Small	100 x 75
     vsm	Very Small	90 x 68
     mcr	Micro	75 x 57
     */
    
    NSString *imageGetter = [NSString stringWithFormat:@"http://images.shrinktheweb.com/xino.php?stwembed=1&stwxmax=100&stwymax=90&stwaccesskeyid=ea6efd2fb0f678a&stwsize=sm&stwurl=%@", recentArticle.guid];
    
    //[[SDImageCache sharedImageCache] removeImageForKey:imageGetter fromDisk:YES];
    
    NSURL *url = [NSURL URLWithString:imageGetter];
    
    [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [UIView animateWithDuration:0.4 animations:^{
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            imageView.alpha = 1;
#pragma clang diagnostic pop
            
            
        } completion:^(BOOL finished) {
            NSLog(@"Image loaded");
        }];
    }];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"RecentArticleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;

}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"shouldIndentWhileEditingRowAtIndexPath");
    return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    // Set allowsMultipleSelectionDuringEditing to YES only while
    // editing. This gives us the golden combination of swipe-to-delete
    // while out of edit mode and multiple selections while in it.
    self.tableView.allowsMultipleSelectionDuringEditing = editing;
    
    [super setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"recentlyReadArticleSeque" sender:self];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(RecentArticleDeleted:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self.managedObjectContext];
        // Delete the row from the data source
        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // handle error
        }

//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                         withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)RecentArticleDeleted:(NSNotification *)notification
{
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"The notification from DELETE changes %@", notification.name);
    
    
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                       withObject:notification
                                                    waitUntilDone:YES];
    
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    VMArticleViewController *vc = (VMArticleViewController *)[segue destinationViewController];
    
    Blog *recentArticle = [_fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    
    NSLog(@"Selecting the link %@", recentArticle.link);
    
    vc.articleURL = recentArticle.link;

}


#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    managedObjectContext = appDelegate.managedObjectContext;
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastRead >= %@", [[NSDate date] beginningOfDay] ];

    fetchRequest.predicate = predicate;
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Blog" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:appDelegate.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        case NSFetchedResultsChangeDelete:
            if(indexPath == NULL) break;
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch((int)type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
