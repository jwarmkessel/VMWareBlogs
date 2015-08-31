//
//  VMBlogFeedViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMBlogFeedViewController.h"
#import "VMAppDelegate.h"
#import "VMArticleViewController.h"
#import "Blog.h"
#import <dispatch/dispatch.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "VMSynchronousFeedUpdater.h"
#import "VMSectionHeaderView.h"

#define DEBUGGER 1
#define BASE_URI @"http://www.vmwareblogs.com/"
#define DEFAULT_ROW_HEIGHT 210
static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";

@interface VMBlogFeedViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (atomic, strong) NSManagedObjectContext *moc;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredTableData;
@property (assign, getter = isFilteredList) BOOL filteredList;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UITapGestureRecognizer *scrollToTopTap;
@property (strong, nonatomic) VMSynchronousFeedUpdater *SynchronousFeedUpdater;

//TODO TEST CODE
@property (assign) BOOL toggle;
@property (strong, nonatomic) UIView *loadingView;
@end

@implementation VMBlogFeedViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
    
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.searchBar setDelegate:self];
    
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.SynchronousFeedUpdater = [[VMSynchronousFeedUpdater alloc] initWithManagedObjectContext:self.managedObjectContext internal:NO];
    [self.SynchronousFeedUpdater setDelegate:self];
    [self.fetchedResultsController setDelegate:self];
    
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width, self.tableView.frame.size.height)];

    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];


    self.filteredList = NO;
    
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"696566"]];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithHexString:@"346633"]];
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithHexString:@"346633"]];
    
    NSError *error;
    self.fetchedResultsController = nil;
    
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
    
    //Make the call to action text animate with blinking.
    //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scrollTest) userInfo:nil repeats: YES];
    
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    else
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)mergeChanges:(NSNotification *)notification{
    // Merge changes into the default context on the main thread
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                              withObject:notification
                           waitUntilDone:YES];
}

- (void)scrollTest {

    if(self.toggle) {
        [self.tableView scrollRectToVisible:CGRectMake(0, arc4random() % (int)self.tableView.contentSize.height, 1, 1) animated:YES];
    } else {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    
    self.toggle = !self.toggle;
}

- (void)refreshTable:(id)sender {
    
    [self.refreshControl beginRefreshing];
    
    NSLog(@"Refreshing Table Data");

    //TODO: refresh your data
    //[self.tableView setUserInteractionEnabled:NO];
    
    [self.loadingView setBackgroundColor:[UIColor blackColor]];
    [self.loadingView setAlpha:0];
    [self.view addSubview:self.loadingView];
    
    [UIView animateWithDuration:0.3
                     animations:^
    {
        [_loadingView setAlpha:0.3];
    }
                     completion:^(BOOL finished)
    {
        self.searchBar.text = @"";
        [self setFilteredList:NO];
        [self.SynchronousFeedUpdater updateList];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.scrollToTopTap setEnabled:YES];
}

- (void)scrollToTopTapHander {
    NSLog(@"Scoll to tap");
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}
- (void)dismissKeyboard {
    // add self
    [self.searchBar resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    
    UINavigationBar *navBar = [[self navigationController] navigationBar];
    UIImage *backgroundImage = [UIImage imageNamed:@"VMware_logo_88.png"];
    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    [self.tableView reloadData];
}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (void)viewDidUnload {
    
    // Release any properties that are loaded in viewDidLoad or can be recreated lazily.
    self.fetchedResultsController = nil;
}

- (void)appWillEnterForeground:(id)sender {
    if([self isKindOfClass:[VMBlogFeedViewController class]]) {
        NSLog(@"App is entering foreground from Blog feed");
    }
}

- (void)appWillEnterBackground:(id)sender {
    if([self isKindOfClass:[VMBlogFeedViewController class]]) {
        NSLog(@"App is entering background from Blog feed");
    }
}

- (void)appWillTerminate:(id)sender {
    if([self isKindOfClass:[VMBlogFeedViewController class]]) {
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

#pragma mark - VMarticleEntityUpdater delegates

-(void)articleEntityUpdaterDidFinishUpdating {
    //[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refreshTable) userInfo:nil repeats: YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.loadingView setAlpha:0.0];
    }completion:^(BOOL finished) {
        [self.loadingView removeFromSuperview];
        [self.tableView setUserInteractionEnabled:YES];
        
        //[self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];

}

-(void)articleEntityUpdaterDidError {
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.loadingView setAlpha:0.0];
    }];
    [self.loadingView removeFromSuperview];
    [self.tableView setUserInteractionEnabled:YES];
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 210;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(![self isFilteredList]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        return [self.filteredTableData count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    VMSectionHeaderView *headerView = [[VMSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    
    if (section == 0) {
        headerView.titleLabel.text = @"The Latest Posts From All VMware Blogs";
        [headerView.titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    return headerView;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.scrollToTopTap setEnabled:NO];
    
    Blog* blog = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    blog.lastRead = [NSDate date];
    
    NSError* error = nil;
    
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Error occurred");
    }
    
    [self performSegueWithIdentifier:@"articleSegue" sender:self];
}

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Blog *blog;
    
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
    
    __weak UIImageView *imageView = (UIImageView *)[cell viewWithTag:103];
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
    
    if (imageFromCache)
    {
        imageView.image = imageFromCache;
        [imageView setAlpha:1.0];
    }
    else
    {
        BOOL isLink = [[blog.guid lowercaseString] hasPrefix:@"http://"];
        
        if (isLink)
        {
            [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
            {
                if (image == nil || error)
                {
                    NSLog(@"Error: %@, Description: %@", error, error.description);
                }
                else
                {
                    [imageView setAlpha:0.0];
                    
                    [UIView animateWithDuration:0.5 animations:^
                    {
                        imageView.image = image;
                        [imageView setAlpha:1.0];
                    }];
                }
            }];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSLog(@"prepareForSegue");
    VMArticleViewController *vc = (VMArticleViewController *)[segue destinationViewController];

    Blog *blog;
    
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
- (NSFetchedResultsController *)fetchedResultsController
{
    self.filteredList = NO;

    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSNumber* internal = self.internalBlog ? self.internalBlog : @(0);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"internal == %@", internal];
    
    fetchRequest.predicate = predicate;
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSEntityDescription *entity = [NSEntityDescription
                                              entityForName:@"Blog"
                                     inManagedObjectContext:self.managedObjectContext];
    
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


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch ((int)type)
    {        
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
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.filteredTableData = [[NSMutableArray alloc] init];
    
    // Create our fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    // Define the entity we are looking for
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Blog" inManagedObjectContext:_fetchedResultsController.managedObjectContext];
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
