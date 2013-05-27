//
//  ADSectionObject.m
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADSectionObject.h"

@implementation ADSectionObject

+ (ADSectionObject *)sectionWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle {
	ADSectionObject *object = [[ADSectionObject alloc] init];
	
	[object setHeaderTitle:headerTitle];
	[object setFooterTitle:footerTitle];
	
	return object;
}

- (id)init {
	if (self = [super init]) {
		_cells = [NSMutableArray array];
	}
	
	return self;
}

- (NSString *)description {
	return [[super description] stringByAppendingFormat:@", cells: %@", [self cells]];
}

@end
