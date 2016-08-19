//
//  MOUIntroViewController.h
//  MovieOnUp
//
//  Created by Mark Smith on 14/08/2016.
//  Copyright © 2016 ___MARK_SMITH___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MOUIntroViewController;

@protocol MOUIntroViewControllerDelegate <NSObject>

- (void)introViewControllerDidFinish:(MOUIntroViewController*)introViewController;

@end

@interface MOUIntroViewController : UIViewController

@property (nonatomic, weak) id<MOUIntroViewControllerDelegate> delegate;

@end
