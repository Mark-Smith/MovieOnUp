//
//  MOUCoreDataHelper.h
//  MovieOnUp
//
//  Created by Mark Smith on 19/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MOUCoreDataHelper : NSObject

+ (MOUCoreDataHelper*)sharedInstance;

- (NSManagedObject*)getConfigMO;
- (BOOL)clearManagedObjectContextCacheForEntity:(NSString*)entityName withId:(NSInteger)objectId;
- (NSArray*)getGenresWithGenreIDs:(NSArray*)genreIDs;

@end
