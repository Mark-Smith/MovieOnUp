//
//  DetailViewController.m
//  MovieOnUp
//
//  Created by Mark Smith on 14/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import "DetailViewController.h"
#import "MOUIntroViewController.h"
#import "MOUGenreCollectionViewCell.h"
#import "MOURESTManager.h"
#import "UIView+Toast.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Configuration.h"
#import "MovieDetail.h"
#import "MOUCoreDataHelper.h"

@interface DetailViewController () <MOUIntroViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *popularity;
@property (weak, nonatomic) IBOutlet UILabel *releaseYear;
@property (weak, nonatomic) IBOutlet UILabel *theTitle;
@property (weak, nonatomic) IBOutlet UITextView *overview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *posterActivityIndicator;
@property (nonatomic, strong) NSString *movieID;
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (weak, nonatomic) IBOutlet UIView *defaultOverviewPlaceholder;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *overviewActivityIndicator;


@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setMovieSummaryMO:(id)movieSummaryMO {
    if (_movieSummaryMO != movieSummaryMO) {
        _movieSummaryMO = movieSummaryMO;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    
    // Update the user interface with whatever data is available from the master view. Other fields will populated once data has been retrieved from the server.
    if (self.movieSummaryMO) {
        self.theTitle.text = [[self.movieSummaryMO valueForKey:@"title"] description];
        //self.popularity.text = [[self.movieSummaryMO valueForKey:@"popularity"] description];
        
        // cludge - should be using restkit stored date tansformer
        NSDate *date = [self.movieSummaryMO valueForKey:@"release_date"];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
        NSInteger year = [components year];
        self.releaseYear.text = [@(year) stringValue];
        
        NSNumber *popNum = [self.movieSummaryMO valueForKey:@"popularity"];
        self.popularity.text = [NSString stringWithFormat:@"Popularity - %.2f", [popNum floatValue]];
        
        self.movieID = [[self.movieSummaryMO valueForKey:@"id"] description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    // hack to get round iPad UITextView not responding to IB setting
    self.overview.editable = YES;
    self.overview.font = [UIFont systemFontOfSize:18.];
    self.overview.editable = NO;
    
    //If in portrait mode, display the master view
    /*if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [self.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action withObject:self.navigationItem];
    }*/
    
    if (!self.movieID) {
        
        // we have most likely started in split screen mode. in split screen mode, detail view controller appears without any master cell being selected yet, i.e. iPad, or iPhone 6s Plus in landscape mode.
        //self.view.hidden = TRUE;
        [self.posterActivityIndicator stopAnimating];
        [self.overviewActivityIndicator stopAnimating];
        self.defaultOverviewPlaceholder.hidden = FALSE;
        return;
    }
    
    //self.view.hidden = FALSE;
    
    [self.posterActivityIndicator startAnimating];
    [self.overviewActivityIndicator startAnimating];
    self.defaultOverviewPlaceholder.hidden = TRUE;
    
    [[MOURESTManager sharedInstance] getMovieDetail:self.movieID success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self.posterActivityIndicator stopAnimating];
        [self.overviewActivityIndicator stopAnimating];
        self.defaultOverviewPlaceholder.backgroundColor = [UIColor clearColor];
        
        //[self.navigationController.view makeToast:@"Movies Loaded"];
        MovieDetail *movieMO =  mappingResult.array[0];

        self.overview.text = [[movieMO valueForKey:@"overview"] description];
        
        // construct the URL for the poster
        NSString *posterPath = [[movieMO valueForKey:@"poster_path"] description];
        NSManagedObject *configMO = [[MOUCoreDataHelper sharedInstance] getConfigMO];
        NSArray *posterSizes = [configMO valueForKey:@"images_poster_sizes"];
        NSString *posterSize = posterSizes[3];
        NSString *baseUrl = [[configMO valueForKey:@"images_base_url"] description];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, posterSize, posterPath];
        
        [self.poster sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            [self.posterActivityIndicator stopAnimating];
            //[self.tableView setNeedsDisplay];
        }];
        
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        [self.posterActivityIndicator stopAnimating];
        [self.navigationController.view makeToast:@"Failed to Movie Details"];
        
    }];
    
    // Configure genre flow layout
    /*self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.flowLayout setItemSize:CGSizeMake(191, 160)];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.flowLayout.minimumInteritemSpacing = 0.0f;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    self.collectionView.bounces = YES;
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView setShowsVerticalScrollIndicator:NO];*/
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICOllectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;//[dataArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MOUGenreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"genreCell" forIndexPath:indexPath];
    cell.genre.text = [NSString stringWithFormat:@"%ld",(long)indexPath.item];
    return cell;
}


#pragma mark - MOUIntroViewControllerDelegate methods

- (void)introViewControllerDidFinish:(MOUIntroViewController*)introViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
