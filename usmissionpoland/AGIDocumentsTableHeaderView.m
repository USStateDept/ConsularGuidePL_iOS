//
//  AGIDocumentsTableHeaderView.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 18.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIDocumentsTableHeaderView.h"
#import "LanguageSettings.h"
#import "NSArray+LayoutConstraints.h"
#import "AppDelegate.h"

@interface AGIDocumentsTableHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *documentsLabel;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *smallSpaceConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *veryLargeSpaceConstraints;

@end

@implementation AGIDocumentsTableHeaderView

+ (CGFloat)defaultViewHeight
{
    CGFloat titleLabelHeight = 20.0f;
    return [AppDelegate smallSpace] + titleLabelHeight + [AppDelegate mediumSpace];
}

- (void)setDocumentsLabel:(UILabel *)documentsLabel
{
    _documentsLabel = documentsLabel;
    
    [self localizeDocumentsLabel];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.smallSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate smallSpace]];
    [self.veryLargeSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate veryLargeSpace]];
}

#pragma mark - Localization

- (void)localizeView
{
    [self localizeDocumentsLabel];
}

- (void)localizeDocumentsLabel
{
    NSString *labelText;
    switch ([[LanguageSettings sharedSettings] currentLanguage])
    {
        case LanguagePolish:
            labelText = @"Dokumenty";
            break;
            
        default:
            labelText = @"Documents";
            break;
    }
    [self.documentsLabel setText:labelText];
}

@end
