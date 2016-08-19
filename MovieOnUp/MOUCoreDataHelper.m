//
//  MOUCoreDataHelper.m
//  MovieOnUp
//
//  Created by Mark Smith on 19/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import "MOUCoreDataHelper.h"
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@implementation MOUCoreDataHelper

+ (MOUCoreDataHelper*)sharedInstance
{
    static MOUCoreDataHelper *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[MOUCoreDataHelper alloc] init];
    });
    return _sharedInstance;
}

- (NSManagedObject*)getConfigMO {
    
    NSManagedObjectContext *managedObjectContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Configuration" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entityDesc];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!results) {
        //
    }
    return results[0];
}

- (BOOL)clearManagedObjectContextCacheForEntity:(NSString*)entityName withId:(NSInteger)objectId {
    
    NSManagedObjectContext *managedObjectContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    NSFetchRequest * entities = [[NSFetchRequest alloc] init];
    [entities setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];
    if (objectId >= 0) {
        NSPredicate  *predicate=[NSPredicate predicateWithFormat:@"id == %d",objectId];
        // Set the batch size to a suitable number.
        [entities setPredicate:predicate];
    }
    [entities setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * entitiesArray = [managedObjectContext executeFetchRequest:entities error:&error];
    //[allGroups release];
    
    if (error) {
        return FALSE;
    }
    
    for (NSManagedObject *entityItem in entitiesArray) {
        [managedObjectContext deleteObject:entityItem];
    }
    
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
    
    if (saveError) {
        return FALSE;
    }
    
    return TRUE;
}

// For a given array of NSInteger genre IDs, consult the Genre entities, and extract the corresponging genre names
-(NSArray*)getGenresWithGenreIDs:(NSArray*)genreIDs
{
    // results array
    NSMutableArray *results = [NSMutableArray array];
    
    NSManagedObjectContext *managedObjectContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    // create and configure a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // create and set an entity description
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Genre" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    for (NSNumber *genreID in genreIDs) {
        
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"id == %d", [genreID integerValue]];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchBatchSize:1];
        NSArray *genresMOs =[managedObjectContext executeFetchRequest:fetchRequest error:nil];
        if (genresMOs.count) {
            NSString *genreName = [[genresMOs[0] valueForKey:@"name"] description];
            [results addObject:genreName];
        }
    }
    
    return results;
}

@end
