//
//  CameraOverlayController.m
//  phototest
//
//  Created by James Urquhart on 17/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CameraOverlayController.h"
#import "phototestAppDelegate.h"
#import "TestView.h"

@implementation CameraOverlayController

@synthesize theView;
@synthesize toolbar;

@synthesize savingView;
@synthesize savingDesc;

@synthesize currentPicker;
@dynamic saving;
@dynamic overlay;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *myView = self.view;
    
    myView.opaque = NO;
    myView.backgroundColor = [UIColor clearColor];
    
    theView = [[TestView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 480.0-54)];
    [myView addSubview:theView];
    [myView bringSubviewToFront:savingView];
    [myView bringSubviewToFront:savingDesc];
    self.overlay = overlay;
    
    saveCount = 0;
    savingView.hidden = YES;
    savingDesc.hidden = YES;
    
    savingDesc.text =  NSLocalizedString(@"sav_stat", @"SAVING");
    
    [self setCameraToolbar:NO];
}

- (void)cancelSelect:(id)sender
{
    phototestAppDelegate *del = [[UIApplication sharedApplication] delegate];
    [del imagePickerControllerDidCancel:del.picker];
}

- (void)cameraSelect:(id)sender
{
    [currentPicker takePicture];
}



- (void)setCameraToolbar:(BOOL)animated
{
    UIImage *camImg = [UIImage imageNamed:@"CameraButton.png"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelSelect:)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithImage:camImg style:UIBarButtonItemStyleBordered target:self action:@selector(cameraSelect:)];
    
    fixedSpace.width = 42.0;
    cameraButton.width = 96.0;
    
    UIEdgeInsets insets = cameraButton.imageInsets;
    insets.left = 0.0;
    cameraButton.imageInsets = insets;
    
    CGRect frame = toolbar.frame;
    frame.origin.y -= 10.0;
    toolbar.frame = frame;
    
    NSArray *theItems = [NSArray arrayWithObjects:
                         cancelButton,
                         fixedSpace,
                         cameraButton,
                         flexSpace,
                         nil];
    
    [toolbar setItems:theItems animated:animated];
    
    // release allocated items
    for (UIView *view in theItems) {
        [view release];
    }
}

- (void)setSaving:(bool)value
{
    bool hidden;
    
    if (value) {
        saveCount++;
    } else {
        saveCount--;
        if (saveCount < 0)
            saveCount = 0;
    }
    
    hidden = saveCount == 0;
    
    savingView.hidden = hidden;
    savingDesc.hidden = hidden;
    
    if (!hidden)
        [savingView startAnimating];
    else
        [savingView stopAnimating];

}

- (bool)saving
{
    return savingView.hidden;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.theView = nil;
    self.toolbar = nil;
    
    self.savingDesc = nil;
    self.savingView = nil;
}

- (void)setOverlay:(OverlayDesc *)theOverlay
{
    if (overlay)
        [overlay release];
    
    overlay = [theOverlay retain];
    
    theView.theImage = overlay.image;
    theView.defaultOpacity = overlay.opacity;
    theView.alpha = overlay.opacity;
}

- (OverlayDesc*)overlay
{
    return overlay;
}


- (void)dealloc {
    [overlay release];
    [super dealloc];
}


@end
