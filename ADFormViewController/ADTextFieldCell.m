//
//  CBTextFieldCell.m
//  cobonia
//
//  Created by Adam Debono on 19/05/13.
//  Copyright (c) 2013 Cobonia. All rights reserved.
//

#import "ADTextFieldCell.h"

@implementation ADTextFieldCell

- (id)init {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ADFormViewControllerResources" ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:path];
	self = [[bundle loadNibNamed:@"CBTextFieldCell" owner:self options:nil] objectAtIndex:0];
	if (self) {
		
	}
	
	return self;
}

+ (NSString *)reuseIdentifier {
	return @"ADTextFieldCell";
}

+ (NSString *)bundleName {
	return @"ADTextFieldCell";
}

@end
