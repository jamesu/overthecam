//
//  OverlayPreviewController.m
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 09/07/2009.
//

#import "OverlayPreviewController.h"
#import "OverlayPickerController.h"
#import "TestView.h"
#import "OverlayDesc.h"

@implementation OverlayPreviewController

@synthesize theView;
@synthesize nameField;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithImage:(OverlayDesc*)theImage andPicker:(OverlayPickerController*)thePicker {
    if (self = [super initWithNibName:@"OverlayPreview" bundle:nil]) {
        // Custom initialization
        oImage = [theImage retain];
        picker = thePicker;
        nameField = nil;
        theView = nil;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Localize
    nameField.placeholder = NSLocalizedString(@"prv_name", @"Name");
    
    // Initial state
    [self toggleEdit:NO animated:NO];
    
    theView.image = oImage.image;
    theView.alpha = oImage.opacity;
}

- (IBAction)opacityUpdate:(id)sender
{
    float value = ((UISlider*)sender).value;
    oImage.opacity = value;
    theView.alpha = value;
}

- (void)setToolbar:(BOOL)editMode animated:(BOOL)animated
{
    NSArray *items = nil;
    UINavigationController *navigation = self.navigationController;
    
    if (editMode) {
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 160.0, 44.0)];
        slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        slider.value = oImage.opacity;
        slider.continuous = YES;
        
        [slider addTarget:self action:@selector(opacityUpdate:) forControlEvents:UIControlEventValueChanged];
    
        UIBarButtonItem *label = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"prv_opacity", @"Opacity") style:UIBarButtonItemStylePlain target:nil action:nil];
        UIBarButtonItem *sliderItem = [[UIBarButtonItem alloc] initWithCustomView:slider];
    
        items = [NSArray arrayWithObjects:
                          label, sliderItem, nil];
        
        // Cleanup
        [slider release];
        [label release];
        [sliderItem release];
    }
    
    navigation.toolbarHidden = !editMode;
    [navigation.toolbar setItems:items animated:animated];
}

- (IBAction)didEditName:(id)sender
{
    // Hide edit box
    [self toggleEdit:NO animated:YES];
}

- (IBAction)willEditName:(id)sender
{
    // Show edit box
    [self toggleEdit:YES animated:YES];
}

- (void)toggleEdit:(BOOL)edit animated:(BOOL)animated
{
    UINavigationItem *item = self.navigationItem;
    UIBarButtonItem *button;
    
    if (edit) {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didEditName:)];
        [self setToolbar:YES animated:animated];
        [item setRightBarButtonItem:button animated:animated];
        
        if (!oImage.internal) {
            nameField.text = oImage.name;
            nameField.hidden = NO;
        }
    } else {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(willEditName:)];
        [self setToolbar:NO animated:animated];
        [item setRightBarButtonItem:button animated:animated];
        
        if (!oImage.internal) {
            if (!nameField.hidden)
                oImage.name = nameField.text;
            [nameField resignFirstResponder];
        }
        nameField.hidden = YES;
    }
    
    [button release];
}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField
{
    return;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [self setToolbar:NO animated:NO];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self setToolbar:NO animated:NO];
    [picker.display reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [nameField release];
    [theView release];
    theView = nil;
    nameField = nil;
}


- (void)dealloc {
    [oImage release];
    [super dealloc];
}


@end
