//
//  MOURESTManager.h
//  RoamPA
//
//  Created by Mark Smith on 18/02/2016.
//  Copyright © 2016 ___ROAMPA___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>


extern NSString *const kDiscoverMovieRouteName;
extern NSString *const kMovieDetailRouteName;
extern NSString* const kGenreMovieRouteName;
extern NSString* const kConfigurationRouteName;

@interface MOURESTManager : NSObject

+ (MOURESTManager*)sharedInstance;
- (void)config;
- (void)getConfigurationWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
- (void)getGenresWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
- (void)getMovies:(NSInteger)page success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
- (void)getMovieDetail:(NSString*)id success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
