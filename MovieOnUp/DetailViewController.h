//
//  DetailViewController.h
//  MovieOnUp
//
//  Created by Mark Smith on 14/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

