//
//  ADDateCell.h
//  ADFormViewController
//
//  Created by Adam Debono on 5/10/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADTextFieldCell.h"

@interface ADDateCell : ADTableViewCell

@property (nonatomic, readonly) UIDatePicker *datePicker;

- (void)setDate:(NSDate *)date;

@end
