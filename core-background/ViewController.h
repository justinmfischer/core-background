//
//  ViewController.h
//  core-background
//
//  Created by JUSTIN M FISCHER on 6/28/13.
//  Copyright (c) 2013 Justin M Fischer. All rights reserved.
//

@interface ViewController : UIViewController<UIScrollViewDelegate>

@property(nonatomic, weak) NSTimer *timer;
@property(nonatomic, strong) NSURL *userPhotoWebPageURL;
@property(nonatomic, strong) IBOutlet UIImageView *backgroundPhoto;
@property(nonatomic, strong) IBOutlet UIImageView *backgroundPhotoWithImageEffects;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *photoUserInfoBarButton;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (IBAction) launchFlickrUserPhotoWebPage:(id) sender;

@end
