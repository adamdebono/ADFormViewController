//
//  ADFormViewController.h
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADFormViewConstants.h"
#import "ADCellObject.h"

typedef BOOL(^ADValidateAction)(NSDictionary *values, NSString **error);
typedef void(^ADDoneAction)(NSDictionary *values);

@interface ADFormViewController : UITableViewController

@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic) BOOL showsKeyboardToolbar;
@property (nonatomic) Class toolbarClass;
@property (nonatomic, strong) ADValidateAction validateAction;
@property (nonatomic, strong) ADDoneAction doneAction;

@property (nonatomic, getter = isFormEditingEnabled) BOOL formEditingEnabled;

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle;
- (void)insertSectionAtIndex:(NSUInteger)index withHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle;

- (void)addCellInSection:(NSUInteger)section withIdentifier:(NSString *)identifer title:(NSString *)title type:(ADFormCellType)type;
- (void)addCellInSection:(NSUInteger)section withCellObject:(ADCellObject *)cellObject;
- (void)addCellsInSection:(NSUInteger)section withCellObjects:(NSArray *)cellObjects;

- (id)valueForIdentifier:(NSString *)identifier;
- (NSDictionary *)allValues;

@end
