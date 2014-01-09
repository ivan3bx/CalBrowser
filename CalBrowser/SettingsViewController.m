//
//  SettingsViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/12/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "SettingsViewController.h"
#import "CABLLocations.h"
#import "CABLConfig.h"

@interface SettingsViewController () {
    CABLConfig *_config;
    CABLLocations *_locations;
}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_config = [CABLConfig sharedInstance];
    _locations = [[CABLLocations alloc] init];
    
    [self addParallaxEffect:self.backgroundImage];
}

-(void)addParallaxEffect:(UIImageView *)imageView
{
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                    type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-15);
    verticalMotionEffect.maximumRelativeValue = @(15);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-15);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [imageView addMotionEffect:group];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSString *city = _config.currentCity;
    NSString *loc = _config.currentLocation;
    NSNumber *floor = _config.currentFloor;
    
    if ([_locations floorNumbersForLocation:loc].count == 1) {
        //
        // Simple location has one floor
        //
        self.editLocationButton.titleLabel.text = [NSString stringWithFormat:@"%@ - (%@)", city, loc];
    } else {
        //
        // Not so simple ; specify the floor
        //
        self.editLocationButton.titleLabel.text = [NSString stringWithFormat:@"%@ - (%@-%@)", city, loc, floor];
    }
}

@end
