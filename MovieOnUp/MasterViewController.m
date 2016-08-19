//
//  MasterViewController.m
//  MovieOnUp
//
//  Created by Mark Smith on 14/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <RestKit/RestKit.h>
#import "MOURESTManager.h"
#import "RKObjectManager+Extras.h"
#import "UIView+Toast.h"
#import "UIView+ToastExtras.h"
#import "MOUSummaryCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Configuration.h"
#import "MOUCoreDataHelper.h"

#define kHeadsUpFailedToGetMovies @"COULD_NOT_RETRIEVE_MOVIES"

@interface MasterViewController () <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
// see https://www.raywenderlich.com/999/core-data-tutorial-for-ios-how-to-use-nsfetchedresultscontroller

@property (assign) NSInteger curPage;
@property (nonatomic, strong) NSString *imagesBaseUrl;
@property (nonatomic, strong) NSString *thumbnailSize;

@end

@implementation MasterViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    /*UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;*/
    
    // clear the cache. why?
    [[MOUCoreDataHelper sharedInstance] clearManagedObjectContextCacheForEntity:@"MovieSummary" withId:-1];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.navigationItem.leftBarButtonItem = nil;
    
    // for table view paging
    self.curPage = 1;
    
    // get configuration
    [[MOURESTManager sharedInstance] getConfigurationWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self setupConfiguration];
        
        // get genres
        [[MOURESTManager sharedInstance] getGenresWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            // get movies
            [[MOURESTManager sharedInstance] getMovies:self.curPage success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                
                // we now have enough info to be able to display
                
                [self.navigationController.view makeToast:@"Movies Loaded"];
                
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                
                [self.navigationController.view makeToast:@"Failed to Load Movies"];
                
            }];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            [self.navigationController.view makeToast:@"Failed to Load Movies"];
            
        }];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        [self.navigationController.view makeToast:@"Failed to Load Movies"];
    }];
    
}

- (void)setupConfiguration {
    
    // From TMDb docs: To build an image URL, you will need 3 pieces of data. The base_url, size and file_path. Simply combine them all and you will have a fully qualified URL. Here’s an example URL:http://image.tmdb.org/t/p/w500/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg
    
    // construct the thumbnail base url
    NSManagedObject *configMO = [[MOUCoreDataHelper sharedInstance] getConfigMO];
    self.imagesBaseUrl = [[configMO valueForKey:@"images_base_url"] description];
    //NSArray *backdropsSizes = [self.configMO valueForKey:@"images_backdrop_sizes"];
    NSArray *posterSizes = [configMO valueForKey:@"images_poster_sizes"];
    self.thumbnailSize = posterSizes[4];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

// http://stackoverflow.com/a/25896529
- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]]
        && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] movieSummaryMO] == nil)) {
        
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
        
    } else {
        
        return NO;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    //[newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
        
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


- (IBAction)refresh:(id)sender {
    // Reload the data
    
    self.curPage = 1;
    
    [[MOURESTManager sharedInstance] getMovies:self.curPage success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.navigationController.view makeToast:@"Movies loaded"];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.navigationController.view makeToast:@"Failed to Load Movies"];
    }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *movieSummaryMO = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setMovieSummaryMO:movieSummaryMO];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numRowsInSection = [[self.fetchedResultsController sections] count];
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger numOfRows = [sectionInfo numberOfObjects];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MOUSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SummaryCell" forIndexPath:indexPath];
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self configureCell:cell withObject:object forIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(MOUSummaryCell *)cell withObject:(NSManagedObject *)object forIndexPath:(NSIndexPath*)indexPath {

    cell.title.text = [[object valueForKey:@"title"] description];
    cell.releaseYear.text = [[object valueForKey:@"release_date"] description];
    
    // cludge - should be using restkit stored date tansformer
    NSDate *date = [object valueForKey:@"release_date"];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger year = [components year];
    cell.releaseYear.text = [@(year) stringValue];
    //self.popularity.text = [NSString stringWithFormat:@"Popularity - %@", [[self.movieSummaryMO valueForKey:@"popularity"] description]];
    //cell.overview.text = [[object valueForKey:@"overview"] description];
    NSNumber *popNum = [object valueForKey:@"popularity"];
    cell.popularity.text = [NSString stringWithFormat:@"Popularity - %.2f", [popNum floatValue]];
    
    // determine genres
    NSArray *genreIDs = [object valueForKey:@"genre_ids"];
    
    NSArray *genreNames = [[MOUCoreDataHelper sharedInstance] getGenresWithGenreIDs:genreIDs];
    
    // construct image url
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", self.imagesBaseUrl, self.thumbnailSize, [[object valueForKey:@"poster_path"] description]];
    
    [cell.activityIndicator startAnimating];
    
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    // see https://github.com/rs/SDWebImage
 
    [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [cell.activityIndicator stopAnimating];
    }];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *managedObjectContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MovieSummary" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entityDesc];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:100];
    [fetchRequest setFetchLimit:20];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:YES];
    [fetchRequest setSortDescriptors:@[sd]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    NSArray *entities = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"%lu",(unsigned long)entities.count);
    
	//NSError *error = nil;
    [NSFetchedResultsController deleteCacheWithName:nil];
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withObject:anObject forIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        self.curPage++;
        [[MOURESTManager sharedInstance] getMovies:self.curPage success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.navigationController.view makeToast:@"Failed to Load Movies"];
        }];
    }
}


@end
