//
//  ADCellObject.m
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADCellObject.h"

#import "ADButtonCell.h"
#import "ADDateCell.h"
#import "ADTextFieldCell.h"

@interface ADCellObject () <UITextFieldDelegate>

@end

@implementation ADCellObject
@synthesize cell = _cell;

+ (ADCellObject *)cellWithType:(ADFormCellType)type {
	return [[ADCellObject alloc] initWithType:type];
}

- (id)initWithType:(ADFormCellType)type {
	if (self = [super init]) {
		_type = type;
		
		_identifier = nil;
		_title = nil;
		_value = nil;
		
		_cellPressedAction = NULL;
		_enabled = YES;
	}
	
	return self;
}

- (ADTableViewCell *)cell {
	if (!_cell) {
		switch ([self type]) {
			case ADFormCellTypeButton:
			case ADFormCellTypeDoneButton:
				_cell = [[ADButtonCell alloc] init];
				break;
			case ADFormCellTypeDate:
				_cell = [[ADDateCell alloc] init];
				if (![self value]) {
					_value = [NSDate date];
				}
				NSAssert([[self value] isKindOfClass:[NSDate class]], @"Date cell must have a date value");
				[(ADDateCell *)[self cell] setDate:[self value]];
				break;
			case ADFormCellTypeText:
				_cell = [[ADTextFieldCell alloc] init];

				if (![self value]) {
					_value = @"";
				}
				[[self textField] setText:[NSString stringWithFormat:@"%@", [self value]]];
				break;
		}
		
		[[_cell label] setText:[self title]];
		[self setEnabled:_enabled];
	}
	
	return _cell;
}

- (NSString *)description {
	return [[super description] stringByAppendingFormat:@" id: %@, value: %@", [self identifier], [self value]];
}

#pragma mark - Setters

- (void)setEnabled:(BOOL)enabled {
	_enabled = enabled;
	
	if (enabled) {
		[[self cell] setBackgroundColor:[UIColor whiteColor]];
	} else {
		[[self cell] setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
	}
}

#pragma mark - Text Field

- (BOOL)hasTextField {
	switch ([self type]) {
		case ADFormCellTypeText:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (UITextField *)textField {
	switch ([self type]) {
		case ADFormCellTypeText:
		case ADFormCellTypeDate:
			return [(ADTextFieldCell *)[self cell] textField];
			break;
		default:
			return nil;
			break;
	}
}

#pragma mark - Date Picker

- (BOOL)hasDatePicker {
	switch ([self type]) {
		case ADFormCellTypeDate:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (UIDatePicker *)datePicker {
	switch ([self type]) {
		case ADFormCellTypeDate:
			return [(ADDateCell *)[self cell] datePicker];
			break;
		default:
			return nil;
			break;
	}
}

@end
