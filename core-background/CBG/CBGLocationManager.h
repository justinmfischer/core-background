//
//  LocationManager.h
//  drink-In-my-hand
//
//  Created by JUSTIN M FISCHER on 6/21/13.
//  Copyright (c) 2013 Fun Touch Apps, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CBGLocationManager : NSObject<CLLocationManagerDelegate>

@property(nonatomic, copy) void (^completionBlock)(CLLocation *, NSError *);

@property(nonatomic, assign) bool isRunning;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *locationBestEffort;
@property(nonatomic, strong) NSDate *locationInvalidateCacheTimeout;
@property(nonatomic, strong) NSDate *locationQuitTimeout;

+ (CBGLocationManager *) sharedManager;
- (void) locationRequest: (void (^)(CLLocation *, NSError *)) completion;

@end
