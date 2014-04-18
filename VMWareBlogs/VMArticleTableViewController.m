//
//  VMArticleTableViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/16/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleTableViewController.h"
#import "VMArticleCell.h"
#import "VMAppDelegate.h"
#import "Blog.h"
#import "VMArticleViewController.h"
#import "VMMasterViewController.h"

#import "VMWareBlogsAPI.h"
#import "VMArticleEntityUpdater.h"

@interface VMArticleTableViewController ()

@end

@implementation VMArticleTableViewController{
    int currentSelection;
}

@synthesize listViewList;
@synthesize fetchedResultsController;
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
    
    //Set the current selection
    currentSelection = -1;
    
    [self.tableView setBackgroundColor:[self colorWithHexString:@"133AAC"]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //self.listViewList = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", nil];
    
    NSError *error;
    self.fetchedResultsController = nil;
    
    NSLog(@"Perform fetch");
    if (![[self fetchResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
//    VMArticleEntityUpdater *updater = [[VMArticleEntityUpdater alloc] init];
//    [updater updateList];
    
    
//    _backgroundQueue = dispatch_queue_create("com.vmwareblogs.articleupdater.bgqueue", NULL);
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:@"UIApplicationWillResignActiveNotification" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
    


}

- (void)viewWillAppear:(BOOL)animated {
    
    UINavigationBar *navBar = [[self navigationController] navigationBar];
    UIImage *backgroundImage = [UIImage imageNamed:@"navBarLogoNoStatusBar.png"];
    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    //Set the update flag to no update being made.
//    self.updateFlag = NO;
    
//    [self.tableView reloadData];
    
    //    [self performSelectorInBackground:@selector(updateList:) withObject:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Stop the blog update;
//    [_updateBlogListTimer invalidate];
    
//    VMArticleViewController *vc = [segue destinationViewController];
//    
//    Blog *blog = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
//    
//    NSLog(@"Selecting the link %@", blog.link);
//    vc.articleURL = blog.link;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == currentSelection) {
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        Blog *article = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        
        float xPos = 0;
        float yPos = 0;
        
        NSArray *visibleCells = [self.tableView visibleCells];
        for (VMArticleCell* cel in visibleCells) {
            
            if(cel.titleTextView.text == article.title) {
                xPos = cel.frame.origin.x;
                yPos = cel.frame.origin.y;
                
                break;
            }
            
            
            NSLog(@"cell : %@ \n\n",cel.textLabel.text);
            
            
        }
        
        UIView *test = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, 200, 200)];
        
        [test setBackgroundColor:[UIColor whiteColor]];
        [self.tableView addSubview:test];
        
        [UIView animateWithDuration:2 animations:^{
            test.layer.frame = CGRectMake(0,0,320,568);
        }];
        
        return  568;
    }
    
    return 200;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"------------------- >NUMBER OF ROWS %lu", (unsigned long)[sectionInfo numberOfObjects]);
    
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    VMArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[VMArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

// Customize the appearance of table view cells.
- (void)configureCell:(VMArticleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    NSLog(@"Configuring Cell");
    Blog *blog = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
    //Set the title and configure.
    cell.titleTextView.text = blog.title;
    [cell.titleTextView setUserInteractionEnabled:NO];
    [cell.titleTextView setFont:[UIFont fontWithName:@"Arial" size:15.0f]];
    cell.titleTextView.textColor = [self colorWithHexString:@"343A43"];
    
    cell.descriptionLbl.text = blog.descr;
    [cell.descriptionLbl setFont:[UIFont fontWithName:@"Arial" size:12.0f]];
    
    cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"articleSegue" sender:self];
    int row = [indexPath row];
    currentSelection = row;
    [tableView beginUpdates];
    [tableView endUpdates];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchResultsController {
    NSLog(@"FetchedResultsController");
    
    if (self.fetchedResultsController != nil) {
        NSLog(@"FetchedResultsController is not equal to NIL");
        return self.fetchedResultsController;
    }
    
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    managedObjectContext = appDelegate.managedObjectContext;
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSLog(@"alloc FetchedResultsController");
    //Retrieve the entity description
    
    NSLog(@"get blog entity");
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Blog" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSLog(@"Create and initialize the fetch results controller.");
    // Create and initialize the fetch results controller.
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:appDelegate.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:@"Root"];
    
    self.fetchedResultsController.delegate = self;
    
    return self.fetchedResultsController;
}


/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerWillChangeContent");
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    
    
    [self.tableView beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"didChangeObject");
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            NSLog(@"Inserting");
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"Deleting");
            NSLog(@"indexpath %@", indexPath);
            if(indexPath == NULL) break;
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"Results Change Update");
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"Move?");
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSLog(@"didChangeSection");
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerDidChangeContent");
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    [self.tableView endUpdates];
    
}

//TODO interesting category test candidate.
-(UIColor*)colorWithHexString:(NSString*)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
