//
//  ADFormOptionsViewController.h
//  ADFormViewController
//
//  Created by Adam Debono on 5/10/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ADCellObject;
@class ADFormOptionsViewController;

@protocol ADFormOptionsViewControllerDelegate <NSObject>
- (void)optionsViewControllerDidFinish:(ADFormOptionsViewController *)optionsViewController;
@end


@interface ADFormOptionsViewController : UITableViewController

@property (nonatomic, weak) id<ADFormOptionsViewControllerDelegate> formOptionsDelegate;

@property (nonatomic) ADCellObject *cellObject;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *separatorColor;
@property (nonatomic) UIColor *elementColor;
@property (nonatomic) UIColor *textColor;

@end
