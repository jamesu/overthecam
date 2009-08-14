//
//  phototestAppDelegate.h
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 08/07/2009.
//

#import <UIKit/UIKit.h>
#import "OverlayPickerController.h"

@class TestView;
@class OverlayDesc;

@interface phototestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UIViewController *viewController;
    UIImagePickerController *picker;
    
    UIImageView *currentOverlay;
    OverlayDesc *overlay;
    NSString *docDir;
    
    TestView *theView;
    NSTimer *cameraTimer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIImageView *currentOverlay;
@property (nonatomic, retain) IBOutlet UIViewController *viewController;

@property (nonatomic, retain) UIImagePickerController *picker;
@property (nonatomic, retain) OverlayDesc *overlay;

- (NSString*)documentFolderFor:(NSString*)file ofType:(NSString*)typeName;
+ (NSString*)theDocumentFolderFor:(NSString*)file ofType:(NSString*)typeName;

- (IBAction)chooseOverlay:(id)sender;
- (IBAction)doTakePicture:(id)sender;

- (void)didChooseOverlay:(NSArray*)list;

@end

