//
//  Created by JUSTIN M FISCHER on 6/17/13.
//  Copyright (c) 2012 Fun Touch Apps, LLC. All rights reserved.
//

//Objective Flickr API

#warning Change Flickr API & SECRET

#define OBJECTIVE_FLICKR_API_KEY @"Ch@ngeMe"
#define OBJECTIVE_FLICKR_API_SHARED_SECRET @"Ch@ngeMe"

/*
 <licenses>
 <license id="0" name="All Rights Reserved"
 <license id="1" name="Attribution-NonCommercial-ShareAlike License" url="http://creativecommons.org/licenses/by-nc-sa/2.0/" />
 <license id="2" name="Attribution-NonCommercial License" url="http://creativecommons.org/licenses/by-nc/2.0/" />
 <license id="3" name="Attribution-NonCommercial-NoDerivs License" url="http://creativecommons.org/licenses/by-nc-nd/2.0/" />
 <license id="4" name="Attribution License" url="http://creativecommons.org/licenses/by/2.0/" />
 <license id="5" name="Attribution-ShareAlike License" url="http://creativecommons.org/licenses/by-sa/2.0/" />
 <license id="6" name="Attribution-NoDerivs License" url="http://creativecommons.org/licenses/by-nd/2.0/" />
 <license id="7" name="No known copyright restrictions" url="http://flickr.com/commons/usage/" />
 <license id="8" name="United States Government Work" url="http://www.usa.gov/copyright.shtml" />
 </licenses>
 */

//Location
#define kLocationInvalidateCacheTimeoutDurationInSeconds 1800 //30min (60 * 30)
#define kLocationQuitTimeoutDurationInSeconds 10

//Flickr
#define KFlickrSsearchTags @"bike"
#define KFlickrSearchLicense @"4,5,6,7"
#define KFlickrSearchRadiusInMiles @"10"
#define kFlickrSearchInvalidateCacheTimeoutDurationInSeconds 900 //15min (60 * 15)
#define kFlickrSearchQuitTimeoutDurationInSeconds 15

//Async Queue Label
#define kAsyncQueueLabel "org.tempuri"