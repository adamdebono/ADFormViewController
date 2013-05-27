//
//  ADCellObject.m
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADCellObject.h"

#import "ADButtonCell.h"
#import "ADTextFieldCell.h"

@interface ADCellObject () <UITextFieldDelegate>

@end

@implementation ADCellObject
@synthesize cell = _cell;

+ (ADCellObject *)cell {
	return [[ADCellObject alloc] init];
}

- (id)init {
	if (self = [super init]) {
		_identifier = nil;
		_title = nil;
		_value = nil;
	}
	
	return self;
}

- (ADTableViewCell *)cell {
	if (!_cell) {
		switch ([self type]) {
			case ADFormCellTypeDoneButton:
				_cell = [[ADButtonCell alloc] init];
				break;
			case ADFormCellTypeText:
				_cell = [[ADTextFieldCell alloc] init];
				//make sure it's a string
				
				if (![self value]) {
					_value = @"";
				}
				[[(ADTextFieldCell *)[self cell] textField] setText:[NSString stringWithFormat:@"%@", [self value]]];
				break;
		}
		
		[[_cell label] setText:[self title]];
	}
	
	return _cell;
}

- (NSString *)description {
	return [[super description] stringByAppendingFormat:@" id: %@, value: %@", [self identifier], [self value]];
}

@end
