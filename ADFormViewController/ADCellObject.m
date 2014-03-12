//
//  ADCellObject.m
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADCellObject.h"

#import "ADButtonCell.h"
#import "ADDatePickerCell.h"
#import "ADOptionCell.h"
#import "ADPickerCell.h"
#import "ADToggleCell.h"
#import "ADTextFieldCell.h"
#import "ADTextAreaCell.h"

@interface ADCellObject () <UITextFieldDelegate>

@property (nonatomic) BOOL userSetDateFormatter;

@end

@implementation ADCellObject

@synthesize cell = _cell;
@synthesize dateFormatter = _dateFormatter;

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
		
		_userSetDateFormatter = NO;
		_datePickerMode = UIDatePickerModeDate;
		
		_cellHeight = UITableViewAutomaticDimension;
		
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
			case ADFormCellTypeDatePicker:
				_cell = [[ADDatePickerCell alloc] init];
				[self setValue:_value];
				break;
			case ADFormCellTypeSingleOption:
			case ADFormCellTypeMultipleOption:
				_cell = [[ADOptionCell alloc] init];
				NSAssert([self options], @"Must provide options");
				[self setValue:_value];
				break;
			case ADFormCellTypePicker:
				_cell = [[ADPickerCell alloc] init];
				NSAssert([self options], @"Must provide options");
				[_cell setCellObject:self];
				[self setValue:_value];
				break;
			case ADFormCellTypeToggle:
				_cell = [[ADToggleCell alloc] init];
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
			case ADFormCellTypeCustom:
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

- (void)setCustomCell:(UITableViewCell *)cell {
	_cell = (ADTableViewCell *)cell;
}

- (NSString *)description {
	return [[super description] stringByAppendingFormat:@" id: %@, value: %@", [self identifier], [self value]];
}

#pragma mark - Setters

- (void)setEnabled:(BOOL)enabled {
	_enabled = enabled;
	
	if ([self type] == ADFormCellTypeCustom) {
		return;
	}
	
	if (enabled) {
		[[self cell] setBackgroundColor:self.backgroundColor];
		[[[self cell] label] setTextColor:self.textColor];
		[[[self cell] detailLabel] setTextColor:self.textColor];
		[[self textField] setTextColor:self.textColor];
		
		[[self toggle] setEnabled:YES];
		[[self toggle] setOnTintColor:nil];
		[[self toggle] setThumbTintColor:nil];
	} else {
		[[self cell] setBackgroundColor:self.disabledBackgroundColor];
		[[[self cell] label] setTextColor:self.disabledTextColor];
		[[[self cell] detailLabel] setTextColor:self.disabledTextColor];
		[[self textField] setTextColor:self.disabledTextColor];
		
		[[self toggle] setEnabled:NO];
		[[self toggle] setOnTintColor:self.disabledTextColor];
		[[self toggle] setThumbTintColor:self.disabledTextColor];
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
			[[self picker] reloadAllComponents];
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
			case ADFormCellTypeDatePicker:
				if (self.datePickerMode == UIDatePickerModeCountDownTimer) {
					if (!_value) {
						[[self datePicker] setCountDownDuration:0];
						_value = [[self datePicker] date];
					} else if ([_value isKindOfClass:[NSNumber class]]) {
						[[self datePicker] setCountDownDuration:[_value doubleValue]];
						_value = [[self datePicker] date];
					}
				}
				if (value) {
					NSAssert([_value isKindOfClass:[NSDate class]], @"Date cell must be given a date value");
					[[self datePicker] setDate:_value];
					[[[self cell] detailLabel] setText:[[self dateFormatter] stringFromDate:_value]];
				} else {
					[[[self cell] detailLabel] setText:@"select"];
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
			case ADFormCellTypeMultipleOption:
				if (_cell) {
					if (value) {
						if ([value isKindOfClass:[NSArray class]]) {
							if ([value count]) {
								if ([[self options] isKindOfClass:[NSArray class]]) {
									NSMutableArray *newValue = [NSMutableArray array];
									for (id obj in value) {
										if ([obj isKindOfClass:[NSNumber class]]) {
											[newValue addObject:[NSString stringWithFormat:@"%@", [[self options] objectAtIndex:[obj integerValue]]]];
										} else {
											[newValue addObject:obj];
										}
									}
									_value = newValue;
									
									[[_cell detailLabel] setText:[newValue componentsJoinedByString:@" "]];
								} else if ([[self options] isKindOfClass:[NSDictionary class]]) {
									NSArray *theValues = [[self options] objectsForKeys:value notFoundMarker:[NSNull null]];
									[[_cell detailLabel] setText:[theValues componentsJoinedByString:@" "]];
								} else {
									NSAssert(false, @"Options must be either array or dictionary");
								}
							} else {
								[[_cell detailLabel] setText:@"select"];
							}
						} else {
							NSAssert(false, @"There must be an array of values");
						}
					} else {
						[[_cell detailLabel] setText:@"select"];
					}
				}
				break;
			case ADFormCellTypeToggle:
				if (_cell) {
					[[(ADToggleCell *)_cell toggle] setOn:[[self value] boolValue]];
					[[self toggle] addTarget:self action:@selector(toggleWasToggled:) forControlEvents:UIControlEventValueChanged];
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
					[[[self cell] detailLabel] setText:str];
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
			case ADFormCellTypeCustom:
				break;
		}
	}
}

- (void)setTitle:(NSString *)title {
	_title = title;
	
	if (_cell) {
		[[[self cell] label] setText:title];
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
		case ADFormCellTypeDatePicker:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (UIDatePicker *)datePicker {
	switch ([self type]) {
		case ADFormCellTypeDatePicker:
			return [(ADDatePickerCell *)[self cell] datePicker];
			break;
		default:
			return nil;
			break;
	}
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode {
	_datePickerMode = datePickerMode;
	
	[[self datePicker] setDatePickerMode:datePickerMode];
	if (!self.userSetDateFormatter) {
		_dateFormatter = nil;
	}
	[self setValue:_value];
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		switch (self.datePickerMode) {
			case UIDatePickerModeDate:
				[_dateFormatter setDateStyle:NSDateFormatterShortStyle];
				[_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
				break;
			case UIDatePickerModeDateAndTime:
				[_dateFormatter setDateStyle:NSDateFormatterShortStyle];
				[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			case UIDatePickerModeTime:
				[_dateFormatter setDateStyle:NSDateFormatterNoStyle];
				[_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
				break;
			case UIDatePickerModeCountDownTimer:
				[_dateFormatter setDateFormat:@"H 'Hrs' m 'Mins'"];
				break;
		}
	}
	
	return _dateFormatter;
}

- (void)setDateFormatter:(NSDateFormatter *)dateFormatter {
	_dateFormatter = dateFormatter;
	
	_userSetDateFormatter = YES;
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

#pragma mark - Toggle

- (BOOL)hasToggle {
	switch ([self type]) {
		case ADFormCellTypeToggle:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (UISwitch *)toggle {
	switch ([self type]) {
		case ADFormCellTypeToggle:
			return [(ADToggleCell *)[self cell] toggle];
			break;
		default:
			return NO;
			break;
	}
}

#pragma mark - Toggle

- (void)toggleWasToggled:(UISwitch *)sender {
	[self setValue:@([sender isOn])];
}

#pragma mark -

- (void)didSelect {
	switch ([self type]) {
		case ADFormCellTypeDatePicker:
			[[[self cell] detailLabel] setTextColor:[UIColor redColor]];
			[[self datePicker] setUserInteractionEnabled:YES];
			break;
		case ADFormCellTypePicker:
			[[[self cell] detailLabel] setTextColor:[UIColor redColor]];
			[[self picker] setUserInteractionEnabled:YES];
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
		case ADFormCellTypeDatePicker:
			[[[self cell] detailLabel] setTextColor:[self textColor]];
			[[self datePicker] setUserInteractionEnabled:NO];
			break;
		case ADFormCellTypePicker:
			[[[self cell] detailLabel] setTextColor:[self textColor]];
			[[self picker] setUserInteractionEnabled:NO];
			break;
		default:
			break;
	}
}

#pragma mark - Cell Size

- (CGFloat)cellHeight {
	if (_cellHeight == UITableViewAutomaticDimension) {
		if ([self type] == ADFormCellTypeTextArea) {
			CGSize size = [[self textView] sizeThatFits:CGSizeMake([[self textView] frame].size.width, FLT_MAX)];
			return MAX(size.height + 1, 44);
		} else if ([self type] == ADFormCellTypePicker || [self type] == ADFormCellTypeDatePicker) {
			return [[self cell] isSelected] ? 230 : 44;
		}
	}
	
	return _cellHeight;
}

#pragma mark - Styling

- (void)setBackgroundColor:(UIColor *)backgroundColor {
	_backgroundColor = backgroundColor;
	
	[[self cell] setBackgroundColor:backgroundColor];
}

- (void)setTextColor:(UIColor *)textColor {
	_textColor = textColor;
	
	switch ([self type]) {
		case ADFormCellTypeCustom:
			break;
		default:
			[[[self cell] label] setTextColor:textColor];
			[[[self cell] detailLabel] setTextColor:textColor];
			[[self textField] setTextColor:textColor];
			[[self textView] setTextColor:textColor];
			break;
	}
}

@end
