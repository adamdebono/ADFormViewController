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
		
		[[self textLabel] setFont:[UIFont systemFontOfSize:17]];
		[[self detailLabel] setFont:[UIFont systemFontOfSize:14]];
		[[self detailLabel] setTextColor:[UIColor blackColor]];
		[[self detailLabel] setAdjustsFontSizeToFitWidth:YES];
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
