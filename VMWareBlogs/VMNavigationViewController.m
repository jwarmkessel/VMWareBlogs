//
//  VMNavigationViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/18/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMNavigationViewController.h"
#import <TBXML+HTTP.h>
#import <TBXML.h>
#import <TBXML+Compression.h>
#import "Blog.h"
#import "VMAppDelegate.h"

@interface VMNavigationViewController ()

@end

@implementation VMNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            NSLog(@"GOT NUMBER");
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
    return result;
}

@end
