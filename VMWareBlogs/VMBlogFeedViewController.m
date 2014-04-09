//
//  VMBlogFeedViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMBlogFeedViewController.h"
#import <TBXML+HTTP.h>
#import <TBXML.h>
#import <TBXML+Compression.h>
#import "Blog.h"
#import "VMBlog.h"
#import "VMAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <dispatch/dispatch.h>
#import "VMArticleViewController.h"

#define UPDATE_ARTICLES_INTERVAL 5

@interface VMBlogFeedViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSTimer *updateBlogListTimer;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;
@property (atomic, strong) NSManagedObjectContext *moc;
@property (atomic, assign) BOOL updateFlag;
@end

@implementation VMBlogFeedViewController
@synthesize managedObjectContext;
@synthesize blogArray;
@synthesize updateFlag;
@synthesize moc = _moc;

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
    
    [self.tableView setBackgroundColor:[self colorWithHexString:@"24232F"]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSError *error;
    self.fetchedResultsController = nil;
    
    NSLog(@"Perform fetch");
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    
    
    _backgroundQueue = dispatch_queue_create("com.vmwareblogs.articleupdater.bgqueue", NULL);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:@"UIApplicationWillResignActiveNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    UINavigationBar *navBar = [[self navigationController] navigationBar];
    UIImage *backgroundImage = [UIImage imageNamed:@"navBarLogoNoStatusBar.png"];
    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    //Set the update flag to no update being made.
    self.updateFlag = NO;

    [self.tableView reloadData];
    
    [self performSelectorInBackground:@selector(updateList:) withObject:self];
    
    //Update the article list every x number of seconds.
    _updateBlogListTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_ARTICLES_INTERVAL target:self selector:@selector(updateList:) userInfo:nil repeats: YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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

- (void)appWillEnterForeground:(id)sender {
    if([self isKindOfClass:[VMBlogFeedViewController class]]) {
        NSLog(@"App is entering foreground from Blog feed update flag: %d", self.updateFlag);
        
        //Update the article list every x number of seconds.
        _updateBlogListTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_ARTICLES_INTERVAL target:self selector:@selector(updateList:) userInfo:nil repeats: YES];
    }
}

- (void)appWillEnterBackground:(id)sender {
    if([self isKindOfClass:[VMBlogFeedViewController class]]) {
        NSLog(@"App is entering background from Blog feed update flag: %d", self.updateFlag);
        
        [self.moc rollback];
        if(self.updateFlag) {
            NSLog(@"Rolling back the managed object context");
            [self.moc rollback];
            self.updateFlag = NO;
        }
        
        NSError *error;
        [managedObjectContext save:&error];
        if(error) {
            NSLog(@"Crap error");
        }
        [_updateBlogListTimer invalidate];
    }
}

- (void)appWillTerminate:(id)sender {
    NSLog(@"App will terminate from Blog feed");
    if([self isKindOfClass:[VMBlogFeedViewController class]]) {
        
        if(self.updateFlag) {
            NSLog(@"Rolling back the managed object context from termination");
            [self.moc rollback];
            self.updateFlag = NO;
        }
        
        NSError *error;
        [managedObjectContext save:&error];
        if(error) {
            NSLog(@"Crappers error");
        }
//        [_updateBlogListTimer invalidate];
    }
}

// Whatever method you registered as an observer to NSManagedObjectContextDidSave
- (void)contextDidSave:(NSNotification *)notification
{
    NSLog(@"The notification from saved changes %@", notification);
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                withObject:notification
                                             waitUntilDone:YES];
}

- (void)listHasUpdated {
    NSLog(@"The list has been updated");
   
    self.fetchedResultsController = nil;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (NSString *)stringByStrippingTags:(NSString *)stringtoParse {
	@autoreleasepool {
        
        // Find first & and short-cut if we can
        NSUInteger ampIndex = [stringtoParse rangeOfString:@"<" options:NSLiteralSearch].location;
        if (ampIndex == NSNotFound) {
            return [NSString stringWithString:stringtoParse]; // return copy of string as no tags found
        }
        
        // Scan and find all tags
        NSScanner *scanner = [NSScanner scannerWithString:stringtoParse];
        [scanner setCharactersToBeSkipped:nil];
        NSMutableSet *tags = [[NSMutableSet alloc] init];
        NSString *tag;
        do {
            
            // Scan up to <
            tag = nil;
            [scanner scanUpToString:@"<" intoString:NULL];
            [scanner scanUpToString:@">" intoString:&tag];
            
            // Add to set
            if (tag) {
                NSString *t = [[NSString alloc] initWithFormat:@"%@>", tag];
                [tags addObject:t];
            }
            
        } while (![scanner isAtEnd]);
        
        // Strings
        NSMutableString *result = [[NSMutableString alloc] initWithString:stringtoParse];
        NSString *finalString;
        
        // Replace tags
        NSString *replacement;
        for (NSString *t in tags) {
            
            // Replace tag with space unless it's an inline element
            replacement = @" ";
            if ([t isEqualToString:@"<a>"] ||
                [t isEqualToString:@"</a>"] ||
                [t isEqualToString:@"<span>"] ||
                [t isEqualToString:@"</span>"] ||
                [t isEqualToString:@"<strong>"] ||
                [t isEqualToString:@"</strong>"] ||
                [t isEqualToString:@"<em>"] ||
                [t isEqualToString:@"</em>"]) {
                replacement = @"";
            }
            
            // Replace
            [result replaceOccurrencesOfString:t
                                    withString:replacement
                                       options:NSLiteralSearch
                                         range:NSMakeRange(0, result.length)];
        }
        
        // Remove multi-spaces and line breaks
        finalString = [self stringByRemovingNewLinesAndWhitespace:result];
        
        // Cleanup
        
        // Return
        return finalString;
        
	}
}

- (NSString *)stringByRemovingNewLinesAndWhitespace:(NSString*)stringToParse {
	@autoreleasepool {
        
        // Strange New lines:
        //	Next Line, U+0085
        //	Form Feed, U+000C
        //	Line Separator, U+2028
        //	Paragraph Separator, U+2029
        
        // Scanner
        NSScanner *scanner = [[NSScanner alloc] initWithString:stringToParse];
        [scanner setCharactersToBeSkipped:nil];
        NSMutableString *result = [[NSMutableString alloc] init];
        NSString *temp;
        NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                                          [NSString stringWithFormat:@" \t\n\r%C%C%C%C", (unichar)0x0085, (unichar)0x000C, (unichar)0x2028, (unichar)0x2029]];
        // Scan
        while (![scanner isAtEnd]) {
            
            // Get non new line or whitespace characters
            temp = nil;
            [scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
            if (temp) [result appendString:temp];
            
            // Replace with a space
            if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
                if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
                    [result appendString:@" "];
            }
            
        }
        
        // Cleanup
        
        // Return
        NSString *retString = [NSString stringWithString:result];
        
        // Return
        return retString;
	}
}

- (NSString *)stringByDecodingXMLEntities: (NSString *)stringToParse {
    
    NSLog(@"stringByDecodingXMLEntities");
    
    NSUInteger myLength = [stringToParse length];
    NSUInteger ampIndex = [stringToParse rangeOfString:@"&" options:NSLiteralSearch].location;
    
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return stringToParse;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
    
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:stringToParse];
    
    [scanner setCharactersToBeSkipped:nil];
    
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
    
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&ndash;" intoString:NULL])
            [result appendString:@"-"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            
            NSLog(@"GOT NUMBER");
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
                
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            
            if (gotNumber) {
                
                [result appendFormat:@"%C", (unichar)charCode];
                
                NSLog(@"Got number %C", (unichar)charCode);
                
                [scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";
                
                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
                
                
                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];
                
                //[scanner scanUpToString:@";" intoString:&unknownEntity];
                //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
                
            }
            
        }
        else {
            NSString *amp;
            
            [scanner scanString:@"&" intoString:&amp];  //an isolated & symbol
            [result appendString:amp];
            
            /*
             NSString *unknownEntity = @"";
             [scanner scanUpToString:@";" intoString:&unknownEntity];
             NSString *semicolon = @"";
             [scanner scanString:@";" intoString:&semicolon];
             [result appendFormat:@"%@%@", unknownEntity, semicolon];
             NSLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
             */
        }
        
    }
    while (![scanner isAtEnd]);
    
finish:
    
    //Handle HTML Character entities that aren't caught above.
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&ndash;" withString:@"-"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&quot;" withString:@"/"""];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&rsquo;" withString:@"'"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&hellip;" withString:@"..."];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#038;" withString:@"&"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#60;" withString:@"<"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#62;" withString:@">"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&lt" withString:@"<"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#160;" withString:@" "];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#8211;" withString:@"-"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#8212;" withString:@"—"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#8216;" withString:@"'"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#8220;" withString:@"/"""];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#8221;" withString:@"/"""];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#8230;" withString:@"'"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#8243;" withString:@"″"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#8594;" withString:@" "];
    
    return result;
}

- (void)updateList:(id)sender {
    NSLog(@"Update Core Manager");

    self.updateFlag = YES;
    
    //TODO
    
    /*
     
     Setup a flag to TRUE which indicates an update is in progress.
     
     Once the update is complete se the flag to False
     
     If the update occurs while the application is terminated/enters into background then revert list to the original.
     
    */
    
    // Perform the request on a new thread so we don't block the UI
    dispatch_async(_backgroundQueue, ^(void) {
        
        NSURL *urlString = [NSURL URLWithString:@"http://www.vmwareblogs.com/rss.jsp"];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlString cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        
        NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        
        NSString* documentResponseString = [[NSString alloc] initWithData:data
                                                                 encoding:NSASCIIStringEncoding];
//        NSLog(@"The documentResponseString %@", documentResponseString);

        int order = 1;
       
        
        if(!error) {
            NSError *TBXMLError = nil;
            
            TBXML *tbxml = [[TBXML alloc] initWithXMLString:documentResponseString error:&TBXMLError];
//            TBXML *tbxml = [[TBXML alloc] initWithXMLData:data error:&TBXMLError];
           
           TBXMLElement * rootElement = tbxml.rootXMLElement;
           NSString *rootElementSTr = [TBXML textForElement:rootElement];
           
           NSLog(@"Root Element String %@", rootElementSTr);
           
           if([rootElementSTr isEqualToString:@""]) {
               NSLog(@"Root Element String empty");
           } else if( rootElementSTr == NULL ) {
               NSLog(@"Root Element String null");
           }
           
           if (!TBXMLError) {

               
               NSLog(@"No error");
               
               VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
               
               //Get the manager object context ******************************************************************

               NSPersistentStoreCoordinator *coordinator = [appDelegate persistentStoreCoordinator];
               
               self.moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
               
               [self.moc setPersistentStoreCoordinator:coordinator];
               
               [[NSNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(contextDidSave:)
                                                            name:NSManagedObjectContextDidSaveNotification
                                                          object:self.moc];
               
               //Retrieve the entity description
               NSEntityDescription *entityDescription = [NSEntityDescription
                                                         entityForName:@"Blog" inManagedObjectContext:self.moc];
               
               // Create and configure a fetch request with the Book entity.
               NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
               NSError *fetchRequestError;

              [fetchRequest setEntity:entityDescription];
               NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
               NSArray *sortDescriptors = @[sort];
               
               [fetchRequest setSortDescriptors:sortDescriptors];
               
               NSArray *sortedArticleArray = [self.moc executeFetchRequest:fetchRequest error:&fetchRequestError];
               
               TBXMLElement * rootXMLElement = tbxml.rootXMLElement;
               TBXMLElement * channelElement = [TBXML childElementNamed:@"channel" parentElement:rootXMLElement];
               TBXMLElement * itemElement = [TBXML childElementNamed:@"item" parentElement:channelElement];
               
               Blog *blogEntry;
               
               int j = 0;
               
               do {
                   if( order == 101 ){
                       dispatch_async(dispatch_get_main_queue(), ^{
                           UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Hello World!"
                                                                             message:@"This is your first UIAlertview message."
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil];
                           [message show];
                       });
                   }
                   
                   TBXMLElement * titleElem = [TBXML childElementNamed:@"title" parentElement:itemElement];
                   TBXMLElement * linkElem = [TBXML childElementNamed:@"link" parentElement:itemElement];
                   TBXMLElement * descElement = [TBXML childElementNamed:@"description" parentElement:itemElement];
                   TBXMLElement * pubDateElement = [TBXML childElementNamed:@"pubDate" parentElement:itemElement];
                   TBXMLElement * guidElement = [TBXML childElementNamed:@"guid" parentElement:itemElement];
                   
                   if([sortedArticleArray count] > 0) {
                       Blog *article = [sortedArticleArray objectAtIndex:j];
                       if( [article.link isEqualToString:[TBXML textForElement:linkElem]] ) {
                           NSLog(@"Same %d, %@----%@", j, [TBXML textForElement:titleElem], article.title);
                           j++;
                           continue;
                       } else {
                           [self.moc deleteObject:article];
                           
                           if (![self.moc save:&error]) {
                               NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                               
                           }
                           
                           [self.moc refreshObject:article mergeChanges:YES];

                       }
                   }
                   
                   //Create an instance of the entity.
                   blogEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Blog"
                                                             inManagedObjectContext:self.moc];

                   //Set the title.
                   NSString *titleStr = [self stringByDecodingXMLEntities:[TBXML textForElement:titleElem]];
                   titleStr = [self stringByStrippingTags:titleStr];
                   
                   [blogEntry setValue:titleStr forKey:@"title"];
                   
                   //Set the link.
                   [blogEntry setValue:[TBXML textForElement:linkElem] forKey:@"link"];
                   
                   NSString *descStr;
                   
                   //TODO Sometimes encoding is for latin handle this here.
                   
//                   if([TBXML textForElement:descElement] == NULL) {
//                       NSLog(@"Description is null");
//                       descStr = [NSString stringWithUTF8String:[[TBXML textForElement:descElement] cStringUsingEncoding:[NSString defaultCStringEncoding]]];
//                   }
                   
                   descStr = [self stringByDecodingXMLEntities:[TBXML textForElement:descElement]];
                   descStr = [self stringByStrippingTags:descStr];
                   
                   [blogEntry setValue:descStr forKey:@"descr"];

                   //Set the description.
                   [blogEntry setValue:[TBXML textForElement:pubDateElement] forKey:@"guid"];
                   [blogEntry setValue:[TBXML textForElement:guidElement] forKey:@"pubDate"];
                   
                   NSNumber *myIntNumber = [NSNumber numberWithInt:order];

                   //Set the order to be used for querying an ordered list.
                   [blogEntry setValue:myIntNumber forKey:@"order"];
                   
                   order++;
                   j++;
                   
                   if (![self.moc save:&error]) {
                       NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                       
                   }
                   
                   [blogEntry.managedObjectContext refreshObject:blogEntry mergeChanges:YES];
                   
               } while ((itemElement = itemElement->nextSibling));
               
               self.updateFlag = NO;
           } else {
               NSLog(@"Error %@", TBXMLError);
           }
       } else {
           NSLog(@"Error");
       }
    });
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 142;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSLog(@"Number of sections in tableView");
    // Return the number of sections.
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"Number of rows in tableView %lu", (unsigned long)[self.blogArray count]);

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"NUMBER OF ROWS %d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Trending Now", @"Trending Now");
            break;
        case 1:
            sectionName = NSLocalizedString(@"myOtherSectionName", @"myOtherSectionName");
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    if (section == 0) {
        [headerView setBackgroundColor:[self colorWithHexString:@"2F3485"]];
        UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0, self.tableView.bounds.size.width, 21.5)];
        [sectionTitle setFont:[UIFont fontWithName:@"ArialMT" size:13]];
        sectionTitle.text = @"Trending Now...";
        sectionTitle.textColor = [UIColor whiteColor];
        [headerView addSubview: sectionTitle];
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"articleSegue" sender:self];
}

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    Blog *blog = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *orderLbl = (UILabel *)[cell viewWithTag:100];
    [orderLbl setFont:[UIFont fontWithName:@"futura" size:20]];
    
    UITextField *titleLbl = (UITextField *)[cell viewWithTag:101];
    [titleLbl setUserInteractionEnabled:NO];
    titleLbl.text = @"text";
    [titleLbl setFont:[UIFont fontWithName:@"Arial" size:15.0f]];
    titleLbl.textColor = [self colorWithHexString:@"343A43"];
    
    UILabel *descLbl = (UILabel *)[cell viewWithTag:102];
    [descLbl setFont:[UIFont fontWithName:@"Arial" size:14.0f]];
    descLbl.textColor = [self colorWithHexString:@"8590A1"];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:103];
    
    [imageView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [imageView.layer setBorderWidth: 0.5];
    
    UIImage *image = [UIImage imageNamed:@"placeholder.png"];
    
    orderLbl.text = [NSString stringWithFormat:@"%@", blog.order];
    titleLbl.text = blog.title;
    descLbl.text = blog.descr;
    
    imageView.image = image;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Stop the blog update;
    [_updateBlogListTimer invalidate];
    [self.moc rollback];
    
    VMArticleViewController *vc = [segue destinationViewController];

    Blog *blog = [_fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    
    NSLog(@"Selecting the link %@", blog.link);
    vc.articleURL = blog.link;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a story board-based application, you will often want to do a little preparation before navigation
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
- (NSFetchedResultsController *)fetchedResultsController {
    NSLog(@"FetchedResultsController");

    if (_fetchedResultsController != nil) {
        NSLog(@"FetchedResultsController is not equal to NIL");
        return _fetchedResultsController;
    }
    
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    NSPersistentStoreCoordinator *coordinator = appDelegate.persistentStoreCoordinator;
//    if (coordinator != nil) {
//        
//        managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
    
    managedObjectContext = appDelegate.managedObjectContext;
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSLog(@"alloc FetchedResultsController");
    //Retrieve the entity description

    NSLog(@"get blog entity");
    NSEntityDescription *entity = [NSEntityDescription
                                              entityForName:@"Blog" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    

    
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error;
    
    [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Create and initialize the fetch results controller.");
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:@"Root"];
    
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
