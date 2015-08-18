//
//  VMWareBlogsAPI.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/17/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//
#define BASE_URI @"http://www.vmwareblogs.com/"
#import "VMWareBlogsAPI.h"
#import "VMAppDelegate.h"

#import "Blog.h"

@interface VMWareBlogsAPI ()

@end

@implementation VMWareBlogsAPI
@synthesize moc, updateFlag;

+ (NSString *)requestRSS:(NSString*)urlString
{
    NSString*   post        = [NSString stringWithFormat:@"nocache=true"];
    NSData*     postData    = [post dataUsingEncoding:NSASCIIStringEncoding
                                 allowLossyConversion:YES];
    NSString*   postLength  = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength
   forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8"
   forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    NSURLResponse*  response    = nil;
    NSError*        error       = nil;
    NSData*         POSTReply   = [NSURLConnection sendSynchronousRequest:request
                                                        returningResponse:&response
                                                                    error:&error];
    
    if (POSTReply == nil)
    {
        if (error)
        {
            NSLog(@"Error %@", error);
        }
    }
    else
    {
        NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes]
                                                      length:[POSTReply length]
                                                    encoding: NSASCIIStringEncoding];
        
        //character decoding http://stackoverflow.com/questions/4913499/utf8-character-decoding-in-objective-c
        NSString *responseString = [NSString stringWithCString:[theReply cStringUsingEncoding:NSISOLatin1StringEncoding]
                                                      encoding:NSUTF8StringEncoding];
        
        return responseString;
    }
    
    return @"";
}

@end

