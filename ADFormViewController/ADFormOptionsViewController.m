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

@end

@implementation ADFormOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	NSAssert([self cellObject], @"Must provide a cell object");
	
	[[self navigationItem] setTitle:[[self cellObject] title]];
}

- (BOOL)isCellAtIndexPathSelected:(NSIndexPath *)indexPath {
	if ([[self cellObject] type] == ADFormCellTypeSingleOption) {
		if (![[self cellObject] value]) {
			return NO;
		}
		if ([[[self cellObject] options] isKindOfClass:[NSArray class]]) {
			if ([[[[self cellObject] options] objectAtIndex:[indexPath row]] isEqualToString:[[self cellObject] value]]) {
				return YES;
			} else {
				return NO;
			}
		} else if ([[[self cellObject] options] isKindOfClass:[NSDictionary class]]) {
			if ([[[[[self cellObject] options] allKeys] objectAtIndex:[indexPath row]] isEqualToString:[[self cellObject] value]]) {
				return YES;
			} else {
				return NO;
			}
		}
	}
	
	return NO;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self cellObject] options] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
    
	id value;
	if ([[[self cellObject] options] isKindOfClass:[NSArray class]]) {
		value = [[[self cellObject] options] objectAtIndex:[indexPath row]];
	} else {
		value = [[[self cellObject] options] objectForKey:[[[[self cellObject] options] allKeys] objectAtIndex:[indexPath row]]];
	}
	[[cell textLabel] setText:[NSString stringWithFormat:@"%@", value]];
	
	if ([self isCellAtIndexPathSelected:indexPath]) {
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	} else {
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[self cellObject] type] == ADFormCellTypeSingleOption) {
		if ([[[self cellObject] options] isKindOfClass:[NSArray class]]) {
			[[self cellObject] setValue:@([indexPath row])];
		} else if ([[[self cellObject] options] isKindOfClass:[NSDictionary class]]) {
			[[self cellObject] setValue:[[[[self cellObject] options] allKeys] objectAtIndex:[indexPath row]]];
		}
		
		[[self navigationController] popViewControllerAnimated:YES];
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	[tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

@end
