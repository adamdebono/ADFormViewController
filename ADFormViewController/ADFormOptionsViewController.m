//
//  ADFormOptionsViewController.m
//  ADFormViewController
//
//  Created by Adam Debono on 5/10/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADFormOptionsViewController.h"

#import "ADCellObject.h"

@interface ADFormOptionsViewController ()

@property (nonatomic) NSArray *sections;
@property (nonatomic) NSArray *sectionTitles;
@property (nonatomic) NSArray *sectionIndexes;
@property (nonatomic) NSDictionary *sectionIndexMapping;
@property (nonatomic) NSArray *tableViewValues;

@end

@implementation ADFormOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSAssert([self cellObject], @"Must provide a cell object");
	
	[[self navigationItem] setTitle:[[self cellObject] title]];
	
	if ([[[self cellObject] options] isKindOfClass:[NSDictionary class]]) {
		if ([[self cellObject] optionValueSortComparator]) {
			_tableViewValues = [[[[self cellObject] options] allValues] sortedArrayUsingComparator:[[self cellObject] optionValueSortComparator]];
		} else {
			//_tableViewValues = [[[[self cellObject] options] allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			_tableViewValues = [[[[self cellObject] options] allValues] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
				return [obj1 compare:obj2 options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSNumericSearch];
			}];
		}
	}
	
	if ([[self cellObject] optionSectionTitleGetter]) {
		NSMutableArray *sections = [NSMutableArray array];
		NSMutableArray *sectionTitles = [NSMutableArray array];
		NSMutableArray *currentSection;
		NSString *lastSection = nil;
		
		if ([[[self cellObject] options] isKindOfClass:[NSDictionary class]]) {
			for (NSString *value in [self tableViewValues]) {
				NSString *sectionTitle = [[self cellObject] optionSectionTitleGetter](value);
				if (![sectionTitle isEqualToString:lastSection]) {
					lastSection = sectionTitle;
					currentSection = [NSMutableArray array];
					[sections addObject:currentSection];
					
					[sectionTitles addObject:sectionTitle];
				}
				
				[currentSection addObject:value];
			}
		}
		
		_sections = sections;
		_sectionTitles = sectionTitles;
		
		if ([[self cellObject] optionSectionIndexGetter]) {
			NSMutableArray *sectionIndexes = [NSMutableArray array];
			NSMutableDictionary *indexMapping = [NSMutableDictionary dictionary];
			
			NSInteger section = 0;
			NSInteger i = 0;
			for (NSString *sectionTitle in sectionTitles) {
				NSString *index = [[self cellObject] optionSectionIndexGetter](sectionTitle);
				if (![[sectionIndexes lastObject] isEqualToString:index]) {
					[sectionIndexes addObject:index];
					[indexMapping setValue:[NSString stringWithFormat:@"%li", (long)section] forKey:[NSString stringWithFormat:@"%li", (long)i]];
					
					i++;
				}
				
				section++;
			}
			
			_sectionIndexes = sectionIndexes;
			_sectionIndexMapping = indexMapping;
		}
	}
}

- (BOOL)isValueSelected:(NSString *)value {
	if ([[[self cellObject] options] isKindOfClass:[NSDictionary class]]) {
		return [[[[self cellObject] options] objectForKey:[[self cellObject] value]] isEqualToString:value];
	} else {
		return [[[self cellObject] value] isEqualToString:value];
	}
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self sections]?[[self sections] count]:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self sections]?[[[self sections] objectAtIndex:section] count]:[[[self cellObject] options] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self sections]?[[self sectionTitles] objectAtIndex:section]:nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
		
		if ([self elementColor]) {
			[cell setBackgroundColor:[self elementColor]];
		}
		if ([self textColor]) {
			[[cell textLabel] setTextColor:[self textColor]];
		}
	}
    
	id value;
	if ([self sections]) {
		value = [[[self sections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	} else if ([[[self cellObject] options] isKindOfClass:[NSArray class]]) {
		value = [[[self cellObject] options] objectAtIndex:[indexPath row]];
	} else {
		value = [[self tableViewValues] objectAtIndex:[indexPath row]];
	}
	[[cell textLabel] setText:[NSString stringWithFormat:@"%@", value]];
	
	if ([self isValueSelected:value]) {
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	} else {
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return [self sectionIndexes];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [[[self sectionIndexMapping] objectForKey:[NSString stringWithFormat:@"%li", (long)index]] integerValue];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[self cellObject] type] == ADFormCellTypeSingleOption) {
		if ([self sections]) {
			NSString *value = [[[self sections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
			NSArray *keys = [[[self cellObject] options] allKeysForObject:value];
			[[self cellObject] setValue:[keys firstObject]];
		} else if ([[[self cellObject] options] isKindOfClass:[NSArray class]]) {
			[[self cellObject] setValue:@([indexPath row])];
		} else if ([[[self cellObject] options] isKindOfClass:[NSDictionary class]]) {
			NSString *value = [[self tableViewValues] objectAtIndex:[indexPath row]];
			NSArray *keys = [[[self cellObject] options] allKeysForObject:value];
			[[self cellObject] setValue:[keys firstObject]];
		}
		
		if ([self formOptionsDelegate]) {
			[[self formOptionsDelegate] optionsViewControllerDidFinish:self];
		}
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	[tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Styling

- (void)setBackgroundColor:(UIColor *)backgroundColor {
	_backgroundColor = backgroundColor;
	
	[[self tableView] setBackgroundColor:backgroundColor];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
	_separatorColor = separatorColor;
	
	[[self tableView] setSeparatorColor:separatorColor];
}

@end
