//
//  ADStandardCell.m
//  Pods
//
//  Created by Adam Debono on 12/03/2014.
//
//

#import "ADStandardCell.h"

@implementation ADStandardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		if (style == UITableViewCellStyleValue1) {
			[[self detailLabel] setFont:[UIFont systemFontOfSize:14.0f]];
		}
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
