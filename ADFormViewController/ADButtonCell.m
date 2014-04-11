//
//  ADButtonCell.m
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADButtonCell.h"

@implementation ADButtonCell

- (void)setHighlight:(BOOL)highlight {
	_highlight = highlight;
	
	[self tintColorDidChange];
}

- (void)tintColorDidChange {
	if (self.highlight) {
		self.label.textColor = self.tintColor;
	}
}

@end
