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
#import "ADPickerCell.h"
#import "ADTextFieldCell.h"
#import "ADTextAreaCell.h"

@interface ADCellObject () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

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
		
		_options = nil;
		_optionValueSortComparator = NULL;
		_optionSectionTitleGetter = NULL;
		
		_cellPressedAction = NULL;
		_enabled = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formCellWasSelected:) name:ADFormCellDidSelect object:nil];
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
				break;
			case ADFormCellTypePicker:
				_cell = [[ADPickerCell alloc] init];
				[[self picker] setDataSource:self];
				[[self picker] setDelegate:self];
				NSAssert([self options], @"Must provide options");
				[self setValue:_value];
				break;
			case ADFormCellTypeText:
				_cell = [[ADTextFieldCell alloc] init];
				
				if (![self value]) {
					_value = @"";
				}
				[[self textField] setText:[NSString stringWithFormat:@"%@", [self value]]];
				break;
			case ADFormCellTypeTextArea:
				_cell = [[ADTextAreaCell alloc] init];
				
				if (![self value]) {
					_value = @"";
				}
				[[self textView] setText:[NSString stringWithFormat:@"%@", [self value]]];
				break;
		}
		
		if ([_cell label]) {
			[[_cell label] setText:[self title]];
		}
		[_cell setCellObject:self];
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
	[self setValue:value updateCell:YES];
}

- (void)setOptions:(id)options {
	_options = options;
	
	switch ([self type]) {
		case ADFormCellTypePicker:
			if ([[self options] isKindOfClass:[NSArray class]]) {
				//ensure that we have a 2 dimensional array
				if (![[[self options] firstObject] isKindOfClass:[NSArray class]] && ![[[self options] firstObject] isKindOfClass:[NSDictionary class]]) {
					NSArray *newOptions = [NSArray arrayWithObject:_options];
					_options = newOptions;
				}
			} else if ([[self options] isKindOfClass:[NSDictionary class]]) {
				//ensure we have 2 dimensions
				NSArray *newOptions = [NSArray arrayWithObject:_options];
				_options = newOptions;
			}
			break;
		default:
			break;
	}
}

- (void)setOptionSectionTitles:(NSArray *)optionSectionTitles {
	_optionSectionTitles = optionSectionTitles;
	
	switch ([self type]) {
		case ADFormCellTypePicker:
			NSAssert([[self options] count] == [[self optionSectionTitles] count], @"There must be a section title for each section in options");
			break;
		default:
			break;
	}
}

- (void)setValue:(id)value updateCell:(BOOL)updateCell {
	_value = value;
	
	if (updateCell) {
		switch ([self type]) {
			case ADFormCellTypeButton:
			case ADFormCellTypeDoneButton:
				break;
			case ADFormCellTypeDate:
				NSAssert([value isKindOfClass:[NSDate class]], @"Date cell must be given a date value");
				if (_cell) {
					[(ADDateCell *)[self cell] setDate:value];
				}
				break;
			case ADFormCellTypeSingleOption:
				if (_cell) {
					if (value && (![value isKindOfClass:[NSString class]] || [value length] > 0)) {
						if ([[self options] isKindOfClass:[NSArray class]]) {
							//NSAssert([[self options] isKindOfClass:[NSArray class]], @"Number value must point to an array of options");
							if ([value isKindOfClass:[NSNumber class]]) {
								_value = [NSString stringWithFormat:@"%@", [[self options] objectAtIndex:[value integerValue]]];
							}
							[[_cell detailLabel] setText:[self value]];
						} else if ([[self options] isKindOfClass:[NSDictionary class]]) {
							//NSAssert([[self options] isKindOfClass:[NSDictionary class]], @"String value must point to a dictionary of options");
							//[[_cell detailLabel] setText:[NSString stringWithFormat:@"%@", [[self options] objectForKey:value]]];
							[[_cell detailLabel] setText:[NSString stringWithFormat:@"%@", [[self options] objectForKey:value]]];
						} else {
							NSAssert(false, @"Option must be either array or dictionary");
						}
					} else {
						[[_cell detailLabel] setText:@"select"];
					}
				}
				break;
			case ADFormCellTypePicker:
				if (!value) {
					value = [NSMutableArray array];
					for (int i=0; i<[self.options count]; i++) {
						[value addObject:@0];
					}
					_value = value;
				}
				
				if (_cell) {
					NSAssert([value isKindOfClass:[NSArray class]], @"Must be an array");
					NSAssert([value count] == [[self options] count], @"Value must have the same number of components as the options");
					
					NSMutableString *str = [NSMutableString string];
					
					for (NSInteger i=0; i<[value count]; i++) {
						id component = [[self options] objectAtIndex:i];
						id componentValue = [value objectAtIndex:i];
						if ([component isKindOfClass:[NSArray class]]) {
							NSAssert([componentValue isKindOfClass:[NSNumber class]], @"Component value must be a number when options are an array");
							[[self picker] selectRow:[componentValue integerValue] inComponent:i animated:NO];
							[str appendFormat:@" %@", [[[self options] objectAtIndex:i] objectAtIndex:[componentValue integerValue]]];
						} else if ([component isKindOfClass:[NSDictionary class]]) {
							NSAssert([componentValue isKindOfClass:[NSString class]], @"Component value must be a string when options are a dictionary");
							
						}
						
						if ([self optionSectionTitles]) {
							[str appendFormat:@" %@", [[self optionSectionTitles] objectAtIndex:i]];
						}
					}
					[[self textField] setText:str];
				}
				break;
			case ADFormCellTypeText:
				if (!_value) {
					_value = @"";
				}
				if (_cell) {
					[[self textField] setText:[NSString stringWithFormat:@"%@", [self value]]];
				}
				break;
			case ADFormCellTypeTextArea:
				if (!_value) {
					_value = @"";
				}
				if (_cell) {
					[[self textView] setText:[NSString stringWithFormat:@"%@", [self value]]];
				}
				break;
		}
	}
}

#pragma mark - Text Field

- (BOOL)hasTextField {
	switch ([self type]) {
		case ADFormCellTypeText:
		case ADFormCellTypeDate:
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
		case ADFormCellTypePicker:
			return [(ADTextFieldCell *)[self cell] textField];
			break;
		default:
			return nil;
			break;
	}
}

#pragma mark - Text View

- (BOOL)hasTextView {
	switch ([self type]) {
		case ADFormCellTypeTextArea:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (UITextView *)textView {
	switch ([self type]) {
		case ADFormCellTypeTextArea:
			return [(ADTextAreaCell *)[self cell] textView];
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

#pragma mark - Picker View

- (BOOL)hasPicker {
	switch ([self type]) {
		case ADFormCellTypePicker:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (UIPickerView *)picker {
	switch ([self type]) {
		case ADFormCellTypePicker:
			return [(ADPickerCell *)[self cell] picker];
			break;
		default:
			return nil;
			break;
	}
}

#pragma mark Picker View Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return [[self options] count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	id rows = [[self options] objectAtIndex:component];
	return [rows count];
}

#pragma mark Picker View Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	id rows = [[self options] objectAtIndex:component];
	id val = nil;
	if ([rows isKindOfClass:[NSArray class]]) {
		val = [rows objectAtIndex:row];
	} else if ([rows isKindOfClass:[NSDictionary class]]) {
		val = [[rows allValues] objectAtIndex:row];
	}
	
	return [NSString stringWithFormat:@"%@", val];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSMutableArray *values = [_value mutableCopy];
	id rows = [[self options] objectAtIndex:component];
	if ([rows isKindOfClass:[NSArray class]]) {
		[values replaceObjectAtIndex:component withObject:@(row)];
	}
	
	[self setValue:values];
}

#pragma mark -

- (void)didSelect {
	switch ([self type]) {
		case ADFormCellTypePicker:
			[[self textField] setTextColor:[UIColor redColor]];
			break;
		default:
			break;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ADFormCellDidSelect object:self];
}

- (void)formCellWasSelected:(NSNotification *)note {
	if ([note object] != self) {
		[self didDeselect];
	}
}

- (void)didDeselect {
	switch ([self type]) {
		case ADFormCellTypePicker:
			[[self textField] setTextColor:[UIColor blackColor]];
			break;
		default:
			break;
	}
}

#pragma mark - Cell Size

- (CGFloat)cellHeight {
	if ([self type] == ADFormCellTypeTextArea) {
		//		[[self textView] setText:[self value]];
		CGSize size = [[self textView] sizeThatFits:CGSizeMake([[self textView] frame].size.width, FLT_MAX)];
		return MAX(size.height + 1, 44);
	} else if ([self type] == ADFormCellTypePicker) {
		return [[self cell] isSelected] ? 230 : 44;
	}
	
	return UITableViewAutomaticDimension;
}

#pragma mark - Styling

- (void)setBackgroundColor:(UIColor *)backgroundColor {
	_backgroundColor = backgroundColor;
	
	[[self cell] setBackgroundColor:backgroundColor];
}

- (void)setTextColor:(UIColor *)textColor {
	_textColor = textColor;
	
	[[[self cell] label] setTextColor:textColor];
	[[[self cell] detailLabel] setTextColor:textColor];
	[[self textField] setTextColor:textColor];
}

@end
