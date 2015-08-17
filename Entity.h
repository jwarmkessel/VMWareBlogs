//
//  Entity.h
//  
//
//  Created by Justin Warmkessel on 8/16/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface Entity : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * community;
@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * internal;
@property (nonatomic, retain) NSDate * lastRead;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * objectSyncStatus;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * pubDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSManagedObject *vmRootItem;

@end
