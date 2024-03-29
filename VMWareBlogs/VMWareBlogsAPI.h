//
//  VMWareBlogsAPI.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/17/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMWareBlogsAPI : NSObject

@property (atomic, strong)      NSManagedObjectContext* moc;
@property (nonatomic, assign)   BOOL                    updateFlag;
@property (strong, nonatomic)   NSString*               songID;

+ (NSString *)requestRSS:(NSString*)urlString;

@end
