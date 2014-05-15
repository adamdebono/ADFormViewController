//
//  ADTableViewCell.h
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ADCellObject;

@interface ADTableViewCell : UITableViewCell

+ (NSString *)nibName;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, weak) ADCellObject *cellObject;

@property (nonatomic) IBOutlet UILabel *label;
@property (nonatomic) IBOutlet UILabel *detailLabel;

@property (nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;

@property (nonatomic) BOOL roundedSectionCorners;

@end
