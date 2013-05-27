//
//  ADSectionObject.h
//  ADFormViewController
//
//  Created by Adam Debono on 27/05/13.
//  Copyright (c) 2013 Adam Debono. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADSectionObject : NSObject

+ (ADSectionObject *)sectionWithHeaderTitle:(NSString *)title footerTitle:(NSString *)footerTitle;

@property (nonatomic) NSString *headerTitle;
@property (nonatomic) NSString *footerTitle;

@property (nonatomic) NSMutableArray *cells;

@end
