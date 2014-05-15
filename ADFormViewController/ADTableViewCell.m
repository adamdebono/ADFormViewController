//
//  ADTableViewCell.m
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import "ADTableViewCell.h"

@interface ADTableViewCell ()

@property (nonatomic, copy) NSString *reuseIdentifier;

@end

@implementation ADTableViewCell
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)init {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ADFormViewControllerResources" ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:path];
	self = [[bundle loadNibNamed:[[self class] nibName] owner:self options:nil] objectAtIndex:0];
	if (self) {
		[self setReuseIdentifier:[[self class] nibName]];
		
		[[self detailLabel] setAdjustsFontSizeToFitWidth:YES];
		
		if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
			[[self leadingConstraint] setConstant:10.0f];
			[[self trailingConstraint] setConstant:10.0f];
		}
	}
	
	return self;
}

+ (NSString *)nibName {
	return NSStringFromClass([self class]);
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	if (self.roundedSectionCorners) {
		UITableView *tableView = [self tableView];
		if (tableView) {
			NSIndexPath *indexPath = [tableView indexPathForCell:self];
			if (indexPath) {
				UIRectCorner corners = 0;
				if (indexPath.row == 0) {
					corners |= UIRectCornerTopLeft | UIRectCornerTopRight;
				}
				if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
					corners |= UIRectCornerBottomLeft | UIRectCornerBottomRight;
				}
				
				if (corners != 0) {
					CAShapeLayer *shapeLayer = [CAShapeLayer layer];
					shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(10.0f, 5.0f)].CGPath;
					self.layer.mask = shapeLayer;
				} else {
					self.layer.mask = nil;
				}
			}
		}
	}
}

- (void)setRoundedSectionCorners:(BOOL)roundedSectionCorners {
	_roundedSectionCorners = roundedSectionCorners;
	[self setFrame:self.frame];
}

- (UITableView *)tableView {
	UIView *superView = self.superview;
	while (superView && ![superView isKindOfClass:[UITableView class]]) {
		superView = superView.superview;
	}
	
	return (UITableView *)superView;
}

@end
