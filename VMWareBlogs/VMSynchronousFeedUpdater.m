//
//  VMSynchronousFeedUpdater.m
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 6/20/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMSynchronousFeedUpdater.h"
#import "VMAppDelegate.h"
#import "Blog.h"
#import "VMWareBlogsAPI.h"
#import <TBXML.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "VMRootItem.h"

static const NSString* kBaseURI             = @"http://www.vmwareblogs.com";
static const NSString* kCorporateRSSFeed    = @"rss.jsp?feed=2";
static const NSString* kCommunityRSSFeed    = @"rss.jsp";

@interface VMSynchronousFeedUpdater()

- (BOOL)updateList;
- (Blog *)createArticleEntityWithTitle:(TBXMLElement *)titleElem
                           articleLink:(TBXMLElement *)linkElem
                    articleDescription:(TBXMLElement *)descElement
                           publishDate:(TBXMLElement *)pubDateElement
                           GUIDElement:(TBXMLElement *)guidElement
                         AuthorElement:(TBXMLElement *)authorElement
                              andOrder:(int)order;

@end

@implementation VMSynchronousFeedUpdater

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                          internal:(BOOL)internal
{
    self = [super init];
    
    if (self)
    {
        _updateContext      = managedObjectContext;
        _internal           = internal;
    }
    return self;
}
- (BOOL)updateList
{
    [self.updateContext reset];
    
    //Request data.
    NSString* urlString = [NSString stringWithFormat:@"%@/%@", kBaseURI, kCommunityRSSFeed];
    
    if (self.internal)
    {
        urlString = [NSString stringWithFormat:@"%@/%@", kBaseURI, kCorporateRSSFeed];
    }
    
    NSString *xmlString = [VMWareBlogsAPI requestRSS:urlString];
    
    if(xmlString == nil)
    {
        NSLog(@"(Developer WARNING) XML string is equal to nil");
        
        return NO;
    }
    
    NSError *TBXMLError = nil;
    
    //initiate tbxml frameworks to consume xml data.
    TBXML *tbxml = [[TBXML alloc] initWithXMLString:xmlString error:&TBXMLError];
    if (TBXMLError) {
        NSLog(@"(Developer WARNING) THERE WAS A BIG MISTAKE %@", TBXMLError);
        [self performSelectorInBackground:@selector(updateList) withObject:self];
        
        return NO;
        
    } else if (!TBXMLError) {
        NSError *temporaryMOCError;
        
        VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        //If either the managed object context or persistent store coordinator are nil set them up.
        if (self.updateContext == nil) {
            self.updateContext = appDelegate.managedObjectContext;
        }
        
        if (self.updateContext.persistentStoreCoordinator == nil) {
            NSPersistentStoreCoordinator *coordinator = [appDelegate persistentStoreCoordinator];
            [self.updateContext setPersistentStoreCoordinator:coordinator];
        }
        
        // Create and configure a fetch request with the Blog entity.
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Blog" inManagedObjectContext:self.updateContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

        [fetchRequest setReturnsObjectsAsFaults:NO];
        
        NSError *fetchRequestError;
        [fetchRequest setEntity:entityDescription];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        NSArray *sortDescriptors = @[sort];
        [fetchRequest setSortDescriptors:sortDescriptors];
        NSArray *sortedArticleArray = [self.updateContext executeFetchRequest:fetchRequest error:&fetchRequestError];
        
        //Prepare to consume data.
        TBXMLElement * rootXMLElement = tbxml.rootXMLElement;
        TBXMLElement * channelElement = [TBXML childElementNamed:@"channel" parentElement:rootXMLElement];
        TBXMLElement * itemElement = [TBXML childElementNamed:@"item" parentElement:channelElement];
        
        int j = 0;
        int order = 1;
        int articleCount = 0;
        int totalArticles = [sortedArticleArray count] == 0 ? 0 : (int)([sortedArticleArray count] -1);
        
        do {
            Blog *blogEntry;
            
            TBXMLElement * titleElem = [TBXML childElementNamed:@"title" parentElement:itemElement];
            TBXMLElement * linkElem = [TBXML childElementNamed:@"link" parentElement:itemElement];
            TBXMLElement * descElement = [TBXML childElementNamed:@"description" parentElement:itemElement];
            TBXMLElement * pubDateElement = [TBXML childElementNamed:@"pubDate" parentElement:itemElement];
            TBXMLElement * guidElement = [TBXML childElementNamed:@"guid" parentElement:itemElement];
            TBXMLElement * authorElement = [TBXML childElementNamed:@"dc:creator" parentElement:itemElement];
            
            //If the input is greater than database...
            if(articleCount >= totalArticles) {
                
                //Just save the articles.
                blogEntry = [self createArticleEntityWithTitle:titleElem articleLink:linkElem articleDescription:descElement publishDate:pubDateElement GUIDElement:guidElement AuthorElement:authorElement andOrder:order];
                
                if (![self.updateContext save:&temporaryMOCError]) {
                    NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                    
                }
                
                [blogEntry.managedObjectContext refreshObject:blogEntry mergeChanges:YES];

                if (blogEntry)
                {
                    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    NSUserDefaults*     defaults    = [NSUserDefaults standardUserDefaults];
                    NSURL*              uri         = [defaults URLForKey:@"rootItem"];
                    NSManagedObjectID*  moid        = [appDelegate.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
                    NSError*            error       = nil;
                    VMRootItem*         rootItem    = (id) [appDelegate.managedObjectContext existingObjectWithID:moid error:&error];
                    
                    [rootItem addBlogObject:blogEntry];
                }
                
            } else {
                Blog *article = [sortedArticleArray objectAtIndex:j];
                if (linkElem)
                {
                    if( ![article.link isEqualToString:[TBXML textForElement:linkElem]] ) {
                                                
                        // Delete the row from the data source.
                        [self.updateContext deleteObject:article];
                        
                        // Force saving the delete.
                        if (![self.updateContext save:&temporaryMOCError]) {
                            NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                        }
                                            
                        //Just save the articles.
                        blogEntry = [self createArticleEntityWithTitle:titleElem articleLink:linkElem articleDescription:descElement publishDate:pubDateElement GUIDElement:guidElement AuthorElement:authorElement andOrder:order];
                        
                        if (blogEntry)
                        {
                            VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
                            
                            NSUserDefaults*     defaults    = [NSUserDefaults standardUserDefaults];
                            NSURL*              uri         = [defaults URLForKey:@"rootItem"];
                            NSManagedObjectID*  moid        = [appDelegate.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
                            NSError*            error       = nil;
                            VMRootItem*         rootItem    = (id) [appDelegate.managedObjectContext existingObjectWithID:moid error:&error];
                            
                            [rootItem addBlogObject:blogEntry];
                        }
                    }
                }
            }
            
            order++;
            j++;
            articleCount++;
            

        } while ((itemElement = itemElement->nextSibling));
        
        NSError* error = nil;
        
        [appDelegate.managedObjectContext save:&error];
        
        
        if (![self.updateContext save:&temporaryMOCError]) {
            NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
        }
    }
    
    [self.delegate articleEntityUpdaterDidFinishUpdating];
    
    return YES;
}

- (Blog *)createArticleEntityWithTitle:(TBXMLElement *)titleElem articleLink:(TBXMLElement *)linkElem articleDescription:(TBXMLElement *)descElement publishDate:(TBXMLElement *)pubDateElement GUIDElement:(TBXMLElement *)guidElement AuthorElement:(TBXMLElement *)authorElement andOrder:(int)order {
    
    //Initialize Blog Entity.
    Blog *blogEntry;
    
    //Create an instance of the entity.
    blogEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Blog"
                                              inManagedObjectContext:self.updateContext];
    
    NSNumber* internal = @(0);
    
    if (self.internal)
    {
        internal = @(1);
    }
    
    [blogEntry setInternal:internal];
    
    if (titleElem)
    {
        //Set the title.
        NSString *titleStr = [NSString stringByDecodingXMLEntities:[TBXML textForElement:titleElem]];
        titleStr = [NSString stringByStrippingTags:titleStr];
        
        [blogEntry setValue:titleStr forKey:@"title"];
    }
    
    if (linkElem)
    {
        //Set the link.
        [blogEntry setValue:[TBXML textForElement:linkElem] forKey:@"link"];
    }
    
    if (descElement)
    {
        NSString *descStr = [TBXML textForElement:descElement];
        
        descStr = [NSString stringByDecodingXMLEntities:descStr];
        descStr = [NSString stringByStrippingTags:descStr];
        
        [blogEntry setValue:descStr forKey:@"descr"];
    }
    
    if (guidElement)
    {
        //Set the description.
        [blogEntry setValue:[TBXML textForElement:guidElement] forKey:@"guid"];
        
        //TODO set the integer value of the community attribute 0 for public and 1 for VMWare community blogs
        NSString *articleLink = [TBXML textForElement:guidElement];
        
        int communityFlag = 0;
        
        if ([articleLink hasPrefix:@"http://vmblog.com"] || [articleLink hasPrefix:@"https://vmblog.com"]) {
            communityFlag = 1;
        }
        
        NSNumber *communityType = [NSNumber numberWithInt:communityFlag];
        
        [blogEntry setValue:communityType forKey:@"community"];
    }

    if (pubDateElement)
    {
        //Truncate date string
        NSString * pubDateString = [TBXML textForElement:pubDateElement];
        NSArray* dateStrArray = [pubDateString componentsSeparatedByString: @" "];
        NSString *dayString = (NSString *) [dateStrArray objectAtIndex: 1];
        
        NSString *ichar = [NSString stringWithFormat:@"%c", [dayString characterAtIndex:0]];
        
        if([ichar  isEqual: @"0"]) {
            dayString = [NSString stringWithFormat:@"%c", [dayString characterAtIndex:1]];
        }
        
        pubDateString = [NSString stringWithFormat:@"%@ %@ %@", dayString, [dateStrArray objectAtIndex: 2], [dateStrArray objectAtIndex: 3]];
        
        [blogEntry setValue:pubDateString forKey:@"pubDate"];
    }
    
    if (authorElement)
    {
        [blogEntry setValue:[TBXML textForElement:authorElement] forKey:@"author"];
    }
    
    NSNumber *myIntNumber = [NSNumber numberWithInt:order];
    
    //Set the order to be used for querying an ordered list.
    [blogEntry setValue:myIntNumber forKey:@"order"];
    
    return blogEntry;
}

@end
