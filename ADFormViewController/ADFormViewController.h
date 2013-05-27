//
//  ADFormViewController.h
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADFormViewConstants.h"
#import "ADCellObject.h"

typedef void(^ADDoneAction)(NSDictionary *values);

@interface ADFormViewController : UITableViewController

@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic, copy) ADDoneAction doneAction;

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle;
- (void)insertSectionAtIndex:(NSUInteger)index withHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle;

- (void)setCellAtIndexPath:(NSIndexPath *)indexPath withIdentifier:(NSString *)identifer title:(NSString *)title type:(ADFormCellType)type;
- (void)setCellAtIndexPath:(NSIndexPath *)indexPath withCellObject:(ADCellObject *)cellObject;

- (id)valueForIdentifier:(NSString *)identifier;
- (NSDictionary *)allValues;

@end
