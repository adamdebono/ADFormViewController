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
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self reloadOnAppear]) {
		_reloadOnAppear = NO;
		[self reload];
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

#pragma mark - Sections

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle {
	[self insertSectionAtIndex:[[self tableViewContent] count] withHeaderTitle:headerTitle andFooterTitle:footerTitle];
}

- (void)insertSectionAtIndex:(NSUInteger)index withHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle {
	//make sure there is enough sections before it
	while (index > [[self tableViewContent] count] - 1) {
		[self addSectionWithHeaderTitle:nil andFooterTitle:nil];
	}
	
	ADSectionObject *section = [ADSectionObject sectionWithHeaderTitle:headerTitle footerTitle:footerTitle];
	
	[[self tableViewContent] insertObject:section atIndex:index];
	
	[self reload];
}

#pragma mark - Cells

- (void)setCellAtIndexPath:(NSIndexPath *)indexPath withIdentifier:(NSString *)identifer title:(NSString *)title type:(ADFormCellType)type {
	//make sure there is enough sections
	while ([indexPath section] >= [[self tableViewContent] count] - 1) {
		[self addSectionWithHeaderTitle:nil andFooterTitle:nil];
	}
	
	ADSectionObject *sectionObject = [[self tableViewContent] objectAtIndex:[indexPath section]];
	ADCellObject *cellObject = [ADCellObject cell];
	
	[[sectionObject cells] addObject:cellObject];
	
	[self reload];
}

#pragma mark - Table View Data Source

- (void)reload {
	if (![self onScreen]) {
		_reloadOnAppear = YES;
		return;
	}
	
	[[self textFieldCellIndexPaths] removeAllObjects];
	
	__block BOOL last = YES;
	[[self tableViewContent] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ADSectionObject *sectionObject, NSUInteger section, BOOL *stop) {
		[[sectionObject cells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ADCellObject *cellObject, NSUInteger row, BOOL *stop) {
			if ([cellObject type] == ADFormCellTypeText) {
				if (last) {
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
	
	[[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self tableViewContent] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	ADSectionObject *sectionObject = [[self tableViewContent] objectAtIndex:section];
	return [[sectionObject cells] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ADCellObject *cellObject = [[[[self tableViewContent] objectAtIndex:[indexPath row]] cells] objectAtIndex:[indexPath row]];
	return [cellObject cell];
}

#pragma mark - Table View Delegate

#pragma mark - Text Field Delegate

@end
