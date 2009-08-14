//
//  OverlayPickerController.m
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 09/07/2009.
//

#import "OverlayPickerController.h"
#import "phototestAppDelegate.h"
#import "OverlayDesc.h"
#import "JUCellFactory.h"

@implementation OverlayPickerController

@synthesize navigation;
@synthesize display;
@synthesize data;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        navigation = nil;
        picker = nil;
        display = nil;
        previous = nil;
        factory = [[JUCellFactory alloc] initWithNib:@"Cells"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Load overlay sets
        NSArray *items = [defaults arrayForKey:@"OverlayList"]; // custom
        NSArray *iitems = [NSMutableArray arrayWithObjects:
                           [OverlayDesc quickWithFilename:@"thirds" name:NSLocalizedString(@"exm_thirds", @"Thirds") internal:YES jpeg:NO opacity:0.5],
                           [OverlayDesc quickWithFilename:@"vanishing_1" name:NSLocalizedString(@"exm_vanish1", @"Vanishing Point 1") internal:YES jpeg:NO opacity:0.5],
                           [OverlayDesc quickWithFilename:@"vanishing_2" name:NSLocalizedString(@"exm_vanish2", @"Vanishing Point 2") internal:YES jpeg:NO opacity:0.5],
                           [OverlayDesc quickWithFilename:@"isometric_1" name:NSLocalizedString(@"exm_iso1", @"Isometric 1") internal:YES jpeg:NO opacity:0.5],
                           [OverlayDesc quickWithFilename:@"isometric_2" name:NSLocalizedString(@"exm_iso2", @"Isometric 2") internal:YES jpeg:NO opacity:0.5], nil];
        
        data = [[NSMutableArray arrayWithCapacity:[items count] + [iitems count]] retain];
        [data addObjectsFromArray:iitems];
        
        // Merge opacity
        NSDictionary *opacityMap = [defaults dictionaryForKey:@"OpacityMap"];
        for (OverlayDesc *desc in data) {
            NSNumber *val = [opacityMap objectForKey:desc.fileName];
            if (val)
                desc.opacity = [val floatValue];
        }
        
        // Incorporate custom list
        for (NSData *dat in items)
            [data addObject:[NSKeyedUnarchiver unarchiveObjectWithData:dat]];
    }
    return self;
}

- (void)navigationController:(UINavigationController*)nav willShowViewController:(UIViewController*)controller animated:(BOOL)animated
{
    [controller viewWillAppear:animated];
    
    if (previous) {
        [previous viewWillDisappear:animated];
    } else {
        // first controller, localize!
        controller.navigationItem.title = NSLocalizedString(@"ovr_sel", @"Choose Overlay");
    }
}

- (void)navigationController:(UINavigationController*)nav didShowViewController:(UIViewController*)controller animated:(BOOL)animated
{
    [controller viewDidAppear:animated];
    
    if (previous) {
        [controller viewDidDisappear:animated];
        [previous release];
    }
    
    previous = [controller retain];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:navigation.view];
    
    CGPoint cent = navigation.view.center;
    cent.y -= 20.0f;
    navigation.view.center = cent;
}


- (IBAction)addNewOverlay:(id)sender
{
    phototestAppDelegate *del = (phototestAppDelegate*)[[UIApplication sharedApplication] delegate];
    [self doTakePicture:sender];
}


- (IBAction)cancel:(id)sender
{
    phototestAppDelegate *del = (phototestAppDelegate*)[[UIApplication sharedApplication] delegate];
    [del didChooseOverlay:data];
}

// TableView delegate

- (void)tableView:(UITableView *)stableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // Details
    OverlayPreviewController *overlayPreview = [[OverlayPreviewController alloc] initWithImage:[data objectAtIndex:indexPath.row] andPicker:self];
    [navigation pushViewController:overlayPreview animated:YES];
    [navigation viewWillAppear:YES];
    [overlayPreview release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (void)tableView:(UITableView *)stableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    phototestAppDelegate *del = (phototestAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // Set active & cancel
    del.overlay = [data objectAtIndex:indexPath.row];
    
    [del didChooseOverlay:data];
}


NSString *kOCell = @"OCELL";

- (UITableViewCell *)tableView:(UITableView *)stableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    UITableViewCell *cell = [stableView dequeueReusableCellWithIdentifier:kOCell];
    
    if (cell == nil) {
        cell = [factory cell:kOCell forTable:stableView];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    OverlayDesc *overlay = (OverlayDesc*)[data objectAtIndex:row];
    
    UIImageView *img = (UIImageView*)[cell viewWithTag:1];
    img.image = overlay.thumb;
    cell.textLabel.text = overlay.name;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)stableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)stableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)stableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !((OverlayDesc*)[data objectAtIndex:indexPath.row]).internal;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    OverlayDesc *desc = [data objectAtIndex:indexPath.row];
    [desc remove];
    [data removeObjectAtIndex:indexPath.row];
        
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                     withRowAnimation:UITableViewRowAnimationFade];
}

// Picker

- (IBAction)doTakePicture:(id)sender
{
    if (picker)
        return;
    
    picker = [[UIImagePickerController alloc] init];
    
    picker.allowsImageEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [navigation presentModalViewController:picker animated:NO];
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

// Courtesy cmezak  http://www.iphonedevsdk.com/forum/iphone-sdk-development/7307-resizing-photo-new-uiimage.html
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

-(UIImage *)resizeImage:(UIImage *)image hasAlpha:(bool*)hasAlpha {
	
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
	
	if (alphaInfo == kCGImageAlphaNone) {
        alphaInfo = kCGImageAlphaNoneSkipLast;
    }
    
    *hasAlpha = !(alphaInfo == kCGImageAlphaNone || alphaInfo == kCGImageAlphaNoneSkipLast || kCGImageAlphaNoneSkipFirst);
	
	int width, height;
	
	width = 320;
	height = 480;
    
    // right == potrait
    // landscape == up
    // left == down
    // landscape alt == down
    
    CGSize sz = image.size;
	CGContextRef bitmap;
	UIImageOrientation orient = image.imageOrientation;
    bitmap = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpaceInfo, alphaInfo);
	
    bool flip = (sz.width > sz.height) || (orient == UIImageOrientationLeft || orient == UIImageOrientationRight);
    
    if (flip) {
        // Need to transform and scale image
        if (orient == UIImageOrientationLeft) {
#ifndef ALLOW_WEIRD
            CGContextRotateCTM (bitmap, radians(90));
            CGContextTranslateCTM (bitmap, 0, -width);
#else
            CGContextRotateCTM (bitmap, radians(-90));  // i.e. upside down
            CGContextTranslateCTM (bitmap, -height, 0);
#endif
        } else if (orient == UIImageOrientationRight) {
            CGContextRotateCTM (bitmap, radians(-90));
            CGContextTranslateCTM (bitmap, -height, 0);
        } else {
            // default
            CGContextRotateCTM (bitmap, radians(-90));
            CGContextTranslateCTM (bitmap, -height, 0);
        }
    }
	
	CGContextDrawImage(bitmap, flip ? CGRectMake(0, 0, height, width) : CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
    CGColorSpaceRelease(colorSpaceInfo);
	CGImageRelease(ref);
    
    return result;
}

- (void)imagePickerController:(UIImagePickerController *)thePicker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    bool jpeg = YES;
    
    // Save
    OverlayDesc *desc = [[OverlayDesc alloc] init];
    desc.name = @"";
    
    // Get unique filename
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *chosenName = nil;
    NSString *fullName = nil;
    
    do {
        NSDate *date = [NSDate date];
        chosenName = [NSString stringWithFormat:@"%@_%x", [[date description] stringByReplacingOccurrencesOfString:@" " withString:@"_"], rand() % 65536];
        fullName = [phototestAppDelegate theDocumentFolderFor:chosenName ofType:(jpeg ? @"jpg" : @"png")];
    } while ([fm fileExistsAtPath:fullName]);
    
    bool hasAlpha = false;
    UIImage *smallImage = [self resizeImage:image hasAlpha:&hasAlpha];
    
    desc.jpeg = !hasAlpha;
    desc.fileName = chosenName;
    desc.image = smallImage;
    
    if (desc.image == nil) {
        // Error!
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(@"dlg_imgerr", @"Image could not be saved.")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"dlg_ok", @"OK")
                                          otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        [data addObject:desc];
        [display reloadData];
    }
    
    // Cleanup
    [navigation dismissModalViewControllerAnimated:YES];
    [desc release];
    [picker release];
    picker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)thePicker
{
    [navigation dismissModalViewControllerAnimated:YES];
    [picker release];
    picker = nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    for (OverlayDesc *overlay in data)
        [overlay clear:NO];
}

- (void)viewDidUnload {
    [previous release];
    previous = nil;
    
    [navigation release];
    navigation = nil;
    
    [display release];
    display = nil;
}


- (void)dealloc {
    // Commit state to defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *outList = [NSMutableArray array];
    NSMutableDictionary *opacityMap = [NSMutableDictionary dictionary];
    
    for (OverlayDesc *desc in data)
    {
        if (!desc.internal) {
            // Set whole properties
            [outList addObject:[NSKeyedArchiver archivedDataWithRootObject:desc]];
        } else {
            // Set opacity map
            [opacityMap setObject:[NSNumber numberWithFloat:desc.opacity] forKey:desc.fileName];
        }
    }
    
    [defaults setObject:opacityMap forKey:@"OpacityMap"];
    [defaults setObject:outList forKey:@"OverlayList"];
    
    [previous release];
    [picker release];
    [factory release];
    [data release];
    [super dealloc];
}


@end
