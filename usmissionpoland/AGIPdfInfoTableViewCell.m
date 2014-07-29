//
//  AGIPdfInfoTableViewCell.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 10.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIPdfInfoTableViewCell.h"
#import "LanguageSettings.h"
#import "NSDate+LocalizedFormatting.h"
#import "NSArray+LayoutConstraints.h"
#import "AppDelegate.h"

typedef enum {
    AGIPdfInfoFileStatusNotDownloaded,
    AGIPdfInfoFileStatusDownloadingInProgress,
    AGIPdfInfoFileStatusDownloaded
} AGIPdfInfoFileStatus;

@interface AGIPdfInfoTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UIImageView *savedIndicator;
@property (weak, nonatomic) IBOutlet UIView *updateIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadIndicator;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *normalFontLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *normalFontButtons;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *veryLargeSpaceConstraints;

@property (nonatomic, assign) AGIPdfInfoFileStatus fileStatus;
@property (nonatomic, assign) BOOL updateAvailable;

@end

@implementation AGIPdfInfoTableViewCell

static NSString *const downloadImageName = @"file_manager-download";
static NSString *const savedImageName = @"file_manager-downloaded";

+ (UIFont *)defaultNameLabelFont
{
    return [UIFont fontWithName:DEFAULT_FONT_REGULAR size:17.0f];
}

+ (CGFloat)defaultNameLabelInset
{
    CGFloat rightInset = 34.0f;
    CGFloat leftInset = [AppDelegate veryLargeSpace];
    return leftInset + rightInset;
}

+ (CGFloat)defaultNameLabelMaxHeight
{
    return 39.0f;
}

+ (CGFloat)defaultConstantHeight
{
    CGFloat infoLineHeight = 13.0f;
    
    return infoLineHeight + 2 * [AppDelegate mediumSpace] + [AppDelegate smallSpace];
}

+ (NSUInteger)defaultNameLabelMaxNumOfLines
{
    return 2;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self hideUtilityButtonsAnimated:NO];
    self.fileStatus = AGIPdfInfoFileStatusNotDownloaded;
    self.updateAvailable = NO;
    
    for (UILabel *label in self.normalFontLabels)
    {
        [label setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:label.font.pointSize]];
    }
    for (UIButton *button in self.normalFontButtons)
    {
        [button.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:button.titleLabel.font.pointSize]];
    }
    
    [self localizeView];
}

- (void)setUpdateLabel:(UILabel *)updateLabel
{
    _updateLabel = updateLabel;
    
    [self localizeUpdateLabel];
}

- (void)setSendButton:(UIButton *)sendButton
{
    _sendButton = sendButton;
    
    [self localizeSendButton];
}

- (void)setModel:(PdfInfo *)model
{
    _model = model;
    
    if (!_model)
        return;
    
    [self.nameLabel setText:[_model localizedName]];
    NSNumberFormatter *sizeFormatter = [[NSNumberFormatter alloc] init];
    [sizeFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [sizeFormatter setMaximumFractionDigits:2];
    [self.sizeLabel setText:[sizeFormatter stringFromNumber:_model.size]];
    
    [self localizeUpdateDateLabel];
    
    if (_model.downloadInProgress)
        self.fileStatus = AGIPdfInfoFileStatusDownloadingInProgress;
    else
        self.fileStatus = (_model.fileVersion) ? AGIPdfInfoFileStatusDownloaded : AGIPdfInfoFileStatusNotDownloaded;
    
    self.updateAvailable = [_model isUpdateAvailable];
    
    [self setNeedsLayout];
}

- (void)setFileStatus:(AGIPdfInfoFileStatus)fileStatus
{
    _fileStatus = fileStatus;
    
    switch (_fileStatus) {
        case AGIPdfInfoFileStatusDownloaded:
        case AGIPdfInfoFileStatusNotDownloaded:
            [self.downloadIndicator stopAnimating];
            
            [self.savedIndicator setImage:[UIImage imageNamed:([self.model fileVersion]) ? savedImageName : downloadImageName]];
            [self.savedIndicator setHidden:NO];
            break;
            
        case AGIPdfInfoFileStatusDownloadingInProgress:
            [self.downloadIndicator startAnimating];
            
            [self.savedIndicator setHidden:YES];
            break;
    }
}

- (void)setUpdateAvailable:(BOOL)updateAvailable
{
    _updateAvailable = updateAvailable;
    
    [self.updateIndicator setHidden:!_updateAvailable];
    
    [self.updateLabel setTextColor:(_updateAvailable) ? [UIColor blackColor] : [UIColor lightGrayColor]];
    [self.updateDateLabel setTextColor:(_updateAvailable) ? [UIColor colorWithRed:253.0f/255.0f green:104.0f/255.0f blue:26.0f/255.0f alpha:1.0] : [UIColor lightGrayColor]];
}

- (void)downloadingStarted
{
    self.fileStatus = AGIPdfInfoFileStatusDownloadingInProgress;
}

- (void)downloadingFinished:(BOOL)success
{
    self.fileStatus = (success) ? AGIPdfInfoFileStatusDownloaded : AGIPdfInfoFileStatusNotDownloaded;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.veryLargeSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate veryLargeSpace]];
}

- (void)layoutSubviews
{
    [self.nameLabel setPreferredMaxLayoutWidth:self.nameLabel.frame.size.width];
    
    [super layoutSubviews];
}

#pragma mark - Localization

- (void)localizeView
{
    [self localizeSendButton];
    [self localizeUpdateDateLabel];
    [self localizeUpdateLabel];
}

- (void)localizeSendButton
{
    NSString *buttonText;
    switch ([[LanguageSettings sharedSettings] currentLanguage])
    {
        case LanguagePolish:
            buttonText = @"Wyślij »";
            break;
            
        default:
            buttonText = @"Send »";
            break;
    }
    [self.sendButton setTitle:buttonText forState:UIControlStateNormal];
}

- (void)localizeUpdateDateLabel
{
    NSString *updateDateString = [[_model updated] localizedStringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    [self.updateDateLabel setText:updateDateString];
}

- (void)localizeUpdateLabel
{
    NSString *labelText;
    switch ([[LanguageSettings sharedSettings] currentLanguage])
    {
        case LanguagePolish:
            labelText = @"Zmiana: ";
            break;
            
        default:
            labelText = @"Update: ";
            break;
    }
    [self.updateLabel setText:labelText];
}

#pragma mark - Actions

- (IBAction)didTapSendButton:(id)sender
{
    [self.pdfInfoDelegate pdfInfoTableViewCell:self sendEmailWithContensOfPdfInfo:self.model];
}

@end
