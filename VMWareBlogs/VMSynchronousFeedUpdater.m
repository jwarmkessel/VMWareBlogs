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

- (NSArray*)fetchPersistedBlog
{
    //VMAppDelegate*      appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults*     defaults    = [NSUserDefaults standardUserDefaults];
    NSURL*              uri         = [defaults URLForKey:@"rootItem"];
    NSManagedObjectID*  moid        = [self.updateContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
    NSError*            error       = nil;
    VMRootItem*         rootItem    = (id) [self.updateContext existingObjectWithID:moid error:&error];
    
    return [rootItem.blog allObjects];;
}

- (BOOL)updateList
{
    BOOL            somethingToUpdate   = NO;
    VMAppDelegate*  appDelegate         = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray*        sortedBlogs         = [self fetchPersistedBlog];
    
    //Request data.
    NSString* urlString = [NSString stringWithFormat:@"%@/%@", kBaseURI, kCommunityRSSFeed];
    
    if (self.internal)
    {
        urlString = [NSString stringWithFormat:@"%@/%@", kBaseURI, kCorporateRSSFeed];
    }
    
    NSString* xmlString = [VMWareBlogsAPI requestRSS:urlString];
    
    if(xmlString)
    {
        somethingToUpdate = YES;
        
        NSError*    TBXMLError  = nil;
        TBXML*      tbxml       = [[TBXML alloc] initWithXMLString:xmlString
                                                             error:&TBXMLError];
        
        if (TBXMLError)
        {
            NSLog(@"TBXML Error : %@", TBXMLError);
            
            [self performSelectorInBackground:@selector(updateList) withObject:self];
        }
        else if (!TBXMLError)
        {
            TBXMLElement*           rootXMLElement          = tbxml.rootXMLElement;
            TBXMLElement*           channelElement          = [TBXML childElementNamed:@"channel" parentElement:rootXMLElement];
            TBXMLElement*           itemElement             = [TBXML childElementNamed:@"item" parentElement:channelElement];
            
            if (!itemElement)
            {
                NSLog(@"Item element from XML download is nil.");
            }
            else if (itemElement)
            {
                do
                {
                    Blog*           blog            = [self createBlog:*itemElement];
                    NSString*       predicateFormat = @"link == %@";
                    NSArray*        existingBlog    = [sortedBlogs filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:predicateFormat,
                                                                                                 blog.link]];
                    
                    if (existingBlog.count == 0)
                    {
                        NSUserDefaults*     defaults    = [NSUserDefaults standardUserDefaults];
                        NSURL*              uri         = [defaults URLForKey:@"rootItem"];
                        NSManagedObjectID*  moid        = [self.updateContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
                        NSError*            error       = nil;
                        VMRootItem*         rootItem    = (id) [self.updateContext existingObjectWithID:moid error:&error];
                        
                        if (error)
                        {
                            NSLog(@"Error retrieving VMRootItem : %@", error);
                        }
                        else
                        {
                            [rootItem addBlogObject:blog];
                        }
                    }
                    else
                    {
                        NSLog(@"Object already exists");
                    }
                    
                } while ((itemElement = itemElement->nextSibling));
            }
            
            NSError* error = nil;
            
            [self.updateContext save:&error];
            
            if (![self.updateContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            else
            {
                [appDelegate.managedObjectContext performBlock:^{
                    NSError *parentError = nil;
                    if (![appDelegate.managedObjectContext save:&parentError]) {
                        NSLog(@"Error saving parent");
                    }
                }];
            }
        }
    }
    
    [self.delegate articleEntityUpdaterDidFinishUpdating];
    
    return somethingToUpdate;
}

- (Blog*)createBlog:(TBXMLElement)itemElement
{
    Blog *blogEntry;
    
    TBXMLElement* titleElem         = [TBXML childElementNamed:@"title"         parentElement:&itemElement];
    TBXMLElement* linkElem          = [TBXML childElementNamed:@"link"          parentElement:&itemElement];
    TBXMLElement* descElement       = [TBXML childElementNamed:@"description"   parentElement:&itemElement];
    TBXMLElement* pubDateElement    = [TBXML childElementNamed:@"pubDate"       parentElement:&itemElement];
    TBXMLElement* guidElement       = [TBXML childElementNamed:@"guid"          parentElement:&itemElement];
    TBXMLElement* authorElement     = [TBXML childElementNamed:@"dc:creator"    parentElement:&itemElement];
    
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
    
    return blogEntry;
}

@end
