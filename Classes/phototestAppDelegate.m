//
//  phototestAppDelegate.m
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 08/07/2009.
//

#import "phototestAppDelegate.h"
#import "TestView.h"
#import "OverlayDesc.h"
#import <objc/runtime.h>

#define TOOLBAR_OFFSET 1.0f
#define TOOLBAR_HEIGHT 54.0f

@implementation phototestAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize picker;
@synthesize currentOverlay;
@synthesize overlay;

static bool camCheck = false;
static bool camRecheck = false;
//#define DEBUG
#ifdef DEBUG
void dumpViews(UIView *root, int offset)
{
    NSString *pad = [@"" stringByPaddingToLength:offset withString:@"\t" startingAtIndex:0];
    
    // Print stats
    CGRect theFrame = root.frame;
    NSLog([NSString stringWithFormat:@"%@(%@) [%f,%f,%f,%f] hidden=%i", pad, [root class], theFrame.origin.x, theFrame.origin.y, theFrame.size.width, theFrame.size.height, root.hidden]);

    for (UIView *child in root.subviews)
          dumpViews(child, offset+1);
}
#endif

bool viewContainsClass(UIView *root, const char *className, int offset)
{
    const char *name = class_getName([root class]);
    if (strcmp(name, className) == 0)
        return true;
    
    for (UIView *child in root.subviews) {
        if (viewContainsClass(child, className, offset+1))
            return true;
    }
    
    return false;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docDir = [paths objectAtIndex:0];
    [docDir retain];
    
    // Last overlay
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *overlayData = [defaults objectForKey:@"LastOverlay"];
    if (overlayData) {
        self.overlay = [NSKeyedUnarchiver unarchiveObjectWithData:overlayData]; 
        currentOverlay.image = overlay.image;
        currentOverlay.alpha = overlay.opacity;
    }
    
    // Localize views
    UIView *view = viewController.view;
    ((UILabel*)[view viewWithTag:1]).text = NSLocalizedString(@"prv_title", @"PREVIEW");
    
    UIButton *control = (UIButton*)[view viewWithTag:2];
    NSString *locale = NSLocalizedString(@"prv_sel", @"SELECT");
    [control setTitle:locale forState:UIControlStateNormal];
    [control setTitle:locale forState:UIControlStateHighlighted];
    
    control = (UIButton*)[view viewWithTag:3];
    locale = NSLocalizedString(@"prv_cap", @"CAPTURE");
    [control setTitle:locale forState:UIControlStateNormal];
    [control setTitle:locale forState:UIControlStateHighlighted];
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (cameraTimer) {
        [cameraTimer invalidate];
        cameraTimer = nil;
    }
    if (picker)
        [picker dismissModalViewControllerAnimated:NO];
    if (theView)
        [theView removeFromSuperview];
    [defaults synchronize];
}

- (NSString*)documentFolderFor:(NSString*)file ofType:(NSString*)typeName
{
    return [NSString stringWithFormat:@"%@/%@.%@", docDir, file, typeName];
}

+ (NSString*)theDocumentFolderFor:(NSString*)file ofType:(NSString*)typeName
{
    return [(phototestAppDelegate*)[[UIApplication sharedApplication] delegate] documentFolderFor:file ofType:typeName];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)tviewController animated:(BOOL)animated
{
    //NSLog(@"-->didShow %@", tviewController);
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)tviewController animated:(BOOL)animated
{
    //NSLog(@"-->willShow %@", tviewController);
}

- (IBAction)doTakePicture:(id)sender
{
    if (picker)
        return;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"dlg_camreq", @"Camera required.")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"dlg_ok", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    picker = [[UIImagePickerController alloc] init];
    
    picker.allowsImageEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [viewController presentModalViewController:picker animated:YES];
    
    CGRect theFrame = window.frame;
    theFrame.origin.y += TOOLBAR_OFFSET;
    theFrame.size.height -= TOOLBAR_HEIGHT;
    theView = [[TestView alloc] initWithFrame:theFrame];
    theView.theImage = overlay.image;
    theView.defaultOpacity = overlay.opacity;
    theView.alpha = overlay.opacity;
    [window addSubview:theView];
    camCheck = false;
    camRecheck = false;
    
    cameraTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(checkCamera:) userInfo:nil repeats:YES];
}

- (void)checkCamera:(NSTimer*)timer
{
    bool hasCamera = true;
    
    // Check for camera button
    if (!camCheck || camRecheck) {
        hasCamera = viewContainsClass(picker.view, "PLCameraButton", 0);
        //dumpViews(picker.view, 0);
        
        // Re-check if camera button is visible (first time)
        if (!camCheck && hasCamera && !camRecheck) {
            camRecheck = true;
        }
        
        camCheck = true;
    } else {
        hasCamera = false;
    }
    
    // Visible if camera button visible or was never visible
    if (hasCamera || !camRecheck)
        [theView animateVisibility:YES];
    else
        [theView animateVisibility:NO];
}

- (void)   savedPhotoImage:(UIImage *)image
  didFinishSavingWithError:(NSError *)error
               contextInfo:(void *)contextInfo
{    
    NSString *message = nil;
    if (error) {
        message = [error localizedDescription];
    } else {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"dlg_ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)imagePickerController:(UIImagePickerController *)thePicker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    [viewController dismissModalViewControllerAnimated:NO];
    [viewController presentModalViewController:thePicker animated:NO];
    
    UIImageWriteToSavedPhotosAlbum(image, 
                                   self,
                                   @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:),
                                   NULL);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)thePicker
{
    [viewController dismissModalViewControllerAnimated:thePicker ? YES : NO];
    [picker release];
    picker = nil;
    [theView removeFromSuperview];
    [theView release];
    theView = nil;
    [cameraTimer invalidate];
    cameraTimer = nil;
}


- (IBAction)chooseOverlay:(id)sender
{
    if (picker)
        [self imagePickerControllerDidCancel:nil];
    
    OverlayPickerController *opicker = [[OverlayPickerController alloc] initWithNibName:@"OverlayPicker" bundle:nil];
    [viewController presentModalViewController:opicker animated:YES];
    [opicker release];
}

- (void)didChooseOverlay:(NSArray*)list
{
    // Custom? then sync with list!
    if (overlay)
    {
        NSString *currentFName = overlay.fileName;
        for (OverlayDesc *desc in list)
        {
            if ([desc.fileName isEqual:currentFName]) {
                overlay.opacity = desc.opacity;
                overlay.name = desc.name;
                break;
            }
        }
    }
    
    currentOverlay.image = overlay.image;
    currentOverlay.alpha = overlay.opacity;
    [viewController dismissModalViewControllerAnimated:YES];
    
    // Set default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (overlay)
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:overlay] forKey:@"LastOverlay"];
    else
        [defaults removeObjectForKey:@"LastOverlay"];
}


- (void)dealloc {
    [docDir release];
    [currentOverlay release];
    [overlay release];
    [viewController dismissModalViewControllerAnimated:NO];
    if (picker) {
        [theView release];
    }
    [picker release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
