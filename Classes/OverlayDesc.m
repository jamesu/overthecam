//
//  OverlayDesc.m
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 09/07/2009.
//

#import "OverlayDesc.h"
#import "phototestAppDelegate.h"

@implementation OverlayDesc

@synthesize name;
@synthesize fileName;
@dynamic image;
@dynamic thumb;
@synthesize internal;
@synthesize jpeg;
@synthesize opacity;

- (id)init
{
    if (self = [super init] ) {
        name = nil;
        fileName = nil;
        image = nil;
        thumb = nil;
        internal = false;
        jpeg = false;
        opacity = 0.6;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	[self init];
	
	self.name = [coder decodeObjectForKey:@"name"];
	self.fileName = [coder decodeObjectForKey:@"fileName"];
	self.internal = [coder decodeBoolForKey:@"internal"];
	self.jpeg = [coder decodeBoolForKey:@"jpeg"];
	self.opacity = [coder decodeFloatForKey:@"opacity"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:fileName forKey:@"fileName"];
	[coder encodeBool:internal forKey:@"internal"];
	[coder encodeBool:jpeg forKey:@"jpeg"];
	[coder encodeFloat:opacity forKey:@"opacity"];
}

- (UIImage*)image
{
    if (!image && fileName) {
        NSString *path = internal ? [[NSBundle mainBundle] pathForResource:fileName ofType:(jpeg ? @"jpg" : @"png")] : 
        [phototestAppDelegate theDocumentFolderFor:fileName ofType:(jpeg ? @"jpg" : @"png")];
        
        if (path) {
            image = [UIImage imageWithContentsOfFile:path];
            [image retain];
        }
    }
    
    return image;
}

- (void)setImage:(UIImage*)theImage
{
    if (image)
        [image release];
    
    if (thumb)
        [thumb release];
    
    image = [theImage retain];
    
    // Update external
    if (!internal)
    {
        NSString *path = [phototestAppDelegate theDocumentFolderFor:fileName ofType:(jpeg ? @"jpg" : @"png")];
        NSData *dat;
        
        if (jpeg)
            dat = UIImageJPEGRepresentation(image, 100);
        else
            dat = UIImagePNGRepresentation(image);
        
        [dat writeToFile:path atomically:NO];
    }
}


- (void)setThumb:(UIImage*)theThumb
{
    if (thumb)
        [thumb release];
    
    thumb = [theThumb retain];
}

- (NSString*)thumbFile
{
    return [NSString stringWithFormat:@"%@_thumb", fileName];
}

- (UIImage*)thumb
{
    if (!thumb) {
        NSString *path = [phototestAppDelegate theDocumentFolderFor:[self thumbFile] ofType:(jpeg ? @"jpg" : @"png")];
        
        // Load from documents path
        if (path) {
            thumb = [UIImage imageWithContentsOfFile:path];
            [thumb retain];
        }
        
        if (!thumb && self.image) {
            // resize
            UIGraphicsBeginImageContext(CGSizeMake(THUMB_SIZE, THUMB_SIZE));
            [image drawInRect:CGRectMake(0, 0, THUMB_SIZE, THUMB_SIZE)];
            thumb = UIGraphicsGetImageFromCurrentImageContext();
            [thumb retain];
            UIGraphicsEndImageContext();
            
            // Store to file
            NSData *dat;
            
            if (jpeg)
                dat = UIImageJPEGRepresentation(thumb, 100);
            else
                dat = UIImagePNGRepresentation(thumb);
            
            [dat writeToFile:path atomically:NO];
        }
    }
    
    return thumb;
}

- (void)clear:(BOOL)includeThumb {
    [image release];
    image = nil;
    
    if (includeThumb) {
        [thumb release];
        thumb = nil;
    }
}

- (void)remove
{
    // Thumbnail
    NSString *path = [phototestAppDelegate theDocumentFolderFor:[self thumbFile] ofType:(jpeg ? @"jpg" : @"png")];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    if (internal)
        return;
    
    // Actual image
    path = [phototestAppDelegate theDocumentFolderFor:fileName ofType:(jpeg ? @"jpg" : @"png")];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)dealloc
{
    [name release];
    [fileName release];
    
    [self clear:YES];
    [super dealloc];
}

+ (OverlayDesc*)quickWithFilename:(NSString*)aName name:(NSString*)desc internal:(BOOL)isInternal jpeg:(BOOL)isJpeg opacity:(float)theOpacity
{
    OverlayDesc *odesc = [[OverlayDesc alloc] init];
    odesc.fileName = aName;
    odesc.name = desc;
    odesc.internal = isInternal;
    odesc.jpeg = isJpeg;
    odesc.opacity = theOpacity;
    return [odesc autorelease];
}

@end
