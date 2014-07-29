//
//  AGIPDFTableViewController.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 10.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIPDFTableViewController.h"
#import "AGIPdfInfoTableHeaderFooterView.h"
#import "AGIPDFContext.h"
#import "NSMutableArray+SWUtilityButtons.h"
#import "AGIFileManager.h"
#import "LanguageSettings.h"
#import "AGIDocumentsTableHeaderView.h"
#import "ALAlertBanner.h"

@interface AGIPDFTableViewController ()

@property (nonatomic, strong) NSArray *pdfInfoArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (nonatomic, assign) BOOL didRotateWhilePresentingVideo;
@property (nonatomic, assign) BOOL orientationBeforePresentingViewController;

@end

@implementation AGIPDFTableViewController

static NSString *const defaultSectionHeaderViewIdentifier = @"defaultSectionHeaderView";
static NSString *const defaultCellIdentifier = @"defaultCell";
static const NSInteger updateButtonIndex = 0;
static const NSInteger deleteButtonIndex = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pdfInfoArray = [[AGIPDFContext defaultContext] getLocallySavedPdfs];
    __weak AGIPDFTableViewController *weakSelf = self;
    [[AGIPDFContext defaultContext] getDataUsingBlock:^(NSArray *newPdfInfoArray)
    {
        AGIPDFTableViewController *blockSelf = weakSelf;
        blockSelf.pdfInfoArray = newPdfInfoArray;
        [blockSelf.tableView reloadData];
    }];
    
    UINib *defaultCellNib = [UINib nibWithNibName:@"AGIPdfInfoTableViewCell" bundle:nil];
    [self.tableView registerNib:defaultCellNib forCellReuseIdentifier:defaultCellIdentifier];
    
    [self localizeDocumentsTitle];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.tableViewTopConstraint setConstant:CGRectGetHeight(self.navBar.frame)];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.navBar setFrame:(CGRect){ .origin = self.navBar.frame.origin, .size = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.navBar.frame)) }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.didRotateWhilePresentingVideo) {
        [self didRotateFromInterfaceOrientation:self.orientationBeforePresentingViewController];
    }
    
    self.pdfInfoArray = [[AGIPDFContext defaultContext] getLocallySavedPdfs];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didPdfFileDownloaded:)
                                                 name:[AGIPDFContext downloadNotificationIdentifier]
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localizeViewWithNotification:)
                                                 name:POST_NOTIFICATION_SWITCH_LANGUAGE
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[AGIPDFContext downloadNotificationIdentifier]
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:POST_NOTIFICATION_SWITCH_LANGUAGE
                                                  object:nil];
}

#pragma mark - Handling PDF Notifications

- (void)didPdfFileDownloaded:(NSNotification *)notification
{
    PdfInfo *infoOfDownloadedPdf = [notification object];
    
    for (NSUInteger i = 0; i < [self.pdfInfoArray count]; ++i)
    {
        if ([infoOfDownloadedPdf.id isEqualToNumber:[self.pdfInfoArray[i] id]])
        {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            
            break;
        }
    }
    
    if ([infoOfDownloadedPdf fileVersion] == nil)
    {
        NSString *titleEn = @"Error occurred during downloading file";
        NSString *titlePl = @"Wystąpił błąd podczas ściągania pliku";
        
        NSString *subtitleEn = @"Please check your Internet connection";
        NSString *subtitlePl = @"Sprawdź swoje połączenie z Internetem";
        
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                            style:ALAlertBannerStyleFailure
                                                         position:ALAlertBannerPositionTop
                                                            title:([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish) ? titleEn : titlePl
                                                         subtitle:([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish) ? subtitleEn : subtitlePl];
        [banner show];
    }
}

#pragma mark - Localization

- (void)localizeView
{
    [self.tableView reloadData];
}

- (void)localizeViewWithNotification:(NSNotification *)notification
{
    [super didChangeLanguage:notification];
    [self localizeView];
}

- (void)localizeDocumentsTitle
{
    return;
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
    [self.navBar.topItem setTitle:labelText];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pdfInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PdfInfo *pdfInfoForCell = self.pdfInfoArray[indexPath.row];
    
    AGIPdfInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defaultCellIdentifier];
    cell.containingTableView = tableView;
    [cell setCellHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
    
    cell.pdfInfoDelegate = self;
    cell.delegate = self;
    cell.model = pdfInfoForCell;
    
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    NSString *updateLabel = ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? @"AKTUALIZUJ" : @"UPDATE";
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     ([pdfInfoForCell isUpdateAvailable]) ? [UIColor colorWithRed:253.0f/255.0f green:104.0f/255.0f blue:26.0f/255.0f alpha:1.0] : [UIColor darkGrayColor]
                                                title:updateLabel];
    
    NSString *deleteLabel = ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? @"USUŃ" : @"DELETE";
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     (pdfInfoForCell.fileVersion) ? [UIColor colorWithRed:188.0f/255.0f green:22.0f/255.0f blue:40.0f/255.0f alpha:1.0] : [UIColor darkGrayColor]
                                                title:deleteLabel];
    
    cell.leftUtilityButtons = leftUtilityButtons;
    cell.rightUtilityButtons = rightUtilityButtons;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat widthBound = self.tableView.bounds.size.width;
    CGFloat nameLabelWidth = widthBound - [AGIPdfInfoTableViewCell defaultNameLabelInset];
    
    PdfInfo *pdfInfoForCell = self.pdfInfoArray[indexPath.row];
    
    UILabel *nameSizingLabel = [[UILabel alloc] init];
    nameSizingLabel.font = [AGIPdfInfoTableViewCell defaultNameLabelFont];
    nameSizingLabel.text = [pdfInfoForCell localizedName];
    nameSizingLabel.numberOfLines = [AGIPdfInfoTableViewCell defaultNameLabelMaxNumOfLines];
    CGSize nameLabelSize = [nameSizingLabel sizeThatFits:CGSizeMake(nameLabelWidth, [AGIPdfInfoTableViewCell defaultNameLabelMaxHeight])];
    CGFloat nameLabelHeight = nameLabelSize.height;
    
    return nameLabelHeight + [AGIPdfInfoTableViewCell defaultConstantHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PdfInfo *selectedPdfInfo = self.pdfInfoArray[indexPath.row];
    if ([selectedPdfInfo downloadInProgress])
        return;
    
    if (selectedPdfInfo.fileVersion)
    {
        Language showPdfInLanguage = [[LanguageSettings sharedSettings] currentLanguage];
        switch (showPdfInLanguage) {
            case LanguagePolish:
                if (!selectedPdfInfo.sourceURLPl)
                    showPdfInLanguage = LanguageEnglish;
                break;
                
            case LanguageEnglish:
                if (!selectedPdfInfo.sourceURLEn)
                    showPdfInLanguage = LanguagePolish;
                break;
        }
        NSURL *pdfURL = [NSURL fileURLWithPath:[[AGIFileManager sharedInstance] filePathForPdf:selectedPdfInfo forLanguage:showPdfInLanguage]];
        
        self.didRotateWhilePresentingVideo = NO;
        self.orientationBeforePresentingViewController = self.interfaceOrientation;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateWithPresentedViewControllerVisible:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        UIDocumentInteractionController *pdfController = [UIDocumentInteractionController interactionControllerWithURL:pdfURL];
        pdfController.delegate = self;
        [pdfController setName:[selectedPdfInfo localizedName]];
        [pdfController presentPreviewAnimated:YES];
    }
    else
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        if ([selectedCell isKindOfClass:[AGIPdfInfoTableViewCell class]])
        {
            AGIPdfInfoTableViewCell *pdfInfoCell = (AGIPdfInfoTableViewCell *)selectedCell;
            [pdfInfoCell downloadingStarted];
        }
        
        [[AGIPDFContext defaultContext] downloadPdf:selectedPdfInfo];
    }
}


#pragma mark - AGIPdfInfoTableViewCellDelegate

- (void)pdfInfoTableViewCell:(AGIPdfInfoTableViewCell *)cell sendEmailWithContensOfPdfInfo:(PdfInfo *)pdfInfo
{
    if (![MFMailComposeViewController canSendMail])
    {
        NSString *titleEn = @"You can't send mail";
        NSString *titlePl = @"Nie możesz wysłać wiadomości";
        
        NSString *msgEn = @"Please check if you have added any mail account or properly configured your mail application.";
        NSString *msgPl = @"Upewnij się czy masz dodane konto pocztowe, albo czy poprawnie skonfigurowałeś klienta pocztowego.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? titlePl : titleEn
                                                        message:([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? msgPl : msgEn
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"[USEmbassy] PDF - %@/%@", pdfInfo.nameEn, pdfInfo.namePl];
    // Email Content
    NSMutableString *messageBody = [NSMutableString stringWithFormat:@"<html><body><h1>US Mission Poland</h1><p>Download file %@/%@</p><a href=\"91.121.155.99/files/get_en_file/%d\">English version</a><br/><a href=\"91.121.155.99/files/get_pl_file/%d\">Polish version</a></body></html>", pdfInfo.nameEn, pdfInfo.namePl, pdfInfo.id.intValue, pdfInfo.id.intValue];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [mc setMailComposeDelegate:self];
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    
    self.didRotateWhilePresentingVideo = NO;
    self.orientationBeforePresentingViewController = self.interfaceOrientation;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateWithPresentedViewControllerVisible:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    if (index == updateButtonIndex)
    {
        NSIndexPath *triggeredCellIndexPath = [self.tableView indexPathForCell:cell];
        PdfInfo *triggeredPdfInfo = self.pdfInfoArray[triggeredCellIndexPath.row];
        if ([triggeredPdfInfo isUpdateAvailable])
        {
            [[AGIPDFContext defaultContext] downloadPdf:triggeredPdfInfo];
        }
        else if (triggeredPdfInfo.fileVersion)
        {
            NSString *msgEn = @"File is up to date.";
            NSString *msgPl = @"Aktualnie masz najnowszą wersję pliku.";
            
            UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? msgPl : msgEn
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [notificationAlert show];
        }
        else
        {
            NSString *msgEn = @"You can't update file which wasn't downloaded.";
            NSString *msgPl = @"Najpierw musisz ściągnąć plik.";
            
            UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? msgPl : msgEn
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [notificationAlert show];
        }
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if (index == deleteButtonIndex)
    {
        NSIndexPath *triggeredCellIndexPath = [self.tableView indexPathForCell:cell];
        PdfInfo *triggeredPdfInfo = self.pdfInfoArray[triggeredCellIndexPath.row];
        if (triggeredPdfInfo.fileVersion && !triggeredPdfInfo.downloadInProgress)
        {
            [[AGIPDFContext defaultContext] removePdf:triggeredPdfInfo];
            [self.tableView reloadRowsAtIndexPaths:@[triggeredCellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else
        {
            NSString *msgEn = @"File isn't downloaded.";
            NSString *msgPl = @"Plik nie jest zapisany na telefonie.";
            
            UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? msgPl : msgEn
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [notificationAlert show];
        }
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}


- (void)didRotateWithPresentedViewControllerVisible:(NSNotification*)notification {
    self.didRotateWhilePresentingVideo = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.didRotateWhilePresentingVideo) {
        self.didRotateWhilePresentingVideo = NO;
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        
        UIViewController *mVC = [[UIViewController alloc] init];
        [self presentViewController:mVC animated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.didRotateWhilePresentingVideo && UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.didRotateWhilePresentingVideo = NO;
        [self updateViewConstraints];
        [self.view setNeedsUpdateConstraints];
    }
}


@end
