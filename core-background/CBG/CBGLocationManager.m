//
//  LocationManager.m
//  drink-In-my-hand
//
//  Created by JUSTIN M FISCHER on 6/21/13.
//  Copyright (c) 2013 Fun Touch Apps, LLC. All rights reserved.
//

#import "CBGLocationManager.h"
#import "CBGConstants.h"

@implementation CBGLocationManager

static CBGLocationManager *sharedManager = nil;

+ (CBGLocationManager *) sharedManager {
    @synchronized (self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    
    return sharedManager;
}

- (id) init {
	self = [super init];
	
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        
        self.locationInvalidateCacheTimeout = [[NSDate alloc] initWithTimeIntervalSinceNow:-kLocationInvalidateCacheTimeoutDurationInSeconds];
    }
    
	return self;
}

- (void) locationRequest: (void (^)(CLLocation *, NSError *)) completion {
    if([CLLocationManager locationServicesEnabled]) {
        
        if(!self.isRunning) {
        
            NSTimeInterval timeout = [self.locationInvalidateCacheTimeout timeIntervalSinceNow];
            
            if(timeout < 0.0) {
                self.isRunning = true;
                self.locationQuitTimeout = [NSDate date];
                
                self.completionBlock = completion;
            
                self.locationManager.delegate = self;
                
                [self.locationManager startUpdatingLocation];
                [self performSelector:@selector(stopLocationManager:) withObject:nil afterDelay:kLocationQuitTimeoutDurationInSeconds];
            } else {
                completion(self.locationBestEffort, [self validate]);
            }
        }
    } else {
        NSError *error = [NSError errorWithDomain:@kAsyncQueueLabel code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Authorize location services.", NSLocalizedDescriptionKey, nil]];
        
        completion(self.locationBestEffort, error);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSTimeInterval locationTimestamp = -[newLocation.timestamp timeIntervalSinceNow];
    
    if (locationTimestamp > 5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    if (self.locationBestEffort == nil || self.locationBestEffort.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        self.locationBestEffort = newLocation;
        
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            self.locationInvalidateCacheTimeout = [[NSDate date] initWithTimeIntervalSinceNow:kLocationInvalidateCacheTimeoutDurationInSeconds];
            
            [self stopLocationManager: nil];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopLocationManager:) object:nil];
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stopLocationManager: error];
}

- (NSError *) validate {
    if(self.locationBestEffort.coordinate.latitude == 0.0 && self.locationBestEffort.coordinate.longitude == 0.0) {
        NSError *error = [NSError errorWithDomain:@kAsyncQueueLabel code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Location information not available.", NSLocalizedDescriptionKey, nil]];
        
        return error;
    } else {
        return nil;
    }
}

- (void) stopLocationManager:(NSError *) error {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    
    if(error) {
        self.completionBlock(self.locationBestEffort, error);
    } else {
        self.completionBlock(self.locationBestEffort, [self validate]);
    }
    
    self.isRunning = false;
}

@end
