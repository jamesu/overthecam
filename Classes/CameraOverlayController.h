//
//  CameraOverlayController.h
//  phototest
//
//  Created by James Urquhart on 17/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OverlayDesc.h"

@class TestView;

@interface CameraOverlayController : UIViewController {
    IBOutlet TestView *theView;
    IBOutlet UIToolbar *toolbar; 
    
    IBOutlet UIActivityIndicatorView *savingView;
    IBOutlet UILabel *savingDesc;
    
    UIImagePickerController *currentPicker;
    OverlayDesc *overlay;
    
    int saveCount;
}

@property(nonatomic, retain) TestView *theView;
@property(nonatomic, retain) UIToolbar *toolbar;

@property(nonatomic, retain) UIActivityIndicatorView *savingView;
@property(nonatomic, retain) UILabel *savingDesc;

@property(nonatomic, assign) UIImagePickerController *currentPicker;

@property(nonatomic, assign) bool saving;
@property(nonatomic, retain) OverlayDesc *overlay;

- (void)setCameraToolbar:(BOOL)animated;

@end
