//
//  FlickrManager.h
//  drink-In-my-hand
//
//  Created by JUSTIN M FISCHER on 6/14/13.
//  Copyright (c) 2013 Fun Touch Apps, LLC. All rights reserved.
//

#import "ObjectiveFlickr.h"
#import "CBGPhotos.h"

@interface FlickrRequestInfo : NSObject

@property(nonatomic, strong) CBGPhotos *photos;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *photoId;
@property(nonatomic, strong) NSString *userInfo;
@property(nonatomic, strong) NSURL *userPhotoWebPageURL;

@end

@interface CBGFlickrManager : NSObject<OFFlickrAPIRequestDelegate>

@property(nonatomic, copy) void (^completionBlock)(FlickrRequestInfo *, NSError *);

@property(nonatomic, assign) bool isRunning;
@property(nonatomic, strong) OFFlickrAPIContext *flickrContext;
@property(nonatomic, strong) OFFlickrAPIRequest *flickrRequest;
@property(nonatomic, strong) FlickrRequestInfo *flickrRequestInfo;

@property(nonatomic, strong) NSDate *searchInvalidateCacheTimeout;
@property(nonatomic, strong) NSDate *searchQuitTimeout;


+ (CBGFlickrManager *) sharedManager;
- (void) randomPhotoRequest: (void (^)(FlickrRequestInfo *, NSError *)) completion;

@end

typedef enum {
    FlickrAPIRequestPhotoSearch = 1,
    FlickrAPIRequestPhotoSizes = 2,
    FlickrAPIRequestPhotoOwner = 3,
} FlickrAPIRequestType;

@interface FlickrAPIRequestSessionInfo : NSObject

@property(nonatomic, assign) FlickrAPIRequestType flickrAPIRequestType;

@end

