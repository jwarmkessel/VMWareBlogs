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

#define UPDATE_ARTICLES_INTERVAL 60

@implementation VMArticleEntityUpdater
@synthesize updateContext;
@synthesize updateFlag;
@synthesize updateBlogListTimer;

- (void)updateList {
    
    if(self.updateFlag) {
        NSLog(@"No update this time");
        return;
    }
    
    self.updateFlag = YES;
    self.updateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [self.updateContext performBlock:^{
        
        VMWareBlogsAPI *api = [[VMWareBlogsAPI alloc] init];
        NSString *xmlString = [api requestRSS];
        
        int order = 1;
        

        NSError *TBXMLError = nil;
        
        TBXML *tbxml = [[TBXML alloc] initWithXMLString:xmlString error:&TBXMLError];
    
        TBXMLElement * rootElement = tbxml.rootXMLElement;
        NSString *rootElementSTr = [TBXML textForElement:rootElement];
        
        NSLog(@"Root Element String %@", rootElementSTr);
        
        if([rootElementSTr isEqualToString:@""]) {
            NSLog(@"Root Element String empty");
        } else if( rootElementSTr == NULL ) {
            NSLog(@"Root Element String null");
        }
        
        if (!TBXMLError) {
            
            NSLog(@"No TBXML error");
            
            VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            //Get the manager object context ******************************************************************
            
            NSPersistentStoreCoordinator *coordinator = [appDelegate persistentStoreCoordinator];
            
            NSError *temporaryMOCError;
            
            [self.updateContext setPersistentStoreCoordinator:coordinator];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contextDidSave:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:self.updateContext];
            
            //Retrieve the entity description
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"Blog" inManagedObjectContext:self.updateContext];
            
            // Create and configure a fetch request with the Book entity.
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSError *fetchRequestError;
            
            [fetchRequest setEntity:entityDescription];
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
            NSArray *sortDescriptors = @[sort];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSArray *sortedArticleArray = [self.updateContext executeFetchRequest:fetchRequest error:&fetchRequestError];
            
//                NSLog(@"sortedArticleArray count %d", [sortedArticleArray count]);
            
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
                    NSLog(@"J COUNT %d", j);
                    Blog *article = [sortedArticleArray objectAtIndex:j];
                    if( [article.link isEqualToString:[TBXML textForElement:linkElem]] ) {
                        NSLog(@"Same %d, %@----%@", j, [TBXML textForElement:titleElem], article.title);
                        j++;
                        continue;
                    } else {
                        [self.updateContext deleteObject:article];
                        
                        if (![self.updateContext save:&temporaryMOCError]) {
                            NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                            
                        }
                        
                        [self.updateContext refreshObject:article mergeChanges:YES];
                        
                        if([article isDeleted]) {
                            //If an object that was already fetched has been deleted on another thread or in a different ManagedObjectContext, it is possible that you receive an exception when you try to access a property of the deleted object
                            
                            NSLog(@"Article is deleted");
                        }
                        
                    }
                }
                
                //Create an instance of the entity.
                blogEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Blog"
                                                          inManagedObjectContext:self.updateContext];
                
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
                
                if (![self.updateContext save:&temporaryMOCError]) {
                    NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                    
                }
                
                [blogEntry.managedObjectContext refreshObject:blogEntry mergeChanges:YES];
                
            } while ((itemElement = itemElement->nextSibling));
            
            // save parent to disk asynchronously
            [appDelegate.managedObjectContext performBlock:^{
                NSLog(@"Perform save to the parent context");
                
                NSError *error;
                if (![appDelegate.managedObjectContext save:&error])
                {
                    // handle error
                }
                
                NSLog(@"Reset the update flag on private queue.");
                self.updateFlag = NO;
                
                //Update the article list every x number of seconds.
                NSLog(@"Start timer");
                if([updateBlogListTimer isValid]) {
                    NSLog(@"-------------------> For some reason the timer is valid");
                    [updateBlogListTimer invalidate];
                    updateBlogListTimer = nil;
                }
                updateBlogListTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_ARTICLES_INTERVAL target:self selector:@selector(updateList) userInfo:nil repeats: YES];
            }];
            
        } else {
            NSLog(@"TBXML Error %@", TBXMLError);
            self.updateFlag = NO;
            [self performSelectorInBackground:@selector(updateList) withObject:self];
            
        }

    }];
}

// Whatever method you registered as an observer to NSManagedObjectContextDidSave
- (void)contextDidSave:(NSNotification *)notification
{
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"The notification from saved changes %@", notification);
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                       withObject:notification
                                                    waitUntilDone:YES];
}

//TODO move this into a separate class to handle HTML Character entities.
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


@end
