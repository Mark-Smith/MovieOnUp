//
//  MOUSummaryCell.h
//  MovieOnUp
//
//  Created by Mark Smith on 17/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOUSummaryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *popularity;
@property (weak, nonatomic) IBOutlet UILabel *releaseYear;
@property (strong, nonatomic) NSString *url;
@property (nonatomic, strong) NSString *thumbnailName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *genreCollectionView;

@end
