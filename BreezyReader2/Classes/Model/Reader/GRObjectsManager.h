//
//  GRObjectsManager.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#define ITEMMODELNAME @"GRItemModel"
#define SUBMODELNAME @"GRSubModel"

@interface GRObjectsManager : NSObject {

}

+(void)clearObjects;
+(BOOL)deleteObject:(NSManagedObject*)object;
+(BOOL)insertObject:(NSManagedObject*)object;
+(BOOL)commitChangeForContext:(NSManagedObjectContext*)context;
+(void)didReceiveMemoryWarning;
+(NSManagedObjectContext*)context;
+(NSFetchedResultsController*)fetchedResultsControllerFromModel:(NSString*)objectModel 
													  predicate:(NSPredicate*)predicate
												sortDescriptors:(NSArray*)descriptors;


@end

@interface GRObjectsManager (private)

+(NSManagedObjectModel*)managedObjectModel;
+(NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+(NSString*)applicationDocumentsDirectory;
+(NSMutableDictionary*)cachedObjects;

@end

