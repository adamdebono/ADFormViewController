//
//  ADFormViewController.h
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADFormViewConstants.h"

@interface ADFormViewController : UITableViewController

@property (nonatomic) UIReturnKeyType returnKeyType;

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle;
- (void)insertSectionAtIndex:(NSUInteger)index withHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle;
- (void)setCellAtIndexPath:(NSIndexPath *)indexPath withIdentifier:(NSString *)identifer title:(NSString *)title type:(ADFormCellType)type;

@end
