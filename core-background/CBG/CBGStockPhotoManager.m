//
//  CBGStockPhotoManager.m
//  drink-In-my-hand
//
//  Created by JUSTIN M FISCHER on 6/25/13.
//  Copyright (c) 2013 Fun Touch Apps, LLC. All rights reserved.
//

#import "CBGStockPhotoManager.h"
#import "CBGUtil.h"
#import "CBGConstants.h"
#import "UIImage+ImageEffects.h"

@implementation CBGStockPhotoManager

static CBGStockPhotoManager *sharedManager = nil;

+ (CBGStockPhotoManager *) sharedManager {
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
        [self load];
	}
    
	return self;
}

- (void) load {
    NSArray *files = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"StockPhotos"];
    
    self.stockPhotoSet = [[NSMutableSet alloc] init];
    
    NSString *prefix;
    NSString *token;
    
    for (NSString *fileName in files) {
        prefix = [fileName lastPathComponent];
        
        token = [prefix substringWithRange:NSMakeRange(0, 3)];
        [self.stockPhotoSet addObject:token];
    }
}

- (void) randomStockPhoto: (void (^)(CBGPhotos *)) completion {
    
    CBGPhotos *photos = [[CBGPhotos alloc] init];
    
    dispatch_queue_t queue = dispatch_queue_create(kAsyncQueueLabel, NULL);
    dispatch_queue_t main = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        int stockPhotoCount = ([self.stockPhotoSet count] - 1);
        int randomIndex = [CBGUtil getRandomIntBetweenLow:0 andHigh:stockPhotoCount];
    
        NSString *imagePath = [NSString stringWithFormat:@"%@/%03d-StockPhoto-320x568.png", @"StockPhotos", randomIndex];
    
        photos.photo = [UIImage imageNamed:imagePath];
        photos.photoWithEffects = [photos.photo applyLightEffect];
        
        dispatch_async(main, ^{
            completion(photos);
        });
    });
}

@end
