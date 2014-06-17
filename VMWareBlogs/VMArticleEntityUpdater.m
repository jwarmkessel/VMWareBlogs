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

@interface VMArticleEntityUpdater()
- (NSString *)stringByDecodingXMLEntities: (NSString *)stringToParse;

- (NSString *)stringByRemovingNewLinesAndWhitespace:(NSString*)stringToParse;

- (NSString *)stringByStrippingTags:(NSString *)stringtoParse;

- (void)contextDidSave:(NSNotification *)notification;

/*
 Update list
*/
- (void)updateList;

- (Blog *)createArticleEntityWithTitle:(TBXMLElement *)titleElem articleLink:(TBXMLElement *)linkElem articleDescription:(TBXMLElement *)descElement publishDate:(TBXMLElement *)pubDateElement GUIDElement:(TBXMLElement *)guidElement AuthorElement:(TBXMLElement *)authorElement andOrder:(int)order;

@end

@implementation VMArticleEntityUpdater
@synthesize updateContext;
@synthesize updateBlogListTimer;

- (void)updateList {
    
    if([self isUpdating]) {
        NSLog(@"DENY UPDATE REQUEST");
        return;
    }
    
    self.updating = YES;
    
    self.updateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
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
            
            //Configure notifications to update when there is a save in Core Data.
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contextDidSave:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:self.updateContext];

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
            TBXMLElement * channelElement = [TBXML childElementNamed:@"channel" parentElement:rootXMLElement];
            TBXMLElement * itemElement = [TBXML childElementNamed:@"item" parentElement:channelElement];
            
            int j = 0;
            int order = 1;
            int articleCount = 0;
            int totalArticles = [sortedArticleArray count] == 0 ? 0 : ([sortedArticleArray count] -1);
            
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

                } else {
                    Blog *article = [sortedArticleArray objectAtIndex:j];
                    
                    if( ![article.link isEqualToString:[TBXML textForElement:linkElem]] ) {
                    
                        [article setOrder:[NSNumber numberWithInt:101]];
                        //If the ordered article is different then save the article with an order that will not be displayed.
                        if (![self.updateContext save:&temporaryMOCError]) {
                            NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                        }
                        
                        //Delete corresponding image in SDWebImage.
                        NSString *imageGetter = [NSString stringWithFormat:@"http://images.shrinktheweb.com/xino.php?stwembed=1&stwxmax=640&stwaccesskeyid=ea6efd2fb0f678a&stwsize=sm&stwurl=%@", [TBXML textForElement:guidElement]];
                        
                        [[SDImageCache sharedImageCache] removeImageForKey:imageGetter fromDisk:YES];
                        
                        //Just save the articles.
                        blogEntry = [self createArticleEntityWithTitle:titleElem articleLink:linkElem articleDescription:descElement publishDate:pubDateElement GUIDElement:guidElement AuthorElement:authorElement andOrder:order];

                        if (![self.updateContext save:&temporaryMOCError]) {
                            NSLog(@"Failed to save - error: %@", [temporaryMOCError localizedDescription]);
                        }
                        
                        [self.updateContext refreshObject:article mergeChanges:YES];
                    }
                    
                    order++;
                    j++;
                    articleCount++; 
                }
            
            } while ((itemElement = itemElement->nextSibling));
            
            //Update is complete. Reset the flag.
            self.updating = NO;
            
            // save parent to disk asynchronously
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"Perform save to the parent context");
                
                NSError *error;
                if (![appDelegate.managedObjectContext save:&error]) {
                    // handle error
                    NSLog(@"Error saving to parent context");
                }

                [self.delegate articleEntityUpdaterDidFinishUpdating];
            });
        }
    }];
}

- (Blog *)createArticleEntityWithTitle:(TBXMLElement *)titleElem articleLink:(TBXMLElement *)linkElem articleDescription:(TBXMLElement *)descElement publishDate:(TBXMLElement *)pubDateElement GUIDElement:(TBXMLElement *)guidElement AuthorElement:(TBXMLElement *)authorElement andOrder:(int)order {
    
    //Initialize Blog Entity.
    Blog *blogEntry;
    
    //Create an instance of the entity.
    blogEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Blog"
                                              inManagedObjectContext:self.updateContext];
    
    //Set the title.
    NSString *titleStr = [self stringByDecodingXMLEntities:[TBXML textForElement:titleElem]];
    titleStr = [self stringByStrippingTags:titleStr];
    
    [blogEntry setValue:titleStr forKey:@"title"];
    
    //Set the link.
    [blogEntry setValue:[TBXML textForElement:linkElem] forKey:@"link"];
    
    NSString *descStr = [TBXML textForElement:descElement];
    
    descStr = [self stringByDecodingXMLEntities:descStr];
    descStr = [self stringByStrippingTags:descStr];
    
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
    VMAppDelegate *appDelegate = (VMAppDelegate *)[[UIApplication sharedApplication] delegate];
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
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&lsquo;" withString:@"'"];
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
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"\""];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"\""];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#rdquo;" withString:@"\""];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#ldquo;" withString:@"\""];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#rsquo;" withString:@"'"];
    result = (NSMutableString *)[result stringByReplacingOccurrencesOfString:@"&#lsquo;" withString:@"'"];
    
    return result;
}


@end
