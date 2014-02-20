//
//  ADTextAreaCell.m
//  Pods
//
//  Created by Adam Debono on 20/02/2014.
//
//

#import "ADTextAreaCell.h"

@implementation ADTextAreaCell

- (id)init {
	if (self = [super init]) {
		[self.textView setScrollEnabled:NO];
	}
	
	return self;
}

@end
