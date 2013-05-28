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

@interface ADFormViewController () <UITextFieldDelegate>

@property (nonatomic) NSMutableArray *tableViewContent;
@property (nonatomic) NSMutableArray *textFieldCellIndexPaths;

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
	_textFieldCellIndexPaths = [NSMutableArray array];
	
	_onScreen = NO;
	_reloadOnAppear = NO;
	
	_returnKeyType = UIReturnKeyGo;
	_doneAction = NULL;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
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

- (void)setCellAtIndexPath:(NSIndexPath *)indexPath withIdentifier:(NSString *)identifer title:(NSString *)title type:(ADFormCellType)type {
	ADCellObject *cellObject = [ADCellObject cell];
	
	[cellObject setIdentifier:identifer];
	[cellObject setTitle:title];
	[cellObject setType:type];
	
	[self setCellAtIndexPath:indexPath withCellObject:cellObject];
}

- (void)setCellAtIndexPath:(NSIndexPath *)indexPath withCellObject:(ADCellObject *)cellObject {
	if ([[self tableViewContent] count] <= [indexPath section]) {
		[self insertSectionAtIndex:[indexPath section] withHeaderTitle:nil andFooterTitle:nil];
	}
	
	ADSectionObject *sectionObject = [[self tableViewContent] objectAtIndex:[indexPath section]];
	[[sectionObject cells] addObject:cellObject];
	
	[self reload];
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
				case ADFormCellTypeDoneButton:
					break;
				default:
					[values setValue:[cellObject value] forKey:[cellObject identifier]];
					break;
			}
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:values];
}

#pragma mark - Table View Data Source

- (void)reload {
	[self reload:YES];
}

- (void)reload:(BOOL)check {
	if (![self onScreen] && check) {
		_reloadOnAppear = YES;
		return;
	}
	
	[[self textFieldCellIndexPaths] removeAllObjects];
	
	__block BOOL last = YES;
	[[self tableViewContent] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ADSectionObject *sectionObject, NSUInteger section, BOOL *stop) {
		[[sectionObject cells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ADCellObject *cellObject, NSUInteger row, BOOL *stop) {
			if ([cellObject type] == ADFormCellTypeText) {
				if (last) {
					last = NO;
					[[(ADTextFieldCell *)[cellObject cell] textField] setReturnKeyType:[self returnKeyType]];
					[[(ADTextFieldCell *)[cellObject cell] textField] setDelegate:self];
				} else {
					[[(ADTextFieldCell *)[cellObject cell] textField] setReturnKeyType:UIReturnKeyNext];
					[[(ADTextFieldCell *)[cellObject cell] textField] setDelegate:self];
				}
				[[self textFieldCellIndexPaths] insertObject:[NSIndexPath indexPathForRow:row inSection:section] atIndex:0];
			}
		}];
	}];
	
	NSInteger i=0;
	for (NSIndexPath *indexPath in [self textFieldCellIndexPaths]) {
		ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
		ADTextFieldCell *cell = (ADTextFieldCell *)[cellObject cell];
		[cell setTag:i];
		
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

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	
	switch ([cellObject type]) {
		case ADFormCellTypeDoneButton:
			[self performDoneAction];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
		case ADFormCellTypeText:
			[[(ADTextFieldCell *)[cellObject cell] textField] becomeFirstResponder];
			break;
	}
}

#pragma mark - Text Field Delegate

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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	NSIndexPath *indexPath = [[self textFieldCellIndexPaths] objectAtIndex:[textField tag]];
	[[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *completeString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
	
	NSIndexPath *indexPath = [[self textFieldCellIndexPaths] objectAtIndex:[textField tag]];
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
	[cellObject setValue:completeString];
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField returnKeyType] == UIReturnKeyNext) {
		NSIndexPath *indexPath = [[self textFieldCellIndexPaths] objectAtIndex:[textField tag]+1];
		//make sure it's on screen
		[[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		
		ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath section]] cells] objectAtIndex:[indexPath row]];
		[[(ADTextFieldCell *)[cellObject cell] textField] becomeFirstResponder];
	} else {
		[self performDoneAction];
	}
	
	return YES;
}

@end
