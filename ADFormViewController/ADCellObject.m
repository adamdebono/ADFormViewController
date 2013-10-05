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
#import "ADOptionCell.h"
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
			case ADFormCellTypeSingleOption:
				_cell = [[ADOptionCell alloc] init];
				NSAssert([self options], @"Must provide options");
				[self setValue:_value];
				
				[[_cell textLabel] setFont:[UIFont systemFontOfSize:17]];
				[[_cell detailLabel] setFont:[UIFont systemFontOfSize:14]];
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

- (void)setValue:(id)value {
	_value = value;
	
	switch ([self type]) {
		case ADFormCellTypeSingleOption:
			if (_cell) {
				if (value) {
					if ([[self options] isKindOfClass:[NSArray class]]) {
						//NSAssert([[self options] isKindOfClass:[NSArray class]], @"Number value must point to an array of options");
						if ([value isKindOfClass:[NSNumber class]]) {
							_value = [NSString stringWithFormat:@"%@", [[self options] objectAtIndex:[value integerValue]]];
						}
						[[_cell detailLabel] setText:[self value]];
					} else if ([[self options] isKindOfClass:[NSDictionary class]]) {
						//NSAssert([[self options] isKindOfClass:[NSDictionary class]], @"String value must point to a dictionary of options");
						[[_cell detailLabel] setText:[NSString stringWithFormat:@"%@", [[self options] objectForKey:value]]];
					} else {
						NSAssert(false, @"Option must be either array or dictionary");
					}
				} else {
					[[_cell detailLabel] setText:@"select"];
				}
			}
			break;
		default:
			break;
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
