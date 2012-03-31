//
//  GRObjectsManager.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRObjectsManager.h"
#define STORE_TYPE		NSSQLiteStoreType
#define STORE_FILENAME	@"items"
#define STORE_FILENAME_EXTENSION @".sqlite"

@implementation GRObjectsManager

static NSManagedObjectModel* mom = nil;
static NSPersistentStoreCoordinator* persistentStoreCoordinator = nil;

static NSUInteger uncommitCount = 0;

static NSMutableDictionary* cachedObjects = nil;


+(NSManagedObjectContext*)context{
	NSManagedObjectContext* context = [[NSManagedObjectContext alloc] init];
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	
	[context setPersistentStoreCoordinator:coordinator];
	
	return [context autorelease];
}

+(void)clearObjects{
	[mom release];
	mom = nil;
	[persistentStoreCoordinator release];
	persistentStoreCoordinator = nil;
}

+(BOOL)insertObject:(NSManagedObject*)object{
	NSManagedObjectContext* context = [object managedObjectContext];
	
	[context lock];
	
	[context insertObject:object];
	
	[context unlock];
	
	return YES;

}

+(BOOL)deleteObject:(NSManagedObject*)object{
	
	NSManagedObjectContext* context = [object managedObjectContext];
	
	[context lock];
	
	[context deleteObject:object];
	
	[context lock];
	
	return YES;
}

+(BOOL)commitChangeForContext:(NSManagedObjectContext*)context{
	
	[context lock];
	
	NSError* error = nil;
	BOOL result = [context save:&error];
	
	if (!result){
		DebugLog(@"unknow error happen:%@", [error userInfo]);
	}
	
	[context unlock];
	
	uncommitCount = 0;
	
	return result;
	
}

+(NSFetchedResultsController*)fetchedResultsControllerFromModel:(NSString*)objectModel 
													  predicate:(NSPredicate*)predicate
												sortDescriptors:(NSArray*)descriptors{
	
	NSManagedObjectContext* context = [self context];
	
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:objectModel 
											  inManagedObjectContext:context];
	[request setEntity:entity];
	[request setPredicate:predicate];
	[request setSortDescriptors:descriptors];
	
	NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																				 managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
	
	[request release];
	
	return [controller autorelease];
}

+(void)didReceiveMemoryWarning{
	[cachedObjects removeAllObjects];
	[cachedObjects release];
	cachedObjects = nil;
}

@end

@implementation GRObjectsManager (private)
	
+(NSManagedObjectModel*)managedObjectModel{
	
    if (mom) {
        return mom;
    }
	
    mom = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	
    return mom;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
+(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[STORE_FILENAME stringByAppendingString:STORE_FILENAME_EXTENSION]];
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSError *error;
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
												  configuration:nil
															URL:storeUrl
														options:options 
														  error:&error]) {
		// Update to handle the error appropriately.
		DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
	
    return persistentStoreCoordinator;
}

+(NSString*)applicationDocumentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+(NSMutableDictionary*)cachedObjects{
	if (!cachedObjects){
		cachedObjects = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
		
	return cachedObjects;
}

@end

