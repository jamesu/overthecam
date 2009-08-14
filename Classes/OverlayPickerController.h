//
//  OverlayPickerController.h
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 09/07/2009.
//

#import <UIKit/UIKit.h>

#import "OverlayPreviewController.h"

@class JUCellFactory;

@interface OverlayPickerController : UIViewController {
    UINavigationController *navigation;
    UIImagePickerController *picker;
    
    UIViewController *previous;
    
    UITableView *display;
    JUCellFactory *factory;
    
    NSMutableArray *data;
}

@property(nonatomic, retain) IBOutlet UINavigationController *navigation;
@property(nonatomic, retain) IBOutlet UITableView *display;
@property(nonatomic, retain) NSMutableArray *data;

- (IBAction)addNewOverlay:(id)sender;
- (IBAction)doTakePicture:(id)sender;
- (IBAction)cancel:(id)sender;

@end
