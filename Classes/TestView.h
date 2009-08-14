//
//  TestView.h
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 08/07/2009.
//

#import <Foundation/Foundation.h>


@interface TestView : UIView {
    UIImage *theImage;
    
    float defaultOpacity;
}

@property(nonatomic, retain) UIImage *theImage;
@property(nonatomic, assign) float defaultOpacity;

- (void)animateVisibility:(BOOL)visible;

@end
