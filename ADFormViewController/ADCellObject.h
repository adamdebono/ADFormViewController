//
//  ADCellObject.h
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADFormViewConstants.h"
#import "ADTableViewCell.h"

@interface ADCellObject : NSObject

+ (ADCellObject *)cellWithType:(ADFormCellType)type;

@property (nonatomic) ADFormCellType type;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *title;
@property (nonatomic) id value;
- (void)setValue:(id)value updateCell:(BOOL)updateCell;
@property (nonatomic, getter = isEnabled) BOOL enabled;

@property (nonatomic, copy) BOOL (^cellPressedAction)(void);
@property (nonatomic) id options;
@property (nonatomic) NSArray *optionSectionTitles;
@property (nonatomic, copy) NSComparator optionValueSortComparator;
@property (nonatomic, copy) NSString *(^optionSectionTitleGetter)(NSString *value);
@property (nonatomic, copy) NSString *(^optionSectionIndexGetter)(NSString *sectionTitle);

@property (nonatomic, readonly) ADTableViewCell *cell;
- (void)setCustomCell:(UITableViewCell *)cell;

- (void)didSelect;
- (void)didDeselect;

- (BOOL)hasTextField;
- (UITextField *)textField;

- (BOOL)hasTextView;
- (UITextView *)textView;

- (BOOL)hasDatePicker;
- (UIDatePicker *)datePicker;
@property (nonatomic) UIDatePickerMode datePickerMode;
@property (nonatomic, copy) NSDateFormatter *dateFormatter;

- (BOOL)hasToggle;
- (UISwitch *)toggle;

@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) UITableViewCellStyle standardCellStyle;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *disabledBackgroundColor;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *disabledTextColor;

@end
