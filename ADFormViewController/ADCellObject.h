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
@property (nonatomic, copy) NSComparator optionValueSortComparator;
@property (nonatomic, copy) NSString *(^optionSectionTitleGetter)(NSString *value);
@property (nonatomic, copy) NSString *(^optionSectionIndexGetter)(NSString *sectionTitle);

@property (nonatomic, readonly) ADTableViewCell *cell;

- (BOOL)hasTextField;
- (UITextField *)textField;

- (BOOL)hasDatePicker;
- (UIDatePicker *)datePicker;

@end
