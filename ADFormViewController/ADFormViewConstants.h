//
//  ADFormViewConstants.h
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#ifndef ADFormViewController_ADFormViewConstants_h
#define ADFormViewController_ADFormViewConstants_h

typedef NS_ENUM(NSInteger, ADFormCellType) {
	ADFormCellTypeButton = 0,
	ADFormCellTypeCustom = 1,
	ADFormCellTypeDatePicker = 2,
	ADFormCellTypeDoneButton = 3,
	ADFormCellTypeSingleOption = 4,
	ADFormCellTypeMultipleOption = 5,
	ADFormCellTypePicker = 6,
	ADFormCellTypeStandard = 7,
	ADFormCellTypeText = 8,
	ADFormCellTypeTextArea = 9,
	ADFormCellTypeToggle = 10
};

static NSString *const ADFormCellDidSelect = @"ADFormCellDidSelect";

#endif
