//
//  FlickrManager.m
//  drink-In-my-hand
//
//  Created by JUSTIN M FISCHER on 6/14/13.
//  Copyright (c) 2013 Fun Touch Apps, LLC. All rights reserved.
//

#import "CBGFlickrManager.h"
#import "CBGLocationManager.h"
#import "CBGUtil.h"
#import "CBGConstants.h"

#import "UIImage+ImageEffects.h"
#import "UIImage+Resize.h"

@implementation FlickrRequestInfo

- (id) init {
	self = [super init];
	
    if (self != nil) {
        self.photos = [[CBGPhotos alloc] init];
    }
    
    return self;
}

@end

@implementation FlickrAPIRequestSessionInfo
@end

@implementation CBGFlickrManager

static CBGFlickrManager *sharedManager = nil;

+ (CBGFlickrManager *) sharedManager {
    @synchronized (self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    
    return sharedManager;
}

-(id) init {
	self = [super init];
	
    if (self != nil) {
        self.flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_API_KEY sharedSecret:OBJECTIVE_FLICKR_API_SHARED_SECRET];
        
        FlickrAPIRequestSessionInfo *sessionInfo = [FlickrAPIRequestSessionInfo alloc];
        sessionInfo.flickrAPIRequestType = FlickrAPIRequestPhotoSearch;
        
        self.flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
        self.flickrRequest.sessionInfo = sessionInfo;
                
        [self.flickrRequest setDelegate:self];
	}
    
	return self;
}

- (void) randomPhotoRequest: (void (^)(FlickrRequestInfo *, NSError *)) completion {
    if(!self.isRunning) {
        self.isRunning = true;
        self.completionBlock = completion;
        
        [self performSelector:@selector(stopFlickrManager:) withObject:nil afterDelay:kFlickrSearchQuitTimeoutDurationInSeconds];
        [self photoRequest];
    }
}

- (void) photoRequest {
    if (![self.flickrRequest isRunning]) {
        ((FlickrAPIRequestSessionInfo *)self.flickrRequest.sessionInfo).flickrAPIRequestType = FlickrAPIRequestPhotoSearch;
        
        NSString *lat = [[NSNumber numberWithDouble:[CBGLocationManager sharedManager].locationBestEffort.coordinate.latitude] stringValue];
        NSString *lon = [[NSNumber numberWithDouble:[CBGLocationManager sharedManager].locationBestEffort.coordinate.longitude] stringValue];
        
        [self.flickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:[NSDictionary dictionaryWithObjectsAndKeys:lat, @"lat", lon, @"lon", KFlickrSearchRadiusInMiles, @"radius", @"mi", @"radius_units", KFlickrSsearchTags, @"tags", @"tag_mode", @"any", KFlickrSearchLicense, @"license", @"500", @"per_page", nil]];
    }
}

- (void) stopFlickrManager:(id) sender {
    NSError *error = [NSError errorWithDomain:@kAsyncQueueLabel code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"FlickrManager timeout. No photos returned.", NSLocalizedDescriptionKey, nil]];
    
    self.completionBlock(nil, error);
    
    [self cleanUpFlickrManager];
}

- (void) cleanUpFlickrManager {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopFlickrManager:) object:nil];
    [self.flickrRequest cancel];
    
    self.isRunning = false;
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
    if(((FlickrAPIRequestSessionInfo *)inRequest.sessionInfo).flickrAPIRequestType == FlickrAPIRequestPhotoSearch) {
    
        self.flickrRequestInfo = [[FlickrRequestInfo alloc] init];
        
        NSArray *photos = [inResponseDictionary valueForKeyPath:@"photos.photo"];
                
        int numberOfPhotos = [photos count] - 1;
        
        if(numberOfPhotos >= 0) {
            
            int randomPhotoIndex = [CBGUtil getRandomIntBetweenLow:0 andHigh:numberOfPhotos];
            
            NSDictionary *photoDict = [photos objectAtIndex:randomPhotoIndex];
            NSURL *photoURL = [self.flickrContext photoSourceURLFromDictionary:photoDict size:OFFlickrLargeSize];
                        
            NSString *photoId = (NSString *)[photoDict objectForKey:@"id"];
            NSString *owner = (NSString *)[photoDict objectForKey:@"owner"];
            
            self.flickrRequestInfo.userPhotoWebPageURL = [self.flickrContext photoWebPageURLFromDictionary:photoDict];
            
            dispatch_queue_t queue = dispatch_queue_create(kAsyncQueueLabel, NULL);
            dispatch_queue_t main = dispatch_get_main_queue();
            
            dispatch_async(queue, ^{
                
                self.flickrRequestInfo.photos.photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
                
                dispatch_async(main, ^{

                    self.flickrRequestInfo.userId = owner;
                    self.flickrRequestInfo.photoId = photoId;
                    
                    if (![self.flickrRequest isRunning]) {
                        ((FlickrAPIRequestSessionInfo *)self.flickrRequest.sessionInfo).flickrAPIRequestType = FlickrAPIRequestPhotoSizes;
                        
                        [self.flickrRequest callAPIMethodWithGET:@"flickr.photos.getSizes" arguments:[NSDictionary dictionaryWithObjectsAndKeys:photoId, @"photo_id", nil]];
                    }
                });
            });
        } else {
            NSError *error = [NSError errorWithDomain:@kAsyncQueueLabel code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"FlickrManager did not return any photos.", NSLocalizedDescriptionKey, nil]];
            
            self.completionBlock(nil, error);
            
            [self cleanUpFlickrManager];
        }

    } else if(((FlickrAPIRequestSessionInfo *)inRequest.sessionInfo).flickrAPIRequestType == FlickrAPIRequestPhotoSizes) {
                
        NSDictionary *photoSizes = [inResponseDictionary valueForKeyPath:@"sizes.size"];
        
        bool found = false;
        
        for (NSDictionary *size in photoSizes) {
            if([[NSString stringWithString:(NSString *)[size objectForKey:@"label"]] isEqualToString:@"Large"]) {
                found = true;
                
                if (![self.flickrRequest isRunning]) {
                    ((FlickrAPIRequestSessionInfo *)self.flickrRequest.sessionInfo).flickrAPIRequestType = FlickrAPIRequestPhotoOwner;
                    
                    [self.flickrRequest callAPIMethodWithGET:@"flickr.people.getInfo" arguments:[NSDictionary dictionaryWithObjectsAndKeys:self.flickrRequestInfo.userId, @"user_id", nil]];
                }
                
                break;
            }
        }
        
        if(!found) {
            [self photoRequest];
        }
            
    } else if(((FlickrAPIRequestSessionInfo *)inRequest.sessionInfo).flickrAPIRequestType == FlickrAPIRequestPhotoOwner) {

        NSDictionary *person = [inResponseDictionary valueForKeyPath:@"person"];
        NSString *username =  [person valueForKeyPath:@"username._text"];
        
        NSString *userInfo = @"";
        
        if([username length]) {
            userInfo = [NSString stringWithFormat:@"© %@", username];
        }
        
        self.flickrRequestInfo.userInfo = userInfo;
        
        dispatch_queue_t queue = dispatch_queue_create(kAsyncQueueLabel, NULL);
        dispatch_queue_t main = dispatch_get_main_queue();
        
        dispatch_async(queue, ^{
    
            [self resizeCropPhoto];
                    
            dispatch_async(main, ^{
                self.completionBlock(self.flickrRequestInfo, nil);
                
                [self cleanUpFlickrManager];
            });
        });
    }
}

- (void) resizeCropPhoto {
    float goldenRatio = 1.6;
    
    int const constWidth = 320;
    int const constHeight = 568;
    
    int newWidth;
    
    int width;
    int height;
    
    float ratio;
    
    CGSize newSize;
    
    width = self.flickrRequestInfo.photos.photo.size.width;
    height = self.flickrRequestInfo.photos.photo.size.height;
    
    ratio = ((float)width / (float)height);
    
    newWidth = roundf((constHeight * ratio));
    
    newSize = CGSizeMake(newWidth, constHeight);
    
    UIImage *resizedImage =  [self.flickrRequestInfo.photos.photo resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
    
    int cropX = ((newWidth / 2) - (constWidth / 2) * (goldenRatio - 1));
    
    UIImage *croppedImage = [resizedImage croppedImage:CGRectMake(cropX, 0, constWidth, constHeight)];
    
    self.flickrRequestInfo.photos.photo = croppedImage;
    self.flickrRequestInfo.photos.photoWithEffects = [croppedImage applyLightEffect];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
    self.completionBlock(nil, inError);
    
    [self cleanUpFlickrManager];
}

@end
