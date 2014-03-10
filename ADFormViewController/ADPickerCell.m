//
//  ADPickerCell.m
//  Pods
//
//  Created by Adam Debono on 20/02/2014.
//
//

#import "ADPickerCell.h"

#import "ADCellObject.h"

@interface ADPickerCell () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation ADPickerCell

- (id)init {
	if (self = [super init]) {
		[self setClipsToBounds:YES];
		
		[[self picker] setDataSource:self];
		[[self picker] setDelegate:self];
		[[self picker] reloadAllComponents];
	}
	
	return self;
}

#pragma mark Picker View Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return [[[self cellObject] options] count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	id rows = [[[self cellObject] options] objectAtIndex:component];
	return [rows count];
}

#pragma mark Picker View Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	id rows = [[[self cellObject] options] objectAtIndex:component];
	id val = nil;
	if ([rows isKindOfClass:[NSArray class]]) {
		val = [rows objectAtIndex:row];
	} else if ([rows isKindOfClass:[NSDictionary class]]) {
		val = [[rows allValues] objectAtIndex:row];
	}
	
	return [NSString stringWithFormat:@"%@", val];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSMutableArray *values = [[[self cellObject] value] mutableCopy];
	id rows = [[[self cellObject] options] objectAtIndex:component];
	if ([rows isKindOfClass:[NSArray class]]) {
		[values replaceObjectAtIndex:component withObject:@(row)];
	}
	
	[[self cellObject] setValue:values];
}


@end
