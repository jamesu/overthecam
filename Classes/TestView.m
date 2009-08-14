//
//  TestView.m
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 08/07/2009.
//

#import "TestView.h"


@implementation TestView

@synthesize theImage;
@synthesize defaultOpacity;

- (id)initWithFrame:(CGRect)theFrame
{
    if (self = [super initWithFrame:theFrame]) {
        self.userInteractionEnabled = NO;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        defaultOpacity = 1.0;
    }
    
    return self;
}

- (void)animateVisibility:(BOOL)visible
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    self.alpha = visible ? defaultOpacity : 0.0;
    
    [UIView commitAnimations];
}

- (void)drawRect:(CGRect)theFrame
{
    [theImage drawInRect:theFrame];
}

- (void)dealloc
{
    [theImage release];
    [super dealloc];
}

@end
