//
//  VMCorporateFeedTableViewController.m
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 7/11/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMCorporateFeedTableViewController.h"
#import "VMAppDelegate.h"
#import "CorporateArticle.h"
#import "RecentArticle.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "VMArticleViewController.h"
#import "VMSectionHeaderView.h"
#import "VMCorporateSynchronousFeedUpdater.h"

@interface VMCorporateFeedTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (atomic, strong) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSMutableArray *filteredTableData;
@property (assign, getter = isFilteredList) BOOL filteredList;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UITapGestureRecognizer *scrollToTopTap;
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) VMCorporateSynchronousFeedUpdater *synchronousFeedUpdater;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation VMCorporateFeedTableViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize loadingView = _loadingView;
@synthesize moc = _moc;
@synthesize filteredTableData = _filteredTableData;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize synchronousFeedUpdater = _synchronousFeedUpdater;

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
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.searchBar setDelegate:self];
    //    self.updater = [[VMArticleEntityUpdater alloc] init];
    //    [self.updater setDelegate:self];
    
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.SynchronousFeedUpdater = [[VMCorporateSynchronousFeedUpdater alloc] initWithManagedObjectContext:self.managedObjectContext];
    [self.synchronousFeedUpdater setDelegate:self];
    [self.fetchedResultsController setDelegate:self];
    
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width, self.tableView.frame.size.height)];
    
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    
    self.filteredList = NO;
    
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"696566"]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithHexString:@"346633"]];
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithHexString:@"346633"]];
    
    NSError *error;
    self.fetchedResultsController = nil;
    
    NSLog(@"Perform fetch");
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        //TODO
        abort();
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    //Notification of special events.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:@"UIApplicationWillResignActiveNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                            selector:@selector(mergeChanges:)
    //                                                name:NSManagedObjectContextDidSaveNotification
    //                                              object:(self.managedObjectContext)];
    
    //Dismiss the keyboard if it's present.
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:self.tap];
    [self.tap setEnabled:NO];
    
    //Scroll to the top on single tap to the navigatio bar.
    self.scrollToTopTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(scrollToTopTapHander)];
    [self.navigationController.navigationBar addGestureRecognizer:self.scrollToTopTap];
    
    //Change keyboard Search button to Done button.
    for(UIView *subView in [self.searchBar subviews]) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subView setReturnKeyType: UIReturnKeyDone];
        } else {
            for(UIView *subSubView in [subView subviews]) {
                if([subSubView conformsToProtocol:@protocol(UITextInputTraits)]) {
                    [(UITextField *)subSubView setReturnKeyType: UIReturnKeyDone];
                }
            }      
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
//    UINavigationBar *navBar = [[self navigationController] navigationBar];
//    UIImage *backgroundImage = [UIImage imageNamed:@"navBarLogoNoStatusBar.png"];
//    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.scrollToTopTap setEnabled:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"view will disappear");
}

- (void)viewDidUnload {
    
    // Release any properties that are loaded in viewDidLoad or can be recreated lazily.
    self.fetchedResultsController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - corporateFeedUpdaterDelegate

- (void)corporateFeedUpdaterDidFinishUpdating {
    [UIView animateWithDuration:0.3 animations:^{
        [self.loadingView setAlpha:0.0];
    }completion:^(BOOL finished) {
        [self.loadingView removeFromSuperview];
        [self.tableView setUserInteractionEnabled:YES];
        
        //[self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)corporateFeedUpdaterDidError {
    [UIView animateWithDuration:0.3 animations:^{
        [self.loadingView setAlpha:0.0];
    }];
    [self.loadingView removeFromSuperview];
    [self.tableView setUserInteractionEnabled:YES];
    [self.refreshControl endRefreshing];
}

#pragma mark - 

- (void)mergeChanges:(NSNotification *)notification{
    // Merge changes into the default context on the main thread
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                withObject:notification
                                             waitUntilDone:YES];
}

#pragma mark - 

- (void)refreshTable:(id)sender {
    
    [self.refreshControl beginRefreshing];
    
    NSLog(@"Refreshing Table Data");
    
    [self.tableView setUserInteractionEnabled:NO];
    [self.loadingView setBackgroundColor:[UIColor blackColor]];
    [self.loadingView setAlpha:0];
    [self.view addSubview:self.loadingView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_loadingView setAlpha:0.3];
    }completion:^(BOOL finished) {
        self.searchBar.text = @"";
        [self setFilteredList:NO];

        [self.synchronousFeedUpdater updateList];
    }];
}

#pragma mark - 

- (void)scrollToTopTapHander {
    NSLog(@"Scoll to tap");
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}
- (void)dismissKeyboard {
    // add self
    [self.searchBar resignFirstResponder];
}

#pragma mark - 

- (void)appWillEnterForeground:(id)sender {
    if([self isKindOfClass:[VMCorporateFeedTableViewController class]]) {
        NSLog(@"App is entering foreground from Blog feed");
    }
}

- (void)appWillEnterBackground:(id)sender {
    if([self isKindOfClass:[VMCorporateFeedTableViewController class]]) {
        NSLog(@"App is entering background from Blog feed");
    }
}

- (void)appWillTerminate:(id)sender {
    if([self isKindOfClass:[VMCorporateFeedTableViewController class]]) {
        NSLog(@"App will terminate from Blog feed");
    }
}

// Whatever method you registered as an observer to NSManagedObjectContextDidSave
- (void)contextDidSave:(NSNotification *)notification {
    NSLog(@"contextDidSave");
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                withObject:notification
                                             waitUntilDone:YES];
}

- (void)updateList:(id)sender {
    NSLog(@"Update Core Manager");
    
    //[self.updater updateList];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    [self.scrollToTopTap setEnabled:NO];
    
    NSManagedObjectContext *tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [tempContext performBlock:^{
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(RecentArticleSaved:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:tempContext];
        
        VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        CorporateArticle *blog;
        
        if(![self isFilteredList]) {
            blog = [_fetchedResultsController objectAtIndexPath:indexPath];
        } else {
            blog = [self.filteredTableData objectAtIndex:indexPath.row];
        }
        
        NSError *temporaryMOCError;
        
        NSPersistentStoreCoordinator *coordinator = [appDelegate persistentStoreCoordinator];
        
        [tempContext setPersistentStoreCoordinator:coordinator];
        //Retrieve the entity description
        RecentArticle *recentArticle;
        
        //Check if entity already exists.
        //Retrieve the entity description
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"RecentArticle" inManagedObjectContext:tempContext];
        
        // Create and configure a fetch request with the Book entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSError *fetchRequestError;
        
        [fetchRequest setReturnsObjectsAsFaults:NO];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"guid = %@", blog.guid]];
        [fetchRequest setFetchLimit:1];
        NSArray *recentlyReadArticle = [tempContext executeFetchRequest:fetchRequest error:&fetchRequestError];
        
        if([recentlyReadArticle count] == 0) {
            //Create an instance of the entity and save.
            recentArticle = [NSEntityDescription insertNewObjectForEntityForName:@"RecentArticle"
                                                          inManagedObjectContext:tempContext];
            
            [recentArticle setValue:blog.link forKey:@"link"];
            [recentArticle setValue:blog.title forKey:@"title"];
            [recentArticle setValue:blog.descr forKey:@"descr"];
            [recentArticle setValue:blog.order forKey:@"order"];
            
            [recentArticle setValue:blog.author forKey:@"author"];
            [recentArticle setValue:blog.guid forKey:@"guid"];
            [recentArticle setValue:blog.pubDate forKey:@"pubDate"];
            
            NSLog(@"Saving to recently read");
            if (![tempContext save:&temporaryMOCError]) {
                NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                
            }
            
            // save parent to disk asynchronously
            [appDelegate.managedObjectContext performBlock:^{
                NSLog(@"Perform save to the parent context");
                
                NSError *error;
                if (![appDelegate.managedObjectContext save:&error])
                {
                    // handle error
                }
            }];
            
            [tempContext refreshObject:recentArticle mergeChanges:YES];
        }
    }];
    
    [self performSegueWithIdentifier:@"corporateArticleSegue" sender:self];
}

- (void)RecentArticleSaved:(NSNotification *)notification {
    NSLog(@"Recent Article Saved Notification");
    
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                       withObject:notification
                                                    waitUntilDone:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    if (section == 0) {
        [headerView setBackgroundColor:[UIColor colorWithHexString:@"346633"]];
        UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0, self.tableView.bounds.size.width, 21.5)];
        [sectionTitle setFont:[UIFont fontWithName:@"ArialMT" size:13]];
        sectionTitle.text = @"The Latest Posts From VMware Corporate";
        sectionTitle.textColor = [UIColor whiteColor];
        [headerView addSubview: sectionTitle];
    }
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"Number of sections %lu", (unsigned long)[[_fetchedResultsController sections] count]);
    return [[_fetchedResultsController sections] count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 210;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(![self isFilteredList]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        NSLog(@"Blog TableView Count: %lu", (unsigned long)[sectionInfo numberOfObjects]);
        
        return [sectionInfo numberOfObjects];
        
    } else {
        return [self.filteredTableData count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
     CorporateArticle *blog;
    
    if(![self isFilteredList]) {
        blog = [_fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        blog = [self.filteredTableData objectAtIndex:indexPath.row];
    }
    
#if DEBUGGER
    UILabel *syncStatus = (UILabel *)[cell viewWithTag:150];
    syncStatus.text = [NSString stringWithFormat:@"%@", blog.order];
#endif
    
    //NSLog(@"GUID: %@", blog.guid);
    UILabel *orderLbl = (UILabel *)[cell viewWithTag:100];
    [orderLbl setFont:[UIFont fontWithName:@"futura" size:20]];
    
    UITextField *titleLbl = (UITextField *)[cell viewWithTag:101];
    [titleLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    titleLbl.textColor = [UIColor colorWithHexString:@"696566"];
    [titleLbl setUserInteractionEnabled:NO];
    titleLbl.text = @"text";
    [titleLbl setBackgroundColor:[UIColor clearColor]];
    
    UITextView *descLbl = (UITextView *)[cell viewWithTag:102];
    [descLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
    descLbl.textColor = [UIColor colorWithHexString:@"8D8D8D"];
    descLbl.userInteractionEnabled = NO;
    
    UILabel *dateLbl = (UILabel *)[cell viewWithTag:104];
    [dateLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    dateLbl.textColor = [UIColor colorWithHexString:@"BBBBBB"];
    [dateLbl setBackgroundColor:[UIColor clearColor]];
    
    UILabel *authorLbl = (UILabel *)[cell viewWithTag:105];
    [authorLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    authorLbl.textColor = [UIColor colorWithHexString:@"8D8D8D"];
    [authorLbl setTextAlignment:NSTextAlignmentRight];
    [authorLbl setBackgroundColor:[UIColor clearColor]];
    
    __block __weak UIImageView *imageView = (UIImageView *)[cell viewWithTag:103];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *orderString = [[NSString alloc] init];
    orderString = [NSString stringWithFormat:@"%@", blog.order];
    orderLbl.text = orderString;
    titleLbl.text = blog.title;
    
    if ([blog.descr isEqualToString:@""]) {
        blog.descr = @"Description unavailable.";
    }
    
    //Define the range you're interested in
    NSRange stringRange = {0, MIN([blog.descr length], 150)};
    
    //Adjust the range to include dependent chars
    stringRange = [blog.descr rangeOfComposedCharacterSequencesForRange:stringRange];
    
    //Now you can create the short string
    NSString *shortString = [blog.descr substringWithRange:stringRange];
    shortString = [NSString stringWithFormat:@"%@...", shortString];
    
    descLbl.text = shortString;
    dateLbl.text = blog.pubDate;
    dateLbl.hidden = YES;
    
    NSString *textString = [[NSString alloc] init];
    textString = [NSString stringWithFormat:@"%@ - %@", blog.author, blog.pubDate];
    
    authorLbl.text = textString;
    
    __weak UIImage *image = [UIImage imageNamed:@"placeholder.png"];
    imageView.image = image;
    
    /************************************************
     Parameter   	Size             	Dimensions
     xlg	Extra Large	320 x 240
     lg	Large	200 x 150
     sm	Small	100 x 75
     vsm	Very Small	90 x 68
     mcr	Micro	75 x 57
     
     Mute warnings using:
     #pragma clang diagnostic push
     #pragma clang diagnostic ignored "-Warc-retain-cycles"
     #pragma clang diagnostic pop
     ************************************************/
    //NSLog(@"GUID: %@", blog.guid);
    NSString *imageGetter = [NSString stringWithFormat:@"http://images.shrinktheweb.com/xino.php?stwembed=1&stwxmax=100&stwymax=90&stwaccesskeyid=ea6efd2fb0f678a&stwsize=sm&stwurl=%@", blog.guid];
    
    NSURL *url = [NSURL URLWithString:imageGetter];
    
    // Interesting way of handling batch image downloads http://stackoverflow.com/questions/23818055/handling-download-of-image-using-sdwebimage-while-reusing-uitableviewcell.
    // request image.
    UIImage *imageFromCache = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageGetter];
    
    if (imageFromCache) {
        imageView.image = imageFromCache;
        [imageView setAlpha:1.0];
    } else {
        
        BOOL isLink = [[blog.guid lowercaseString] hasPrefix:@"http://"];
        if(isLink) {
            
            [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                
                CGImageRef cgref = [image CGImage];
                CIImage *cim = [image CIImage];
                
                if (cim == nil && cgref == NULL)
                {
                    NSLog(@"no underlying data");
                } else {
                    NSLog(@"There is data");
                }
                
                if (!error) {
                    [imageView setAlpha:0.0];
                    [UIView animateWithDuration:0.5 animations:^{
                        imageView.image = image;
                        [imageView setAlpha:1.0];
                    }];
                } else {
                    NSLog(@"Error: %@, Description: %@", error, error.description);
                    
                    /*
                     
                     Error: Error Domain=NSURLErrorDomain Code=-1100 "The operation couldn’t be completed. (NSURLErrorDomain error -1100.)", Description: Error Domain=NSURLErrorDomain Code=-1100 "The operation couldn’t be completed. (NSURLErrorDomain error -1100.)"
                     
                     Your system is configured to download updates from a private server, not from Apple. That server isn't working or isn't reachable. If you're bound to an Open Directory or Active Directory domain, or if you're behind a firewall that doesn't allow downloading updates directly from Apple, your network administrator has to solve the problem.
                     
                     */
                }
            }];
        }
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    VMArticleViewController *vc = (VMArticleViewController *)[segue destinationViewController];
    
    CorporateArticle *blog;
    
    if(![self isFilteredList]) {
        blog = [_fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    } else {
        blog = [self.filteredTableData objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
    
    vc.articleURL = blog.link;
}


#pragma mark - FetchedResults controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    NSLog(@"fetchedResultsController method");
    
    self.filteredList = NO;
    
    if (_fetchedResultsController != nil) {
        
        return _fetchedResultsController;
        
    }
    
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _managedObjectContext = appDelegate.managedObjectContext;
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CorporateArticle"
                                   inManagedObjectContext:_managedObjectContext];
    
    [fetchRequest setFetchLimit:100];
    
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
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerWillChangeContent");
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"didChangeObject Row %ld", (long)indexPath.row);
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            NSLog(@"Inserting");
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"Deleting");
            NSLog(@"indexpath %@", indexPath);
            if(indexPath == NULL) break;
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"Results Change Update");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"Move?");
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
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

#pragma mark - UISearchBar delegates

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldBeginEditing");
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidBeginEditing");
    [self.tap setEnabled:YES];
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldEndEditing");
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidEndEditing");
    [self.tap setEnabled:NO];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"textDidChange");
    
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _managedObjectContext = appDelegate.managedObjectContext;
    
    self.filteredTableData = [[NSMutableArray alloc] init];
    
    // Create our fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    // Define the entity we are looking for
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CorporateArticle" inManagedObjectContext:_fetchedResultsController.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Define how we want our entities to be sorted
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"order" ascending:YES];
    
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // If we are searching for anything...
    if(searchText.length > 0)
    {
        // Define how we want our entities to be filtered
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[c] %@) OR (descr CONTAINS[c] %@)", searchText, searchText];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    
    // Finally, perform the load
    NSArray* loadedEntities = [self.fetchedResultsController.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [self setFilteredList:YES];
    self.filteredTableData = [[NSMutableArray alloc] initWithArray:loadedEntities];
    
    if(searchText.length < 1) {
        [self setFilteredList:NO];
    }
    
    [self.tableView reloadData];
}

//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0); // called before text changes

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarSearchButtonClicked");
    [searchBar resignFirstResponder];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarBookmarkButtonClicked");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"searchBarCancelButtonClicked");
}


@end