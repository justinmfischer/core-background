//
//  ViewController.m
//  core-background
//
//  Created by JUSTIN M FISCHER on 6/28/13.
//  Copyright (c) 2013 Justin M Fischer. All rights reserved.
//

#import "ViewController.h"
#import "CBG.h"

//Timer
#define kTimerIntervalInSeconds 10

@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];

    //ScrollView content size
    if([CBGUtil is4InchIphone]) {
        self.scrollView.contentSize = CGSizeMake(320, 720);
    } else {
        self.scrollView.contentSize = CGSizeMake(320, 580);
    }
    
    //Initial stock photos from bundle
    [[CBGStockPhotoManager sharedManager] randomStockPhoto:^(CBGPhotos * photos) {
        [self crossDissolvePhotos:photos withTitle:@""];
    }];
    
    //Retrieve location and content from Flickr
    [self retrieveLocationAndUpdateBackgroundPhoto];
    
    //Schedule updates
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerIntervalInSeconds target:self selector:@selector(retrieveLocationAndUpdateBackgroundPhoto)userInfo:nil repeats:YES];
}

- (void) retrieveLocationAndUpdateBackgroundPhoto {
    
    //Location
    [[CBGLocationManager sharedManager] locationRequest:^(CLLocation * location, NSError * error) {
        
        [self.activityIndicator startAnimating];
        
        if(!error) {
            
            //Flickr 
            [[CBGFlickrManager sharedManager] randomPhotoRequest:^(FlickrRequestInfo * flickrRequestInfo, NSError * error) {
                
                if(!error) {
                    self.userPhotoWebPageURL = flickrRequestInfo.userPhotoWebPageURL;
                    
                    [self crossDissolvePhotos:flickrRequestInfo.photos withTitle:flickrRequestInfo.userInfo];
                    [self.activityIndicator stopAnimating];
                } else {
                    
                    //Error : Stock photos
                    [[CBGStockPhotoManager sharedManager] randomStockPhoto:^(CBGPhotos * photos) {
                        [self crossDissolvePhotos:photos withTitle:@""];
                    }];
                    
                    [self.activityIndicator stopAnimating];
                    
                    NSLog(@"Flickr: %@", error.description);
                }
            }];
        } else {
            
            //Error : Stock photos
            [[CBGStockPhotoManager sharedManager] randomStockPhoto:^(CBGPhotos * photos) {
                [self crossDissolvePhotos:photos withTitle:@""];
            }];
            
            [self.activityIndicator stopAnimating];
            
            NSLog(@"Location: %@", error.description);
        }
    }];
}

- (void) crossDissolvePhotos:(CBGPhotos *) photos withTitle:(NSString *) title {
    [UIView transitionWithView:self.backgroundPhoto duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        self.backgroundPhoto.image = photos.photo;
        self.backgroundPhotoWithImageEffects.image = photos.photoWithEffects;
        self.photoUserInfoBarButton.title = title;
        
    } completion:NULL];
}

- (IBAction) launchFlickrUserPhotoWebPage:(id) sender {
    if([self.photoUserInfoBarButton.title  length] > 0) {
        [[UIApplication sharedApplication] openURL:self.userPhotoWebPageURL];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= 80.0) {
        float percent = (scrollView.contentOffset.y / 80.0);
        
        self.backgroundPhotoWithImageEffects.alpha = percent;
        
    } else if (scrollView.contentOffset.y > 80.0){
        self.backgroundPhotoWithImageEffects.alpha = 1;
    } else if (scrollView.contentOffset.y < 0) {
        self.backgroundPhotoWithImageEffects.alpha = 0;
    }
}

@end
