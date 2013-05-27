//
//  ADCellObject.m
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADCellObject.h"

#import "ADTextFieldCell.h"

@interface ADCellObject () <UITextFieldDelegate>

@end

@implementation ADCellObject
@synthesize cell = _cell;

+ (ADCellObject *)cell {
	return [[ADCellObject alloc] init];
}

- (ADTableViewCell *)cell {
	if (!_cell) {
		switch ([self type]) {
			case ADFormCellTypeText:
				_cell = [ADTextFieldCell alloc];
				
				break;
		}
		
		[[_cell label] setText:[self title]];
	}
	
	return _cell;
}

@end
