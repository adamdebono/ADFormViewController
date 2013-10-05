//
//  ADDateCell.m
//  ADFormViewController
//
//  Created by Adam Debono on 5/10/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADDateCell.h"

@interface ADDateCell ()

@property (nonatomic) IBOutlet UITextField *textField;

@end

@implementation ADDateCell

- (id)init {
	if (self = [super init]) {
		_datePicker = [[UIDatePicker alloc] init];
		[[self datePicker] setDatePickerMode:UIDatePickerModeDate];
		[[self datePicker] addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
		[[self textField] setInputView:[self datePicker]];
	}
	
	return self;
}

- (void)setDate:(NSDate *)date {
	[[self datePicker] setDate:date];
	[self updateTextFieldText];
}

- (void)datePickerValueChanged:(UIDatePicker *)sender {
	[self updateTextFieldText];
}

- (void)updateTextFieldText {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterShortStyle];
	[df setTimeStyle:NSDateFormatterNoStyle];
	
	[[self textField] setText:[df stringFromDate:[[self datePicker] date]]];
}

@end
