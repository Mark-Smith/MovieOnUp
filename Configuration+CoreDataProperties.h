//
//  Configuration+CoreDataProperties.h
//  
//
//  Created by Mark Smith on 17/08/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Configuration.h"

NS_ASSUME_NONNULL_BEGIN

@interface Configuration (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *images_base_url;
@property (nullable, nonatomic, retain) id images_backdrop_sizes;
@property (nullable, nonatomic, retain) id images_poster_sizes;

@end

NS_ASSUME_NONNULL_END
