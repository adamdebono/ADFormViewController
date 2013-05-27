//
//  ADCellObject.h
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADFormViewConstants.h"
#import "ADTableViewCell.h"

@interface ADCellObject : NSObject

+ (ADCellObject *)cell;

@property (nonatomic) ADFormCellType type;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *title;
@property (nonatomic) id value;

@property (nonatomic, readonly) ADTableViewCell *cell;

@end
