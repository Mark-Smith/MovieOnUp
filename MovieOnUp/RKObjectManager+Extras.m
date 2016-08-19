//
//  RKObjectManager+Extras.m
//  MovieOnUp
//
//  Created by Mark Smith on 13/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import "RKObjectManager+Extras.h"
#import "definitions.h"

@implementation RKObjectManager (Extras)

- (NSMutableURLRequest*)myRequestWithPathForRouteNamed:(NSString*)routeName object:(id)object parameters:(NSDictionary*)parameters {
    NSMutableDictionary *mutableParams = parameters.mutableCopy;
    mutableParams[@"api_key"] = kTMDbAPIKey;
    return [self requestWithPathForRouteNamed:routeName object:object parameters:mutableParams.copy];
}

- (void)myGetObjectsAtPathForRouteNamed:(NSString *)routeName object:(id)object parameters:(NSDictionary *)parameters success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure {
    
    NSMutableDictionary *mutParams;
    if (!parameters) {
        mutParams = [NSMutableDictionary dictionary];
    } else {
        mutParams = parameters.mutableCopy;
    }
    mutParams[@"api_key"] = kTMDbAPIKey;
    
    [self getObjectsAtPathForRouteNamed:routeName object:object parameters:mutParams.copy success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

@end
