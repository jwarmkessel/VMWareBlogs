//
//  VMBlog.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/14/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMBlog.h"

@implementation VMBlog
@synthesize title, link, descr, pubDate;
-(id) initWithTitle:(NSString*)blogTitle link:(NSString*)blogLink descr:(NSString*)description publishDate:(NSString*)publishDate {
    self.title = blogTitle;
    self.link = blogLink;
    self.descr = description;
    self.pubDate = publishDate;
    
    return self;
}

@end
