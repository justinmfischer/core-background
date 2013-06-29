//
//  Created by JUSTIN M FISCHER on 6/17/13.
//  Copyright (c) 2012 Fun Touch Apps, LLC. All rights reserved.
//

#import "CBGUtil.h"

@implementation CBGUtil

+ (int) getRandomIntBetweenLow:(int) low andHigh:(int) high {
	return ((arc4random() % (high - low + 1)) + low);
}

+ (BOOL) is4InchIphone {
    BOOL taller = NO;
    
    int height = [[UIScreen mainScreen] bounds].size.height;
    
    if(height == 568) {
        taller = YES;
    }
    
    return taller;
}

@end
