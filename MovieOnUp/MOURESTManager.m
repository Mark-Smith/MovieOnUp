//
//  MOURESTManager.m
//  RoamPA
//
//  Created by Mark Smith on 18/02/2016.
//  Copyright © 2016 ___ROAMPA___. All rights reserved.
//

#import "MOURESTManager.h"
#import "Genre.h"
#import "MovieSummary.h"
#import "MovieDetail.h"
#import "Configuration.h"
#import "definitions.h"
#import "RKObjectManager+Extras.h"


NSString *const kDiscoverMovieRouteName = @"DISCOVER_MOVIE";
NSString *const kMovieDetailRouteName = @"MOVIE_DETAIL_ROUTE";
NSString *const kGenreMovieRouteName = @"GENRE_MOVIE_ROUTE";
NSString *const kConfigurationRouteName = @"CONFIGURATION_ROUTE";

@interface MOURESTManager ()

@end

@implementation MOURESTManager

+ (MOURESTManager*)sharedInstance
{
    static MOURESTManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[MOURESTManager alloc] init];
    });
    return _sharedInstance;
}

- (void)config {
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"MovieOnUp" ofType:@"momd"]];

    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // create the persistent store
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"RoamPA.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (!persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
        return; // TODO: not sure how to report error or exit app
    }

    // create RESTKit object manager
    NSURL *baseURL = [NSURL URLWithString:kWebServerURL];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    objectManager.managedObjectStore = managedObjectStore;
    [RKObjectManager setSharedManager:objectManager];
    
    
    
    //--------------- Transformers -------------------
    
    // form TMDb: "release_date": "2016-08-03"
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    //dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    [RKObjectMapping setPreferredDateFormatter:dateFormatter];
    NSDateFormatter *formatter = [RKObjectMapping preferredDateFormatter];

    
    
    
    //--------------- Entity Mappings --------------
    
    // Configuration mapping
    RKEntityMapping *configurationEM = [RKEntityMapping mappingForEntityForName:@"Configuration" inManagedObjectStore:managedObjectStore];
    [configurationEM addAttributeMappingsFromDictionary:@{
                                                          @"images.base_url":@"images_base_url",
                                                          @"images.poster_sizes":@"images_poster_sizes",
                                                          @"images.backdrop_sizes":@"images_backdrop_sizes"
                                                          }];
    
    // Genre mapping
    RKEntityMapping *genreEM = [RKEntityMapping mappingForEntityForName:@"Genre" inManagedObjectStore:managedObjectStore];
    [genreEM addAttributeMappingsFromDictionary:@{@"id":@"id",@"name":@"name"}];
    genreEM.identificationAttributes = @[@"id"];
    
    // Movie Summary mapping
    RKEntityMapping *movieSummaryEM = [RKEntityMapping mappingForEntityForName:@"MovieSummary" inManagedObjectStore:managedObjectStore];
    [movieSummaryEM addAttributeMappingsFromArray:@[
                                                     @"poster_path",
                                                     @"release_date",
                                                     @"genre_ids",
                                                     @"title",
                                                     @"popularity",
                                                     @"backdrop_path"
                                                     ]];
    [movieSummaryEM addAttributeMappingsFromDictionary:@{@"id":@"id"}];
    movieSummaryEM.identificationAttributes = @[@"id"];
    
    // Movie Detail mapping
    RKEntityMapping *movieDetailEM = [RKEntityMapping mappingForEntityForName:@"MovieDetail" inManagedObjectStore:managedObjectStore];
    [movieDetailEM addAttributeMappingsFromArray:@[
                                                    @"backdrop_path",
                                                    @"genres",
                                                    @"popularity",
                                                    @"poster_path",
                                                    @"release_date",
                                                    @"title",
                                                    @"overview"
                                                    ]];
    [movieDetailEM addAttributeMappingsFromDictionary:@{@"id":@"id"}];
     movieSummaryEM.identificationAttributes = @[@"id"];
    
    
    
    //------------- Add Mappings --------------------

    // add Genre mapping to Movie Detail mapping
    [movieDetailEM addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"results.genres" toKeyPath:@"results.genres" withMapping:genreEM]];
    
    
    
    // ----------- Response Descriptors -------------
    
    // Configuration response descriptor
    RKResponseDescriptor *configurationRD = [RKResponseDescriptor responseDescriptorWithMapping:configurationEM method:RKRequestMethodGET pathPattern:@"configuration" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [RKObjectManager.sharedManager addResponseDescriptor:configurationRD];
    
    // Movie Summary response descriptor
    RKResponseDescriptor *movieSummaryRD = [RKResponseDescriptor responseDescriptorWithMapping:movieSummaryEM method:RKRequestMethodGET pathPattern:@"discover/movie" keyPath:@"results" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [RKObjectManager.sharedManager addResponseDescriptor:movieSummaryRD];
     
     // Movie Detail response descriptor
     RKResponseDescriptor *movieDetailRD = [RKResponseDescriptor responseDescriptorWithMapping:movieDetailEM method:RKRequestMethodGET pathPattern:@"movie/:id" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
     [RKObjectManager.sharedManager addResponseDescriptor:movieDetailRD];
    
    
    
    // ----------- Routes -------------
    
    // route for Configuration
    [[RKObjectManager sharedManager].router.routeSet addRoute:[RKRoute routeWithName:kConfigurationRouteName pathPattern:@"configuration" method:RKRequestMethodGET]];
    
    // route for Movie genre
    [[RKObjectManager sharedManager].router.routeSet addRoute:[RKRoute routeWithName:kGenreMovieRouteName pathPattern:@"genre/movie/list" method:RKRequestMethodGET]];
    
    // route for Movie summary
    [[RKObjectManager sharedManager].router.routeSet addRoute:[RKRoute routeWithName:kDiscoverMovieRouteName pathPattern:@"discover/movie" method:RKRequestMethodGET]];

    // route for Movie detail
    [[RKObjectManager sharedManager].router.routeSet addRoute:[RKRoute routeWithName:kMovieDetailRouteName pathPattern:@"movie/:id" method:RKRequestMethodGET]];
    
    //---------------------------------
    
    
    // create contexts
    [managedObjectStore createManagedObjectContexts];
}

- (void)getConfigurationWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    [[RKObjectManager sharedManager] myGetObjectsAtPathForRouteNamed:kConfigurationRouteName
                                                              object:nil
                                                          parameters:nil
                                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                 success(operation, mappingResult);
                                                             }
                                                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                 failure(operation, error);
                                                             }];
}

- (void)getGenresWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    [[RKObjectManager sharedManager] myGetObjectsAtPathForRouteNamed:kDiscoverMovieRouteName
                                                              object:nil
                                                          parameters:nil
                                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                 success(operation, mappingResult);
                                                             }
                                                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                 failure(operation, error);
                                                             }];
}

- (void)getMovies:(NSInteger)page success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    [[RKObjectManager sharedManager] myGetObjectsAtPathForRouteNamed:kDiscoverMovieRouteName
                                                              object:nil
                                                          parameters:@{
                                                                       @"include_adult":@"true",
                                                                       @"page":@(page),
                                                                       @"sort_by":@"popularity.desc"
                                                                       }
                                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                 success(operation, mappingResult);
                                                             }
                                                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                 failure(operation, error);
                                                             }];
}

- (void)getMovieDetail:(NSString*)movieID success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    [[RKObjectManager sharedManager] myGetObjectsAtPathForRouteNamed:kMovieDetailRouteName
                                                              object:@{@"id":movieID}
                                                          parameters:nil
                                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                 success(operation, mappingResult);
                                                             }
                                                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                 failure(operation, error);
                                                             }];
}

@end
