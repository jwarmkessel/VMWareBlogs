//
//  VMBlog.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/14/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMBlog : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *descr;
@property (nonatomic, strong) NSString *pubDate;

-(id) initWithTitle:(NSString*)blogTitle link:(NSString*)blogLink descr:(NSString*)description publishDate:(NSString*)publishDate;
@end
