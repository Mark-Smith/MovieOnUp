//
//  MovieDetail+CoreDataProperties.h
//  
//
//  Created by Mark Smith on 18/08/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MovieDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface MovieDetail (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *backdrop_path;
@property (nullable, nonatomic, retain) id genres;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *overview;
@property (nullable, nonatomic, retain) NSNumber *popularity;
@property (nullable, nonatomic, retain) NSString *poster_path;
@property (nullable, nonatomic, retain) NSDate *release_date;
@property (nullable, nonatomic, retain) NSString *title;

@end

NS_ASSUME_NONNULL_END
