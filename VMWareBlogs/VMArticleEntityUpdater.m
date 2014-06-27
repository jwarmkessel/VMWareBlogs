//
//  VMArticleEntityUpdater.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/17/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleEntityUpdater.h"
#import "VMAppDelegate.h"
#import "Blog.h"
#import "VMWareBlogsAPI.h"
#import <TBXML.h>
#import <SDWebImage/UIImageView+WebCache.h>


typedef enum {
    objectSynced = 0,
    objectCreated = 1,
    objectDeleted = 2,
} ObjectSyncStatus;

@interface VMArticleEntityUpdater()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (void)contextDidSave:(NSNotification *)notification;
- (void)updateList;
- (Blog *)createArticleEntityWithTitle:(TBXMLElement *)titleElem articleLink:(TBXMLElement *)linkElem articleDescription:(TBXMLElement *)descElement publishDate:(TBXMLElement *)pubDateElement GUIDElement:(TBXMLElement *)guidElement AuthorElement:(TBXMLElement *)authorElement objectSyncStatus:(ObjectSyncStatus)syncStatus andOrder:(int)order;
@end

@implementation VMArticleEntityUpdater
@synthesize updateContext;
@synthesize updateBlogListTimer;
@synthesize dateFormatter = _dateFormatter;


//This is what has been happening http://stackoverflow.com/questions/20937496/deleting-object-in-background-moc-then-refreshing-it-in-main-moc-causes-crash-in

- (void)updateList {
    
    self.updateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [self.updateContext reset];
    

    
    [self.updateContext performBlock:^{


        //Request data.
        NSString *xmlString = [VMWareBlogsAPI requestRSS];
        
        if(xmlString == nil) {
            self.updating = NO;
            NSLog(@"(Developer WARNING) XML string is equal to nil");
            [self.delegate articleEntityUpdaterDidError];
            
            return;
        }
        
        NSError *TBXMLError = nil;
        
        //initiate tbxml frameworks to consume xml data.
        TBXML *tbxml = [[TBXML alloc] initWithXMLString:xmlString error:&TBXMLError];
        if (TBXMLError) {
            NSLog(@"(Developer WARNING) THERE WAS A BIG MISTAKE %@", TBXMLError);
            self.updating = NO;
            [self.delegate articleEntityUpdaterDidError];
            [self performSelectorInBackground:@selector(updateList) withObject:self];
            
            return;
            
        } else if (!TBXMLError) {
            
            //Get the persistentStoreCoordinator
            VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSPersistentStoreCoordinator *coordinator = [appDelegate persistentStoreCoordinator];
            NSError *temporaryMOCError;
            [self.updateContext setPersistentStoreCoordinator:coordinator];
            
            
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
            TBXMLElement * channelElement;
            
            if (![TBXML childElementNamed:@"channel" parentElement:rootXMLElement]) {
                NSLog(@"(Developer WARNING) channel Element not found");
                [self.delegate articleEntityUpdaterDidError];
                return;
            } else {
                channelElement = [TBXML childElementNamed:@"channel" parentElement:rootXMLElement];
            }
            
            TBXMLElement * itemElement = [TBXML childElementNamed:@"item" parentElement:channelElement];
            
            if (![TBXML childElementNamed:@"item" parentElement:channelElement]) {
                NSLog(@"(Developer WARNING) item element not found");
                [self.delegate articleEntityUpdaterDidError];
                return;
            } else {
                itemElement = [TBXML childElementNamed:@"item" parentElement:channelElement];
            }
            
            int j = 0;
            int order = 0;
            int articleCount = 0;
            int totalArticles = [sortedArticleArray count] == 0 ? 0 : ([sortedArticleArray count] -1);
            
            NSLog(@"/t/t/t/t/t/t/t Total Article Count: %d", totalArticles);
            
            do {
                Blog *blogEntry;
                
                TBXMLElement * titleElem = [TBXML childElementNamed:@"title" parentElement:itemElement];
                TBXMLElement * linkElem = [TBXML childElementNamed:@"link" parentElement:itemElement];
                TBXMLElement * descElement = [TBXML childElementNamed:@"description" parentElement:itemElement];
                TBXMLElement * pubDateElement = [TBXML childElementNamed:@"pubDate" parentElement:itemElement];
                TBXMLElement * guidElement = [TBXML childElementNamed:@"guid" parentElement:itemElement];
                TBXMLElement * authorElement = [TBXML childElementNamed:@"dc:creator" parentElement:itemElement];
                
                //Set the title.
                NSString *titleStr = [NSString stringByDecodingXMLEntities:[TBXML textForElement:titleElem]];
                NSLog(@"TItle String %@", titleStr);
                
                //If the input is greater than database...
                if (articleCount >= totalArticles) {
                    
                    //Create an instance of the entity.
                    blogEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Blog"
                                                              inManagedObjectContext:self.updateContext];
                    //Just save the articles.
                    //Set sync status
                    [blogEntry setValue:[NSNumber numberWithInt:objectCreated] forKey:@"objectSyncStatus"];
                    
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
                    
                    NSLog(@"Order %d", order);
                    
                    NSNumber *myIntNumber = [NSNumber numberWithInt:order];
                    
                    //Set the order to be used for querying an ordered list.
                    [blogEntry setValue:myIntNumber forKey:@"order"];


                    if (![self.updateContext save:&temporaryMOCError]) {
                        NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                        
                    }
                    
                    // save parent to disk asynchronously
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.delegate articleEntityUpdaterDidInsertArticle:[blogEntry objectID]];
                    });
                    
                    [blogEntry.managedObjectContext refreshObject:blogEntry mergeChanges:NO];

                }else {
                    Blog *article = [sortedArticleArray objectAtIndex:j];
                    
                    NSLog(@"Article Link: %@", article.link);
                    NSLog(@"Blog link: %@", [TBXML textForElement:linkElem]);
                    
                    if( ![article.link isEqualToString:[TBXML textForElement:linkElem]] ) {
                        
                        // save parent to disk asynchronously
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.delegate articleEntityDidDeleteArticle:[article objectID]];
                        });
                        
                        Blog *aManagedObject = article;
                        NSManagedObjectContext *context = [aManagedObject managedObjectContext];
                        
                        [context deleteObject:aManagedObject];
                        
                        NSError *error;
                        if (![context save:&error]) {
                            // Handle the error.
                        }
 
                        //Create an instance of the entity.
                        blogEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Blog"
                                                                  inManagedObjectContext:self.updateContext];
                        
                        //Set sync status
                        [blogEntry setValue:[NSNumber numberWithInt:objectCreated] forKey:@"objectSyncStatus"];
                        
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

                        
                        if (![self.updateContext save:&temporaryMOCError]) {
                            NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                        }
                        
                        // save parent to disk asynchronously
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.delegate articleEntityUpdaterDidInsertArticle:[article objectID]];
                        });
                        
                        [self.updateContext refreshObject:article mergeChanges:NO];
                        [self.updateContext refreshObject:blogEntry mergeChanges:NO];
                    }
                }
                
                order++;
                j++;
                articleCount++;
                
            } while ((itemElement = itemElement->nextSibling));
            
            if (![self.updateContext save:&temporaryMOCError]) {
                NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
            }
            
            // save parent to disk asynchronously
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate articleEntityUpdaterDidFinishUpdating];
            });
            
            [self.updateContext reset]; // Here the inserted objects get released in the core data stack
        }
    }];
}

- (Blog *)createArticleEntityWithTitle:(TBXMLElement *)titleElem articleLink:(TBXMLElement *)linkElem articleDescription:(TBXMLElement *)descElement publishDate:(TBXMLElement *)pubDateElement GUIDElement:(TBXMLElement *)guidElement AuthorElement:(TBXMLElement *)authorElement objectSyncStatus:(ObjectSyncStatus)syncStatus andOrder:(int)order {
    
    //Initialize Blog Entity.
    Blog *blogEntry;
    
    //Set sync status
    [blogEntry setValue:[NSNumber numberWithInt:syncStatus] forKey:@"objectSyncStatus"];
    
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

// Whatever method you registered as an observer to NSManagedObjectContextDidSave
- (void)contextDidSave:(NSNotification *)notification
{
    NSLog(@"context did save");
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                       withObject:notification
                                                    waitUntilDone:YES];
}


#pragma mark - File Management

- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)JSONDataRecordsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL URLWithString:@"JSONRecords/" relativeToURL:[self applicationCacheDirectory]];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return url;
}

- (void)writeJSONResponse:(id)response toDiskForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    if (![(NSDictionary *)response writeToFile:[fileURL path] atomically:YES]) {
        NSLog(@"Error saving response to disk, will attempt to remove NSNull values and try again.");
        // remove NSNulls and try again...
        NSArray *records = [response objectForKey:@"results"];
        NSMutableArray *nullFreeRecords = [NSMutableArray array];
        for (NSDictionary *record in records) {
            NSMutableDictionary *nullFreeRecord = [NSMutableDictionary dictionaryWithDictionary:record];
            [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNull class]]) {
                    [nullFreeRecord setValue:nil forKey:key];
                }
            }];
            [nullFreeRecords addObject:nullFreeRecord];
        }
        
        NSDictionary *nullFreeDictionary = [NSDictionary dictionaryWithObject:nullFreeRecords forKey:@"results"];
        
        if (![nullFreeDictionary writeToFile:[fileURL path] atomically:YES]) {
            NSLog(@"Failed all attempts to save response to disk: %@", response);
        }
    }
}

- (NSDictionary *)JSONDictionaryForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    return [NSDictionary dictionaryWithContentsOfURL:fileURL];
}

- (NSArray *)JSONDataRecordsForClass:(NSString *)className sortedByKey:(NSString *)key {
    NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:className];
    NSArray *records = [JSONDictionary objectForKey:@"results"];
    return [records sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
}

- (void)deleteJSONDataRecordsForClassWithName:(NSString *)className {
    NSURL *url = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        NSLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}

#pragma mark - Date Manager

/*
 
 {
 "__type": "Date",
 "iso": "2011-08-21T18:02:52.249Z"
 }
 
*/
- (void)initializeDateFormatter {
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
}

- (NSDate *)dateUsingStringFromAPI:(NSString *)dateString {
    [self initializeDateFormatter];
    // NSDateFormatter does not like ISO 8601 so strip the milliseconds and timezone
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-5)];
    
    return [self.dateFormatter dateFromString:dateString];
}

- (NSString *)dateStringForAPIUsingDate:(NSDate *)date {
    [self initializeDateFormatter];
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    // remove Z
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-1)];
    // add milliseconds and put Z back on
    dateString = [dateString stringByAppendingFormat:@".000Z"];
    
    return dateString;
}

#pragma mark Core Data Example

//- (void)setValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject {
//    
//    if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"]) {
//        NSDate *date = [self dateUsingStringFromAPI:value];
//        [managedObject setValue:date forKey:key];
//    } else if ([value isKindOfClass:[NSDictionary class]]) {
//        if ([value objectForKey:@"__type"]) {
//            NSString *dataType = [value objectForKey:@"__type"];
//            
//            if ([dataType isEqualToString:@"Date"]) {
//                NSString *dateString = [value objectForKey:@"iso"];
//                NSDate *date = [self dateUsingStringFromAPI:dateString];
//                [managedObject setValue:date forKey:key];
//            } else if ([dataType isEqualToString:@"File"]) {
//                NSString *urlString = [value objectForKey:@"url"];
//                NSURL *url = [NSURL URLWithString:urlString];
//                NSURLRequest *request = [NSURLRequest requestWithURL:url];
//                NSURLResponse *response = nil;
//                NSError *error = nil;
//                NSData *dataResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//                [managedObject setValue:dataResponse forKey:key];
//            } else {
//                NSLog(@"Unknown Data Type Received");
//                [managedObject setValue:nil forKey:key];
//            }
//        }
//    } else {
//        [managedObject setValue:value forKey:key];
//    }
//}
//
//- (void)processJSONDataRecordsForDeletion {
//    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
//    //
//    // Iterate over all registered classes to sync
//    //
//    for (NSString *className in self.registeredClassesToSync) {
//        //
//        // Retrieve the JSON response records from disk
//        //
//        NSArray *JSONRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
//        if ([JSONRecords count] > 0) {
//            //
//            // If there are any records fetch all locally stored records that are NOT in the list of downloaded records
//            //
//            NSArray *storedRecords = [self
//                                      managedObjectsForClass:className
//                                      sortedByKey:@"objectId"
//                                      usingArrayOfIds:[JSONRecords valueForKey:@"objectId"]
//                                      inArrayOfIds:NO];
//            
//            //
//            // Schedule the NSManagedObject for deletion and save the context
//            //
//            [managedObjectContext performBlockAndWait:^{
//                for (NSManagedObject *managedObject in storedRecords) {
//                    [managedObjectContext deleteObject:managedObject];
//                }
//                NSError *error = nil;
//                BOOL saved = [managedObjectContext save:&error];
//                if (!saved) {
//                    NSLog(@"Unable to save context after deleting records for class %@ because %@", className, error);
//                }
//            }];
//        }
//        
//        //
//        // Delete all JSON Record response files to clean up after yourself
//        //
//        [self deleteJSONDataRecordsForClassWithName:className];
//    }
//    
//    //
//    // Execute the sync completion operations as this is now the final step of the sync process
//    //
//    [self executeSyncCompletedOperations];
//}
//
//- (void)processJSONDataRecordsIntoCoreData {
//    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
//    //
//    // Iterate over all registered classes to sync
//    //
//    for (NSString *className in self.registeredClassesToSync) {
//        if (![self initialSyncComplete]) { // import all downloaded data to Core Data for initial sync
//            //
//            // If this is the initial sync then the logic is pretty simple, you will fetch the JSON data from disk
//            // for the class of the current iteration and create new NSManagedObjects for each record
//            //
//            NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:className];
//            NSArray *records = [JSONDictionary objectForKey:@"results"];
//            for (NSDictionary *record in records) {
//                [self newManagedObjectWithClassName:className forRecord:record];
//            }
//        } else {
//            //
//            // Otherwise you need to do some more logic to determine if the record is new or has been updated.
//            // First get the downloaded records from the JSON response, verify there is at least one object in
//            // the data, and then fetch all records stored in Core Data whose objectId matches those from the JSON response.
//            //
//            NSArray *downloadedRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
//            if ([downloadedRecords lastObject]) {
//                //
//                // Now you have a set of objects from the remote service and all of the matching objects
//                // (based on objectId) from your Core Data store. Iterate over all of the downloaded records
//                // from the remote service.
//                //
//                NSArray *storedRecords = [self managedObjectsForClass:className sortedByKey:@"objectId" usingArrayOfIds:[downloadedRecords valueForKey:@"objectId"] inArrayOfIds:YES];
//                int currentIndex = 0;
//                //
//                // If the number of records in your Core Data store is less than the currentIndex, you know that
//                // you have a potential match between the downloaded records and stored records because you sorted
//                // both lists by objectId, this means that an update has come in from the remote service
//                //
//                for (NSDictionary *record in downloadedRecords) {
//                    NSManagedObject *storedManagedObject = nil;
//                    
//                    // Make sure we don't access an index that is out of bounds as we are iterating over both collections together
//                    if ([storedRecords count] > currentIndex) {
//                        storedManagedObject = [storedRecords objectAtIndex:currentIndex];
//                    }
//                    
//                    if ([[storedManagedObject valueForKey:@"objectId"] isEqualToString:[record valueForKey:@"objectId"]]) {
//                        //
//                        // Do a quick spot check to validate the objectIds in fact do match, if they do update the stored
//                        // object with the values received from the remote service
//                        //
//                        [self updateManagedObject:[storedRecords objectAtIndex:currentIndex] withRecord:record];
//                    } else {
//                        //
//                        // Otherwise you have a new object coming in from your remote service so create a new
//                        // NSManagedObject to represent this remote object locally
//                        //
//                        [self newManagedObjectWithClassName:className forRecord:record];
//                    }
//                    currentIndex++;
//                }
//            }
//        }
//        //
//        // Once all NSManagedObjects are created in your context you can save the context to persist the objects
//        // to your persistent store. In this case though you used an NSManagedObjectContext who has a parent context
//        // so all changes will be pushed to the parent context
//        //
//        [managedObjectContext performBlockAndWait:^{
//            NSError *error = nil;
//            if (![managedObjectContext save:&error]) {
//                NSLog(@"Unable to save context for class %@", className);
//            }
//        }];
//        
//        //
//        // You are now done with the downloaded JSON responses so you can delete them to clean up after yourself,
//        // then call your -executeSyncCompletedOperations to save off your master context and set the
//        // syncInProgress flag to NO
//        //
//        [self deleteJSONDataRecordsForClassWithName:className];
//        [self executeSyncCompletedOperations];
//    }
//}

//http://www.raywenderlich.com/15916/how-to-synchronize-core-data-with-a-web-service-part-1
//http://www.raywenderlich.com/17927/how-to-synchronize-core-data-with-a-web-service-part-2

@end
