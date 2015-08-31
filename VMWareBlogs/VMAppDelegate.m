//
//  VMAppDelegate.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 3/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMAppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "VMSynchronousFeedUpdater.h"
#import "VMRootItem.h"
#import "Blog.h"

static NSString* kCrashlyticsKey = @"59c371b61d689f5678d0ebe6a0d8db4973125312";

@interface VMAppDelegate ()

@property (nonatomic, strong) NSManagedObjectContext* asynchronousContext;

@end

@implementation VMAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureRootItemForCoreData];
 
    [Crashlytics startWithAPIKey:kCrashlyticsKey];

    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];

    self.asynchronousContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [self.asynchronousContext setParentContext:self.managedObjectContext];
    
    [operationQueue addOperationWithBlock:^
    {
        self.updater = [[VMSynchronousFeedUpdater alloc] initWithManagedObjectContext:self.asynchronousContext internal:NO];
        [self.updater updateList];

        self.corporateUpdater = [[VMSynchronousFeedUpdater alloc] initWithManagedObjectContext:self.asynchronousContext internal:YES];

        [self.corporateUpdater updateList];
    }];
    

    
    return YES;
}

- (void)configureRootItemForCoreData
{
    
#if DEBUG
    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
#endif
    
    if (![self determineIfPeresistentStoreExists])
    {
        NSError*    error       = nil;
        VMRootItem* rootItem    = [VMRootItem insertNewObjectInManagedObjectContext:self.managedObjectContext];
        
        rootItem.lastUpdated    = [NSDate date];
        
        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Error occurred");
        }
        else
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setURL:rootItem.objectID.URIRepresentation forKey:@"rootItem"];
        }
    }

//    else
//    {
//        //  Access ID
//        NSUserDefaults*     defaults    = [NSUserDefaults standardUserDefaults];
//        NSURL*              uri         = [defaults URLForKey:@"rootItem"];
//        NSManagedObjectID*  moid        = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
//        NSError*            error       = nil;
//        VMRootItem*         rootItem    = (id) [self.managedObjectContext existingObjectWithID:moid error:&error];
//        
//        Blog* blog = [[rootItem.blog allObjects] objectAtIndex:0];
//        
//        
//    }
}

- (BOOL)determineIfPeresistentStoreExists
{
    BOOL    persistenStoreExists    = NO;
    NSURL*  url                     = [[self applicationDocumentsURLDirectory] URLByAppendingPathComponent:@"BlogModel.sqlite"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.relativePath])
    {
        persistenStoreExists = YES;
    }
    return persistenStoreExists;
}
         
#pragma mark - Private Helper Methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSError *error;
    [self.managedObjectContext save:&error];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSError *error;
    [self.managedObjectContext save:&error];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack
/*
Lightweight migrations can handle the following changes:
 - Adding or removing an entity, attribute, or relationship
 - Making an attribute non-optional with a default value
 - Making a non-optional attribute optional
 - Renaming an entity or attribute using a renaming identifier
 
On a related subject, there are some changes that do not require a migration, basically anything that doesn’t change the underlying SQLite backing store, including:
 - Changing the name of an NSManagedObject subclass
 - Adding or removing a transient property
 - Making changes to the user info dictionary
 - Changing validation rules

To enable lightweight migrations, you need to pass a dictionary containing two keys to the options parameter of the method that initializes the persistent store coordinator. These keys are:
 - NSMigratePersistentStoresAutomaticallyOption – attempt to automatically migrate versioned stores
 - NSInferMappingModelAutomaticallyOption – attempt to create the mapping model automatically

Important note: Don’t run your project after making these modifications yet. This is because if you do it will upgrade your model to the new version, and you don’t want to do that until you actually modify it.
 */

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BlogModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsURLDirectory] URLByAppendingPathComponent:@"BlogModel.sqlite"];
    
    NSError *error = nil;
    
    //I can currently perform a lightweight migration http://stackoverflow.com/questions/8881453/the-model-used-to-open-the-store-is-incompatible-with-the-one-used-to-create-the
    
    /*
     Add or remove a property (attribute or relationship).
     Make a nonoptional property optional.
     Make an optional attribute nonoptional, as long as you provide a default value.
     Add or remove an entity.
     Rename a property.
     Rename an entity.
    */
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        

        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsURLDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}


@end
