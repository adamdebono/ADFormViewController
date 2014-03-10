//
//  ADDateCell.m
//  ADFormViewController
//
//  Created by Adam Debono on 5/10/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADDatePickerCell.h"

#import "ADCellObject.h"

@interface ADDatePickerCell ()

@end

@implementation ADDatePickerCell

- (id)init {
	if (self = [super init]) {
		[self setClipsToBounds:YES];
		
		[[self datePicker] addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
	}
	
	return self;
}

- (void)datePickerValueChanged:(UIDatePicker *)sender {
	[[self cellObject] setValue:[sender date]];
}

@end
