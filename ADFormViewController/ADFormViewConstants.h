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
	ADFormCellTypeButton,
	ADFormCellTypeDatePicker,
	ADFormCellTypeDoneButton,
	ADFormCellTypeSingleOption,
	ADFormCellTypeMultipleOption,
	ADFormCellTypePicker,
	ADFormCellTypeText,
	ADFormCellTypeTextArea,
	ADFormCellTypeToggle
};

static NSString *const ADFormCellDidSelect = @"ADFormCellDidSelect";

#endif
