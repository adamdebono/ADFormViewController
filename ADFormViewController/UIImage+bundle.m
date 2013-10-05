//
//  UIImage+bundle.m
//  ADFormViewController
//
//  Created by Adam Debono on 5/10/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "UIImage+bundle.h"

@implementation UIImage (bundle)

+ (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)bundle {
	if (bundle == nil) {
		// Use main bundle
		bundle = [NSBundle mainBundle];
	}
	
	// Split into extension and name
	NSString *extension = [name pathExtension];
	if (!extension || ![extension length]) {
		extension = @"png";
	} else {
		name = [name stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", extension] withString:@"" options:NSBackwardsSearch|NSAnchoredSearch range:NSMakeRange(0, [name length])];
	}
	
	// Get scale
	UIScreen *screen = [UIScreen mainScreen];
	CGFloat scale = 1.0f;
	if ([screen respondsToSelector:@selector(scale)]) {
		scale = screen.scale;
	}
	
	// Transform into int
	NSUInteger intScale = (NSUInteger)round(scale);
	
	// Generate modified
	NSString *modifier = @"";
	if (intScale != 1) {
		modifier = [NSString stringWithFormat:@"@%dx", intScale];
	}
	
	// Generate resolution dependent name
	NSString *resolutionDependentName = [NSString stringWithFormat:@"%@%@", name, modifier];
	
	// Search for resolution dependent file in bundle
	NSString *path = [bundle pathForResource:resolutionDependentName ofType:extension];
	if (path == nil) {
		// Not found, try to find standard res file
		path = [bundle pathForResource:name ofType:extension];
	}
	
	if (path == nil) {
		// Still not found, return nil
		return nil;
	} else {
		// Load and return image
		return [UIImage imageWithContentsOfFile:path];
	}
}

@end
