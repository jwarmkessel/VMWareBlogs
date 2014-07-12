//
//  VMCorporateSynchronousFeedUpdater.m
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 6/20/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMCorporateSynchronousFeedUpdater.h"
#import "VMAppDelegate.h"
#import "CorporateArticle.h"
#import "VMWareBlogsAPI.h"
#import <TBXML.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface VMCorporateSynchronousFeedUpdater()

- (BOOL)updateList;
- (CorporateArticle *)createArticleEntityWithTitle:(TBXMLElement *)titleElem articleLink:(TBXMLElement *)linkElem articleDescription:(TBXMLElement *)descElement publishDate:(TBXMLElement *)pubDateElement GUIDElement:(TBXMLElement *)guidElement AuthorElement:(TBXMLElement *)authorElement andOrder:(int)order;
@end

@implementation VMCorporateSynchronousFeedUpdater
@synthesize updateContext;
@synthesize updateBlogListTimer;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if (self) {
        self.updateContext = managedObjectContext;
    }
    return self;
}
- (BOOL)updateList {
    
    [self.updateContext reset];
    
    //Request data.
    NSString *xmlString = [VMWareBlogsAPI corporateRequestRSS];
    NSLog(@"Finished xmlString");
    if(xmlString == nil) {
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
        NSLog(@"Parsing xmlString");
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
                                                  entityForName:@"CorporateArticle" inManagedObjectContext:self.updateContext];
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
            CorporateArticle *blogEntry;
            
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
                
            } else {
                CorporateArticle *article = [sortedArticleArray objectAtIndex:j];
                
                if( ![article.link isEqualToString:[TBXML textForElement:linkElem]] ) {
                                            
                    // Delete the row from the data source.
                    [self.updateContext deleteObject:article];
                    
                    // Force saving the delete.
                    if (![self.updateContext save:&temporaryMOCError]) {
                        NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                    }
                                        
                    //Just save the articles.
                    blogEntry = [self createArticleEntityWithTitle:titleElem articleLink:linkElem articleDescription:descElement publishDate:pubDateElement GUIDElement:guidElement AuthorElement:authorElement andOrder:order];
                }
            }
            
            order++;
            j++;
            articleCount++;
            

        } while ((itemElement = itemElement->nextSibling));
        
        if (![self.updateContext save:&temporaryMOCError]) {
            NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
        }
    }
    
    [self.delegate corporateFeedUpdaterDidFinishUpdating];
    
    return YES;
}

- (CorporateArticle *)createArticleEntityWithTitle:(TBXMLElement *)titleElem articleLink:(TBXMLElement *)linkElem articleDescription:(TBXMLElement *)descElement publishDate:(TBXMLElement *)pubDateElement GUIDElement:(TBXMLElement *)guidElement AuthorElement:(TBXMLElement *)authorElement andOrder:(int)order {
    
    //Initialize Blog Entity.
    CorporateArticle *blogEntry;
    
    //Create an instance of the entity.
    blogEntry = [NSEntityDescription insertNewObjectForEntityForName:@"CorporateArticle"
                                              inManagedObjectContext:self.updateContext];
    
    //Set the title.
    NSString *titleStr = [NSString stringByDecodingXMLEntities:[TBXML textForElement:titleElem]];
    titleStr = [NSString stringByStrippingTags:titleStr];
    
    [blogEntry setValue:titleStr forKey:@"title"];
    
    //Set the link.
    [blogEntry setValue:[TBXML textForElement:linkElem] forKey:@"link"];
    
    NSString *descStr = [TBXML textForElement:descElement];
    
    descStr = [NSString stringByDecodingXMLEntities:descStr];
    descStr = [NSString stringByStrippingTags:descStr];
    
    [blogEntry setValue:descStr forKey:@"descr"];
    
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
    
    [blogEntry setValue:[TBXML textForElement:authorElement] forKey:@"author"];
    
    NSNumber *myIntNumber = [NSNumber numberWithInt:order];
    
    //Set the order to be used for querying an ordered list.
    [blogEntry setValue:myIntNumber forKey:@"order"];
    
    return blogEntry;
    
}

@end
