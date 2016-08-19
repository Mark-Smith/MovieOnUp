//
//  MOUSummaryRecord.h
//  MovieOnUp
//
//  Created by Mark Smith on 18/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MOUSummaryRecord : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *popularity;
@property (nonatomic, strong) NSString *releaseYear;
@property (nonatomic, strong) NSString *thumbnailName;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIImage *thumbnail;

@end
