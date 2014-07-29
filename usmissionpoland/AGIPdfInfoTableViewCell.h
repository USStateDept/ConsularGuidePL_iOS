//
//  AGIPdfInfoTableViewCell.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 10.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "PdfInfo.h"

@class AGIPdfInfoTableViewCell;

@protocol AGIPdfInfoTableViewCellDelegate <NSObject>

- (void)pdfInfoTableViewCell:(AGIPdfInfoTableViewCell *)cell sendEmailWithContensOfPdfInfo:(PdfInfo *)pdfInfo;

@end

@interface AGIPdfInfoTableViewCell : SWTableViewCell

@property (nonatomic, strong) PdfInfo *model;

@property (nonatomic, weak) id<AGIPdfInfoTableViewCellDelegate> pdfInfoDelegate;

+ (CGFloat)defaultConstantHeight;
+ (UIFont *)defaultNameLabelFont;
+ (CGFloat)defaultNameLabelInset;
+ (CGFloat)defaultNameLabelMaxHeight;
+ (NSUInteger)defaultNameLabelMaxNumOfLines;

- (void)downloadingStarted;
- (void)downloadingFinished:(BOOL)success;

@end
