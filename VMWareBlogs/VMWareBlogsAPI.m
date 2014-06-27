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

+ (NSString *)requestRSS {
    
    //NSTimeInterval timeInMilliseconds = [[NSDate date] timeIntervalSince1970];
    NSString *post = [NSString stringWithFormat:@"nocache=true"];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rss.jsp", BASE_URI]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *error;
    
    NSLog(@"\t\t\t\t\t\t\t\tRequesting from RSS");
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!error) {
        NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
        
        //character decoding http://stackoverflow.com/questions/4913499/utf8-character-decoding-in-objective-c
        NSString *responseString = [NSString stringWithCString:[theReply cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
        
        return responseString;
    } else {
        NSLog(@"Error %@", error);
    }
    
    return @"";
    

//    NSString *urlStr = [NSString stringWithFormat:@"%@/rss.jsp?nocache=true", BASE_URI];
//    //NSString *urlStr = [NSString stringWithFormat:@"%@/rss.jsp", BASE_URI];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
//    
//    NSURLResponse* response = nil;
//    NSError *NSURLConnectionError = nil;
//    
//    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&NSURLConnectionError];
//    
//    NSString* responseString;
//    
//    if(!NSURLConnectionError) {
//        
//        //Decode data.
//        responseString = [[NSString alloc] initWithData:data
//                                                       encoding:NSASCIIStringEncoding];
//
//        //character decoding http://stackoverflow.com/questions/4913499/utf8-character-decoding-in-objective-c
//        responseString = [NSString stringWithCString:[responseString cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
//        
//    } else {
//        NSLog(@"NSURLConnection Error %@", NSURLConnectionError);
//        NSLog(@"NSURLConnection Error %ld", (long)NSURLConnectionError.code);
//        NSLog(@"NSURLConnection Error %@", NSURLConnectionError.domain);
//        NSLog(@"NSURLConnection Error %@", NSURLConnectionError.userInfo);
//        NSLog(@"NSURLConnection Error %@", NSURLConnectionError.localizedDescription);
//        
//        NSLog(@"NSURLConnection Error %@", NSURLConnectionError.localizedDescription);
//        NSLog(@"NSURLConnection Error %@", NSURLConnectionError.localizedRecoveryOptions);
//        NSLog(@"NSURLConnection Error %@", NSURLConnectionError.localizedFailureReason);
//        NSLog(@"NSURLConnection Error %@", NSURLConnectionError.localizedRecoverySuggestion);
//    }
//
//    NSLog(@"Returning response");
//    return responseString;
}

@end

