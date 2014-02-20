//
//  ADFormViewController.m
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADFormViewController.h"

#import "ADSectionObject.h"
#import "ADCellObject.h"

#import "ADTableViewCell.h"
#import "ADTextFieldCell.h"
#import "ADFormOptionsViewController.h"

#import "UIImage+bundle.h"

@interface ADFormViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic) NSMutableArray *tableViewContent;
@property (nonatomic) NSMutableArray *selectableCellIndexPaths;

@property (nonatomic) UIToolbar *keyboardToolbar;
@property (nonatomic) UIBarButtonItem *toolbarPrevButton;
@property (nonatomic) UIBarButtonItem *toolbarNextButton;

@property (nonatomic) BOOL reloadOnAppear;
@property (nonatomic) BOOL onScreen;

@end

@implementation ADFormViewController

- (id)init {
	if (self = [super init]) {
		[self combinedInit];
	}
	
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		[self combinedInit];
	}
	
	return self;
}

- (void)awakeFromNib {
	[self combinedInit];
}

- (void)combinedInit {
	_tableViewContent = [NSMutableArray array];
	_selectableCellIndexPaths = [NSMutableArray array];
	
	_onScreen = NO;
	_reloadOnAppear = NO;
	
	_returnKeyType = UIReturnKeyGo;
	_showsKeyboardToolbar = NO;
	_toolbarClass = Nil;
	_doneAction = NULL;
	
	_formEditingEnabled = YES;
}

- (void)setToolbarClass:(Class)toolbarClass {
	NSAssert([toolbarClass isSubclassOfClass:[UIToolbar class]], @"Custom toolbar class must be a subclass of UIToolbar");
	
	_toolbarClass = toolbarClass;
	
	_keyboardToolbar = nil;
}

- (UIToolbar *)keyboardToolbar {
	if (!_keyboardToolbar) {
		Class ktClass = [self toolbarClass];
		if (ktClass == Nil) {
			ktClass = [UIToolbar class];
		}
		
		_keyboardToolbar = [[ktClass alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
		
		NSString *path = [[NSBundle mainBundle] pathForResource:@"ADFormViewControllerResources" ofType:@"bundle"];
		NSBundle *bundle = [NSBundle bundleWithPath:path];
		
		UIImage *leftImage = [UIImage imageNamed:@"arrow-backward" bundle:bundle];
		UIImage *rightImage = [UIImage imageNamed:@"arrow-forward" bundle:bundle];
		
		_toolbarPrevButton = [[UIBarButtonItem alloc] initWithImage:leftImage style:UIBarButtonItemStylePlain target:self action:@selector(previousCell)];
		_toolbarNextButton = [[UIBarButtonItem alloc] initWithImage:rightImage style:UIBarButtonItemStylePlain target:self action:@selector(nextCell)];
		
		UIBarButtonItem *midSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
		[midSeparator setWidth:20];
		
		UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
		UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeKeyboard)];
		
		[[self keyboardToolbar] setItems:@[[self toolbarPrevButton], midSeparator, [self toolbarNextButton], separator, doneItem]];
	}
	
	return _keyboardToolbar;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
		[[self tableView] setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self reloadOnAppear]) {
		_reloadOnAppear = NO;
		[self reload:NO];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	_onScreen = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	_onScreen = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark - Perform Action

- (void)performDoneAction {
	[[self findFirstResponder] resignFirstResponder];
	
	if ([self validateFields]) {
		if ([self doneAction]) {
			[self doneAction]([self allValues]);
		}
	}
}

- (BOOL)validateFields {
	return YES;
}

#pragma mark - Sections

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle {
	[self insertSectionAtIndex:[[self tableViewContent] count] withHeaderTitle:headerTitle andFooterTitle:footerTitle];
}

- (void)insertSectionAtIndex:(NSUInteger)index withHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle {
	if ([[self tableViewContent] count] < index) {
		[self insertSectionAtIndex:index-1 withHeaderTitle:nil andFooterTitle:nil];
	}
	
	ADSectionObject *section = [ADSectionObject sectionWithHeaderTitle:headerTitle footerTitle:footerTitle];
	
	[[self tableViewContent] insertObject:section atIndex:index];
	
	[self reload];
}

#pragma mark - Cells

- (void)addCellInSection:(NSUInteger)section withIdentifier:(NSString *)identifer title:(NSString *)title type:(ADFormCellType)type {
	ADCellObject *cellObject = [ADCellObject cellWithType:type];
	
	[cellObject setIdentifier:identifer];
	[cellObject setTitle:title];
	
	[self addCellInSection:section withCellObject:cellObject];
}

- (void)addCellInSection:(NSUInteger)section withCellObject:(ADCellObject *)cellObject {
	if ([[self tableViewContent] count] <= section) {
		[self insertSectionAtIndex:section withHeaderTitle:nil andFooterTitle:nil];
	}
	
	ADSectionObject *sectionObject = [[self tableViewContent] objectAtIndex:section];
	[[sectionObject cells] addObject:cellObject];
	
	[self reload];
}

- (void)addCellsInSection:(NSUInteger)section withCellObjects:(NSArray *)cellObjects {
	for (ADCellObject *cellObject in cellObjects) {
		if ([cellObject isKindOfClass:[ADCellObject class]]) {
			[self addCellInSection:section withCellObject:cellObject];
		}
	}
}

#pragma mark - Values

- (id)valueForIdentifier:(NSString *)identifier {
	for (ADSectionObject *sectionObject in [self tableViewContent]) {
		for (ADCellObject *cellObject in [sectionObject cells]) {
			if ([[cellObject identifier] isEqualToString:identifier]) {
				return [cellObject value];
			}
		}
	}
	
	return nil;
}

- (NSDictionary *)allValues {
	NSMutableDictionary *values = [NSMutableDictionary dictionary];
	for (ADSectionObject *sectionObject in [self tableViewContent]) {
		for (ADCellObject *cellObject in [sectionObject cells]) {
			switch ([cellObject type]) {
				case ADFormCellTypeButton:
				case ADFormCellTypeDoneButton:
					break;
				default:
					if ([cellObject value]) {
						[values setValue:[cellObject value] forKey:[cellObject identifier]];
					} else {
						[values setValue:[NSNull null] forKey:[cellObject identifier]];
					}
					break;
			}
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:values];
}

#pragma mark - Table View

#pragma mark Data Source

- (void)reload {
	[self reload:YES];
}

- (void)reload:(BOOL)check {
	if (![self onScreen] && check) {
		_reloadOnAppear = YES;
		return;
	}
	
	[[self selectableCellIndexPaths] removeAllObjects];
	
	__block BOOL last = YES;
	[[self tableViewContent] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ADSectionObject *sectionObject, NSUInteger section, BOOL *stop) {
		[[sectionObject cells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ADCellObject *cellObject, NSUInteger row, BOOL *stop) {
			if ([cellObject type] == ADFormCellTypeText) {
				if (last) {
					last = NO;
					[[cellObject textField] setReturnKeyType:[self returnKeyType]];
				} else {
					[[cellObject textField] setReturnKeyType:UIReturnKeyNext];
				}
				
				[[cellObject textField] setDelegate:self];
				[[self selectableCellIndexPaths] insertObject:[NSIndexPath indexPathForRow:row inSection:section] atIndex:0];
			} else if ([cellObject type] == ADFormCellTypeDate) {
				[[cellObject textField] setDelegate:self];
				[[self selectableCellIndexPaths] insertObject:[NSIndexPath indexPathForRow:row inSection:section] atIndex:0];
			} else if ([cellObject type] == ADFormCellTypeTextArea) {
				[[cellObject textView] setDelegate:self];
				[[self selectableCellIndexPaths] insertObject:[NSIndexPath indexPathForRow:row inSection:section] atIndex:0];
			}
		}];
	}];
	
	NSInteger i=0;
	for (NSIndexPath *indexPath in [self selectableCellIndexPaths]) {
		ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
		//ADTextFieldCell *cell = (ADTextFieldCell *)[cellObject cell];
		//[[cell textField] setTag:i];
		if ([cellObject hasTextField]) {
			[[cellObject textField] setTag:i];
		} else if ([cellObject hasTextView]) {
			[[cellObject textView] setTag:i];
		}
		
		i++;
	}
	
	[[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self tableViewContent] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	ADSectionObject *sectionObject = [[self tableViewContent] objectAtIndex:section];
	return [sectionObject headerTitle];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	ADSectionObject *sectionObject = [[self tableViewContent] objectAtIndex:section];
	return [sectionObject footerTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	ADSectionObject *sectionObject = [[self tableViewContent] objectAtIndex:section];
	return [[sectionObject cells] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	return [cellObject cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	
	CGFloat height = [cellObject cellHeight];
	
	//	NSLog(@"%@ -> %f", indexPath, height);
	
	return height;
}

#pragma mark Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ADFormOptionsViewController *optionsViewController;
	
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	if ([cellObject isEnabled] && (![cellObject cellPressedAction] || [cellObject cellPressedAction]())) {
		switch ([cellObject type]) {
			case ADFormCellTypeDoneButton:
				[self performDoneAction];
			case ADFormCellTypeButton:
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				break;
			case ADFormCellTypeDate:
			case ADFormCellTypeText:
				[[cellObject textField] becomeFirstResponder];
				break;
			case ADFormCellTypeSingleOption:
				[[self findFirstResponder] resignFirstResponder];
				
				optionsViewController = [[ADFormOptionsViewController alloc] initWithStyle:UITableViewStylePlain];
				[optionsViewController setCellObject:cellObject];
				
				NSAssert([self navigationController], @"Options cells can only be used in a navigation controller context");
				[[self navigationController] pushViewController:optionsViewController animated:YES];
				break;
			case ADFormCellTypeTextArea:
				[[cellObject textView] becomeFirstResponder];
		}
	}
}

#pragma mark - Text Fields & Views

- (UIView *)findFirstResponder {
	return [self findFirstResponderForView:[self view]];
}

- (UIView *)findFirstResponderForView:(UIView *)view {
    if ([view isFirstResponder]) {
        return view;
    }
	
    for (UIView *subView in [view subviews]) {
        UIView *firstResponder = [self findFirstResponderForView:subView];
		
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
	
    return nil;
}

- (BOOL)hasPreviousCell {
	id field = [self findFirstResponder];
	return [field tag] > 0;
}

- (BOOL)hasNextCell {
	id field = [self findFirstResponder];
	return [field tag] < [[self selectableCellIndexPaths] count] - 1;
}

- (void)previousCell {
	if (![self hasPreviousCell]) {
		return;
	}
	
	id field = [self findFirstResponder];
	[self selectCellWithTag:[field tag]-1];
}

- (void)nextCell {
	if (![self hasNextCell]) {
		return;
	}
	
	id field = [self findFirstResponder];
	[self selectCellWithTag:[field tag]+1];
}

- (void)selectCellWithTag:(NSUInteger)tag {
	NSIndexPath *indexPath = [[self selectableCellIndexPaths] objectAtIndex:tag];
	
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	if ([cellObject hasTextField]) {
		[[cellObject textField] becomeFirstResponder];
	} else if ([cellObject hasTextView]) {
		[[cellObject textView] becomeFirstResponder];
	}
}

- (void)closeKeyboard {
	[[self findFirstResponder] resignFirstResponder];
}

#pragma mark Text Field Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	NSIndexPath *indexPath = [[self selectableCellIndexPaths] objectAtIndex:[textField tag]];
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	
	if ([self isFormEditingEnabled] && [cellObject isEnabled]) {
		if ([self showsKeyboardToolbar]) {
			[[cellObject textField] setInputAccessoryView:[self keyboardToolbar]];
		}
		
		return YES;
	}
	
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	NSIndexPath *indexPath = [[self selectableCellIndexPaths] objectAtIndex:[textField tag]];
	[[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	
	[[self toolbarPrevButton] setEnabled:[self hasPreviousCell]];
	[[self toolbarNextButton] setEnabled:[self hasNextCell]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *completeString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
	
	NSIndexPath *indexPath = [[self selectableCellIndexPaths] objectAtIndex:[textField tag]];
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	[cellObject setValue:completeString updateCell:NO];
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([self hasNextCell]) {
		[self nextCell];
	} else {
		[self performDoneAction];
	}
	
	return YES;
}

#pragma mark Text View Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	NSIndexPath *indexPath = [[self selectableCellIndexPaths] objectAtIndex:[textView tag]];
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	
	if ([self isFormEditingEnabled] && [cellObject isEnabled]) {
		if ([self showsKeyboardToolbar]) {
			[[cellObject textView] setInputAccessoryView:[self keyboardToolbar]];
		}
		
		return YES;
	}
	
	return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	[[self toolbarPrevButton] setEnabled:[self hasPreviousCell]];
	[[self toolbarNextButton] setEnabled:[self hasNextCell]];
}

- (void)textViewDidChange:(UITextView *)textView {
	NSIndexPath *indexPath = [[self selectableCellIndexPaths] objectAtIndex:[textView tag]];
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	[cellObject setValue:[textView text] updateCell:NO];
	
	[[self tableView] beginUpdates];
	[[self tableView] endUpdates];
	[[cellObject textView] becomeFirstResponder];
}

@end
