//
//  RKObjectManager+Extras.h
//  MovieOnUp
//
//  Created by Mark Smith on 13/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import <RestKit/RestKit.h>

@interface RKObjectManager (Extras)

- (NSMutableURLRequest*)myRequestWithPathForRouteNamed:(NSString*)routeName object:(id)object parameters:(NSDictionary*)parameters;

- (void)myGetObjectsAtPathForRouteNamed:(NSString *)routeName object:(id)object parameters:(NSDictionary *)parameters success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;

@end
