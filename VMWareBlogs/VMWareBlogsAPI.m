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

- (NSString *)requestRSS {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/rss.jsp", BASE_URI];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    NSURLResponse* response = nil;
    NSError *NSURLConnectionError = nil;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&NSURLConnectionError];
    
    NSString* responseString;
    
    if(!NSURLConnectionError) {
        
        //Decode data.
        responseString = [[NSString alloc] initWithData:data
                                                       encoding:NSASCIIStringEncoding];
    } else {
        NSLog(@"NSURLConnection Error");
    }

    return responseString;
}

@end

