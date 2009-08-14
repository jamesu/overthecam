//
//  OverlayDesc.h
// 
//  OverTheCam
//    Copyright (C) 2009 James S Urquhart (jamesu at gmail dot com).
//    Refer to the LICENSE file included in the distribution for licensing information.
//
//  Created by James Urquhart on 09/07/2009.
//

#import <Foundation/Foundation.h>

#define THUMB_SIZE 64.0f

@interface OverlayDesc : NSObject {
    NSString *name;
    NSString *fileName;
    
    UIImage *image;
    UIImage *thumb;
    
    bool internal;
    bool jpeg;
    
    float opacity;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *fileName;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) UIImage *thumb;
@property(nonatomic, assign) bool internal;
@property(nonatomic, assign) bool jpeg;
@property(nonatomic, assign) float opacity;

- (void)clear:(BOOL)includeThumb;
- (void)remove; // remove from FS

+ (OverlayDesc*)quickWithFilename:(NSString*)aName name:(NSString*)desc internal:(BOOL)isInternal jpeg:(BOOL)isJpeg opacity:(float)opacity; 

@end
