//
//  ADPickerCell.h
//  Pods
//
//  Created by Adam Debono on 20/02/2014.
//
//

#import "ADTableViewCell.h"

@interface ADPickerCell : ADTableViewCell

@property (nonatomic) IBOutlet UIPickerView *picker;
@property (nonatomic) IBOutlet UITextField *textField;

@end
