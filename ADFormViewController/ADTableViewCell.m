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
//@synthesize reuseIdentifier = _reuseIdentifier;

- (id)init {
	NSString *path = [[NSBundle mainBundle] pathForResource:[[self class] bundleName] ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:path];
	self = [[bundle loadNibNamed:@"CBTextFieldCell" owner:self options:nil] objectAtIndex:0];
	if (self) {
		[self setReuseIdentifier:[[self class] reuseIdentifier]];
	}
	
	return self;
}

+ (NSString *)bundleName {
	return nil;
}

+ (NSString *)reuseIdentifier {
	return nil;
}

@end
