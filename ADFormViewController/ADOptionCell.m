//
//  ADOptionCell.m
//  ADFormViewController
//
//  Created by Adam Debono on 5/10/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADOptionCell.h"

@implementation ADOptionCell

- (id)init {
	if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"option"]) {
		[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	
	return self;
}

- (UILabel *)label {
	return [self textLabel];
}

- (UILabel *)detailLabel {
	return [self detailTextLabel];
}

@end
