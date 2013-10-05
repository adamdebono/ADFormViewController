//
//  ADTableViewCell.m
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADTableViewCell.h"

@interface ADTableViewCell ()

@property (nonatomic, copy) NSString *reuseIdentifier;

@end

@implementation ADTableViewCell

- (id)init {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ADFormViewControllerResources" ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:path];
	self = [[bundle loadNibNamed:[[self class] nibName] owner:self options:nil] objectAtIndex:0];
	if (self) {
		[self setReuseIdentifier:[[self class] nibName]];
	}
	
	return self;
}

+ (NSString *)nibName {
	return NSStringFromClass([self class]);
}

@end
