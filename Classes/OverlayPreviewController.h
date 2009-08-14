//
//  OverlayPreviewController.h
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 09/07/2009.
//

#import <UIKit/UIKit.h>

@class TestView;
@class OverlayDesc;
@class OverlayPickerController;

@interface OverlayPreviewController : UIViewController {
    IBOutlet UIImageView *theView;
    IBOutlet UITextField *nameField;
    
    OverlayDesc *oImage;
    OverlayPickerController *picker;
}

@property(nonatomic, retain) UIImageView *theView;
@property(nonatomic, retain) UITextField *nameField;

- (id)initWithImage:(OverlayDesc*)theImage andPicker:(OverlayPickerController*)thePicker;

- (IBAction)didEditName:(id)sender;
- (IBAction)willEditName:(id)sender;

- (void)toggleEdit:(BOOL)edit animated:(BOOL)animated;

@end
