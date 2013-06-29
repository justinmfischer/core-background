CoreBackground is a set of Objective-C classes inspired by the [iOS Yahoo Weather](https://itunes.apple.com/us/app/yahoo!-weather/id628677149?mt=8) App.

This lightweight framework makes it easy to add gorgeous location-based public photos from [Flickr](http://www.flickr.com/services/developer/) to any iOS iPhone App. Additionally as one scrolls over the foreground content the background image is applied a Gaussian blur light effect. This provides for an engaging location-based UX while at the same time providing a canvas to apply readable content to the foreground. Furthermore CoreBackground is a non-blocking event based Objective-C block API and All rendering occurs in backing stores to preserve the main run loop. Make it be the foundation of your next project today.

&copy; Copyrights

Since CoreBackground uses public licenses to retrieve content from Flickr we display the owner’s copyright information along with a link to encourage discoverability.

## Example
![Example](http://funtouchapps.com/Photos/CBG.gif)

```Objective-C
Note : Quality shown above is low due to animated gif dithering.
```

## Getting Started
CoreBackground is comprised of 3 main Objective-C singleton managers all within the CBG header file `(CBG.h)`.

* **CGBLocationManager** : _Provides cacheable location-based information._
* **CGBFlickrManager** : _Provides cacheable Flickr API content._
* **CGBStockPhotoManager** : _Provides local image content in case of reachability issues._

Prior to using CoreBackground a valid Flickr API key and shared secret is required. The sample project will not successfully build without this information. The Flickr API key and shared secret can be obtained [here](http://www.flickr.com/services/apps/create/apply/). As of this writing Flickr restricts free (Non-Commercial) accounts to 3600 request per hour. Please make the following modifications below.

```Objective-C
(CBGConstants.h)
```

```Objective-C
//Flickr Auth
#define OBJECTIVE_FLICKR_API_KEY @"Ch@ngeMe"
#define OBJECTIVE_FLICKR_API_SHARED_SECRET @"Ch@ngeMe"
```

The constants file also contains a value to provide searchable Flickr photo tags. The sample project uses “bike” and will match any comma separated values. Example: “bike,ride,outdoor”

```Objective-C
//Flickr Search
#define KFlickrSsearchTags @"bike"
```

## Code : Sample Project 

The CoreBackground sample project demonstrates how these Objective-C classes can be used to achieve location-based background content to drive discoverability and local engagement.

While one could subclass UIViewController to provide high orders of abstraction CoreBackground was specifically designed to be loosely coupled and not bound to a particular view hierarchy. This design pattern encourages community modifications and higher adoption rates.

```Objective-C
ViewController.m
```

```Objective-C
- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [[CBGStockPhotoManager sharedManager] randomStockPhoto:^(CBGPhotos * photos) {
        [self crossDissolvePhotos:photos withTitle:@""];
    }];
    
    [self retrieveLocationAndUpdateBackgroundPhoto];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerIntervalInSeconds target:self selector:@selector(retrieveLocationAndUpdateBackgroundPhoto) userInfo:nil repeats:YES];
}

- (void) retrieveLocationAndUpdateBackgroundPhoto {
    [[LocationManager sharedManager] locationRequest:^(CLLocation * location, NSError * error) {
                
        [self.activityIndicator startAnimating];
        
        if(!error) {        
            [[FlickrManager sharedManager] randomPhotoRequest:^(FlickrRequestInfo * flickrRequestInfo, NSError * error) {
                                
                if(!error) {
                    self.userPhotoWebPageURL = flickrRequestInfo.userPhotoWebPageURL;
                
                    [self crossDissolvePhotos:flickrRequestInfo.photos withTitle:flickrRequestInfo.userInfo];
                    [self.activityIndicator stopAnimating];
                } else {
                    
                    [[CBGStockPhotoManager sharedManager] randomStockPhoto:^(CBGPhotos * photos) {
                        [self crossDissolvePhotos:photos withTitle:@""];
                    }];
                    
                    [self.activityIndicator stopAnimating];
                    
                    NSLog(@"Flickr: %@", error.description);
                }
            }];
        } else {            
            
            [[CBGStockPhotoManager sharedManager] randomStockPhoto:^(CBGPhotos * photos) {
                [self crossDissolvePhotos:photos withTitle:@""];
            }];
            
            [self.activityIndicator stopAnimating];
            
            NSLog(@"LocationManager: %@", error.description);
        }
    }];
}

- (void) crossDissolvePhotos:(CBGPhotos *) photos withTitle:(NSString *) title {
    [UIView transitionWithView:self.backgroundPhoto duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        self.backgroundPhoto.image = photos.photo;
        self.backgroundPhotoWithImageEffects.image = photos.photoWithEffects;
        [self.photoUserInfoButton setTitle:title forState:UIControlStateNormal];
        
    } completion:NULL];
}

- (IBAction) launchFlickrUserPhotoWebPage:(id) sender {
    if([self.photoUserInfoButton.titleLabel.text  length] > 0) {
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
```

## Cache & Timeout Details

CoreBackground provides location and Flickr search caching to save power, reduce bandwidth and most important to preserve the UX. The default settings cache location information for 30 minuets and Flickr search results for 15 minuets.

Location requests will timeout after 10 seconds and requests to Flickr after 15 seconds. These settings can be modified as show below.

```Objective-C
(CBGConstants.h)
```

```Objective-C
//Location
#define kLocationInvalidateCacheTimeoutDurationInSeconds 1800 //30min (60 * 30)
#define kLocationQuitTimeoutDurationInSeconds 10

//Flickr
#define kFlickrSearchInvalidateCacheTimeoutDurationInSeconds 900 //15min Hour (60 * 15)
#define kFlickrSearchQuitTimeoutDurationInSeconds 15
```

## Thread-Safety
_Although CoreBackground is thread-safe it is intended to be called from a timer which is scheduled on the main run loop._

### History
Initial release : _6/27/2013_

### Acknowledgements
Special thanks to [Matt Martindale](https://github.com/showpony) of [Show Pony Apps, LLC](http://www.showponyapps.com) for providing architecture guidance.

### Copyright and Software License

* ObjectiveFlickr : _Lukhnos D. Liu._
* LFWebAPIKit : _Lukhnos D. Liu and Lithoglyph Inc._
* UIImage Alpha, Resize, RoundedCorner Category Methods : _Trevor Harmon_
* UIImage Image Effects Category Methods : _Apple, Inc._

The MIT License (MIT)

Copyright (c) 2013 Justin M Fischer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Contact
* Justin M Fischer : _justinmfischer@gmail.com_

### Links
* [iOS Yahoo Weather App](https://itunes.apple.com/us/app/yahoo!-weather/id628677149?mt=8)
* [Flickr API key, secret](http://www.flickr.com/services/apps/create/apply/)
