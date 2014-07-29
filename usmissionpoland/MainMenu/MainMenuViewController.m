//
//  MainMenuViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/25/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AppDelegate.h"
#import "DetailMenuViewController.h"
#import "MainPageCell.h"
#import "ContentPageViewController.h"
#import "FaqViewController.h"
#import "VideoViewController.h"
#import "AGIPDFTableViewController.h"
#import "NewsTableViewController.h"
#import "HomePageViewController.h"
#import "PassportStatusViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.isSectionOpenArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], /*[NSNumber numberWithBool:NO],*/ nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeLanguage:) name:POST_NOTIFICATION_SWITCH_LANGUAGE object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPages) name:POST_NOTIFICATION_DID_END_DATABASE_UPDATE object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = CustomUSAppBlueColor;
    
    [self loadPages];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 28, self.view.frame.size.width - 10, self.view.frame.size.height - 28 - 54) style:UITableViewStylePlain];
    tableView.backgroundColor = CustomUSAppBlueColor;
    tableView.separatorColor = CustomUSAppLightBlueColor;
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // added to remove extra rows at the end
    
    UIView *languageBar = [[UIView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 54, self.view.frame.size.width - 10, 54)];
    languageBar.backgroundColor = [UIColor colorWithRed:0.16f green:0.26f blue:0.44f alpha:1];
    languageBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:languageBar];
    self.languageBar = languageBar;
    
    [self initLanguageEnglishButton];
    [self initLanguagePolishButton];
    
    UIView *languageButtonsSeparator = [[UIView alloc] init];
    languageButtonsSeparator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2f];
    [languageBar addSubview:languageButtonsSeparator];
    self.languageButtonsSeparator = languageButtonsSeparator;
    
    BilingualLabel *languageLabel = [[BilingualLabel alloc] initWithTextEnglish:@"Language" polish:@"Język"];
    languageLabel.frame = CGRectMake(10, 0, languageBar.frame.size.width - 20 - self.languageEnglishButton.frame.origin.x, languageBar.frame.size.height);
    languageLabel.textColor = [UIColor whiteColor];
    languageLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:16];
    [languageBar addSubview:languageLabel];
}

- (void)loadPages {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    NSFetchRequest *generalInfoFetchRequest = [[NSFetchRequest alloc] init];
    generalInfoFetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
    generalInfoFetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %d", 1];
    self.generalInfoPages = [managedObjectContext executeFetchRequest:generalInfoFetchRequest error:nil];
    
    self.generalInfoPages = [self.generalInfoPages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(Page*)a index];
        NSNumber *second = [(Page*)b index];
        return [first compare:second];
    }];
    
    
    NSFetchRequest *visasFetchRequest = [[NSFetchRequest alloc] init];
    visasFetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
    visasFetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %d", 2];
    
    self.visasPages = [managedObjectContext executeFetchRequest:visasFetchRequest error:nil];
    self.visasPages = [self.visasPages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(Page*)a index];
        NSNumber *second = [(Page*)b index];
        return [first compare:second];
    }];
    
    
    NSFetchRequest *acsFetchRequest = [[NSFetchRequest alloc] init];
    acsFetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
    acsFetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %d", 3];
    
    self.acsPages = [managedObjectContext executeFetchRequest:acsFetchRequest error:nil];
    self.acsPages = [self.acsPages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(Page*)a index];
        NSNumber *second = [(Page*)b index];
        return [first compare:second];
    }];
    
    
    NSFetchRequest *newsFetchRequest = [[NSFetchRequest alloc] init];
    newsFetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
    newsFetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %d", 4];
    
    self.newsPages = [managedObjectContext executeFetchRequest:newsFetchRequest error:nil];
    self.newsPages = [self.newsPages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(Page*)a index];
        NSNumber *second = [(Page*)b index];
        return [first compare:second];
    }];
    
    /*
    NSFetchRequest *visaStatusFetchRequest = [[NSFetchRequest alloc] init];
    visaStatusFetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
    visaStatusFetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %d", 5];
    
    self.visaStatusPages = [managedObjectContext executeFetchRequest:visaStatusFetchRequest error:nil];
    self.visaStatusPages = [self.visaStatusPages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(Page*)a index];
        NSNumber *second = [(Page*)b index];
        return [first compare:second];
    }];
    */
    
    NSArray *passportEmptyArray = [NSArray array];
    
    NSArray *homeEmptyArray = [NSArray array];
    
    self.allPages = [NSArray arrayWithObjects:homeEmptyArray, self.generalInfoPages, self.visasPages, self.acsPages, self.newsPages, passportEmptyArray, /*self.visaStatusPages,*/ nil];
    
    [self.tableView reloadData];
}

- (UIView *)view {
    return [super view];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tableView.frame = CGRectMake(10, 28, self.view.frame.size.width - 10, self.view.frame.size.height - 28 - 54);
    for (MainPageCell *cell in self.tableView.visibleCells) {
        cell.contentWidth = self.view.frame.size.width - self.tableView.frame.origin.x - self.slidingViewController.anchorRightPeekAmount;
    }
    NSRange indexesRange;
    indexesRange.location = 0;
    indexesRange.length = self.tableView.numberOfSections;
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndexesInRange:indexesRange]  withRowAnimation:UITableViewRowAnimationNone];
    
    CGFloat rightEnd = self.view.frame.size.width - self.slidingViewController.anchorRightPeekAmount;
    self.languageEnglishButton.frame = CGRectMake(rightEnd - 120, 0, 40, self.languageBar.frame.size.height);
    self.languagePolishButton.frame = CGRectMake(rightEnd - 60, 0, 40, self.languageBar.frame.size.height);
    self.languageButtonsSeparator.frame = CGRectMake((self.languageEnglishButton.frame.origin.x + self.languageEnglishButton.frame.size.width + self.languagePolishButton.frame.origin.x)/2, 0, 1, self.languageBar.frame.size.height);
}

- (void)initLanguageEnglishButton {
    UIButton *languageEnglishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [languageEnglishButton setTitle:@"EN" forState:UIControlStateNormal];
    [languageEnglishButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.3f] forState:UIControlStateNormal];
    [languageEnglishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    languageEnglishButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    languageEnglishButton.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:16];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish) {
        languageEnglishButton.selected = YES;
    }
    else {
        languageEnglishButton.layer.borderColor = CustomUSAppLightBlueColor.CGColor;
    }
    [languageEnglishButton addTarget:self action:@selector(didTapLanguageEnglishButton) forControlEvents:UIControlEventTouchUpInside];
    [self.languageBar addSubview:languageEnglishButton];
    _languageEnglishButton = languageEnglishButton;
}

- (void)initLanguagePolishButton {
    UIButton *languagePolishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [languagePolishButton setTitle:@"PL" forState:UIControlStateNormal];
    [languagePolishButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.3f] forState:UIControlStateNormal];
    [languagePolishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    languagePolishButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    languagePolishButton.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:16];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        languagePolishButton.selected = YES;
    }
    else {
        languagePolishButton.layer.borderColor = CustomUSAppLightBlueColor.CGColor;
    }
    [languagePolishButton addTarget:self action:@selector(didTapLanguagePolishButton) forControlEvents:UIControlEventTouchUpInside];
    [self.languageBar addSubview:languagePolishButton];
    _languagePolishButton = languagePolishButton;
}

- (void)didTapLanguageEnglishButton {
    if (!self.languageEnglishButton.selected) {
        [[LanguageSettings sharedSettings] setLanguage:LanguageEnglish];
    }
}

- (void)didTapLanguagePolishButton {
    if (!self.languagePolishButton.selected) {
        [[LanguageSettings sharedSettings] setLanguage:LanguagePolish];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allPages.count;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderTappableView *headerView = [[HeaderTappableView alloc] initWithFrame:CGRectMake(0, 0, 1000, 100)];
    headerView.section = section;
    headerView.delegate = self;
    headerView.opaque = YES;
    headerView.backgroundColor = CustomUSAppLightBlueColor;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width - 20 - self.slidingViewController.anchorRightPeekAmount, headerView.frame.size.height)];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.opaque = YES;
    headerLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:16];
    headerLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:headerLabel];
    
    UIView *headerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - 1, headerView.frame.size.width, 1)];
    headerSeparator.backgroundColor = CustomUSAppBlueColor;
    headerSeparator.opaque = YES;
    headerSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [headerView addSubview:headerSeparator];
    
    
    return headerView;
}

- (void)didTapHeaderInSection:(NSInteger)section {
    if (section == 0) {
        [self didTapHomeButton];
        return;
    }
    else if (section == 5) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            id<EmbeddingViewController> homeVc = ((UINavigationController*)self.slidingViewController.topViewController).viewControllers.firstObject;
            [homeVc removeAllEmbeddedViewControllers];
            [homeVc openPassportPage:nil];
            [self.slidingViewController resetTopView];
        }
        else {
            [self openPassportPage:nil];
        }
        return;
    }
    NSMutableArray *openedHigherRows = [NSMutableArray array], *openedLowerRows = [NSMutableArray array];
    NSMutableArray *sectionsToClose = [NSMutableArray array]; //useful if there will be a change that we will allow more than one section to be open at once - in current concept, it's just one
    NSMutableArray *rowsToOpen = [NSMutableArray array];
    BOOL isTappedSectionOpen = NO;
    for (int i = 0; i < self.isSectionOpenArray.count; ++i) {
        if ([[self.isSectionOpenArray objectAtIndex:i] boolValue]) {
            if (i == section) {
                isTappedSectionOpen = YES;
            }
            [sectionsToClose addObject:[NSNumber numberWithInt:i]];
            NSArray *openedArray = [self.allPages objectAtIndex:i];
            if (i <= section) {
                for (int j = 0; j < openedArray.count; ++j) {
                    [openedHigherRows addObject:[NSIndexPath indexPathForRow:j inSection:i]];
                }
            }
            else {
                for (int j = 0; j < openedArray.count; ++j) {
                    [openedLowerRows addObject:[NSIndexPath indexPathForRow:j inSection:i]];
                }
            }
        }
    }
    
    if (!isTappedSectionOpen) {
        NSArray *arrayToOpen = [self.allPages objectAtIndex:section];
        for (int i = 0; i < arrayToOpen.count; ++i) {
            [rowsToOpen addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
    }
    
    
    [self.tableView beginUpdates];
    
    for (NSNumber *sectionToCloseNumber in sectionsToClose) {
        NSUInteger sectionToClose = [sectionToCloseNumber unsignedIntegerValue];
        [self.isSectionOpenArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:sectionToClose];
    }
    if (!isTappedSectionOpen) {
        [self.isSectionOpenArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:section];
        
        [self.tableView deleteRowsAtIndexPaths:openedHigherRows withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView insertRowsAtIndexPaths:rowsToOpen withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView deleteRowsAtIndexPaths:openedLowerRows withRowAnimation:UITableViewRowAnimationBottom];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:openedHigherRows withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView insertRowsAtIndexPaths:rowsToOpen withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView deleteRowsAtIndexPaths:openedLowerRows withRowAnimation:UITableViewRowAnimationTop];
    }
    
    
    [self.tableView endUpdates];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        switch (section) {
            case 0:
                return @"Ekran Główny";
                break;
            case 1:
                return @"Informacje Ogólne";
                break;
            case 2:
                return @"Wizy";
                break;
            case 3:
                return @"Usługi dla Obywateli USA";
                break;
            case 4:
                return @"Wiadomości";
                break;
            case 5:
                return @"Status paszportu";
                break;
            case 6:
                return @"Status Podania o Wizę";
                break;
                
            default:
                return nil;
                break;
        }
    }
    else {
        switch (section) {
            case 0:
                return @"Home";
                break;
            case 1:
                return @"General Information";
                break;
            case 2:
                return @"Visas";
                break;
            case 3:
                return @"American Citizens Services";
                break;
            case 4:
                return @"News";
                break;
            case 5:
                return @"Passport Tracker";
                break;
            case 6:
                return @"Visa Application Status";
                break;
                
            default:
                return nil;
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ceilf( [[self tableView:self.tableView titleForHeaderInSection:section] sizeWithFont:[UIFont fontWithName:DEFAULT_FONT_BOLD size:16] constrainedToSize:CGSizeMake(self.view.frame.size.width - self.slidingViewController.anchorRightPeekAmount - self.tableView.frame.origin.x - 20, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height ) + 42;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ceilf( [[((Page*)[[self.allPages objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]) localizedTitle] sizeWithFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:16] constrainedToSize:CGSizeMake(self.view.frame.size.width - self.slidingViewController.anchorRightPeekAmount - self.tableView.frame.origin.x - 34, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height ) + 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.isSectionOpenArray objectAtIndex:section] boolValue]) {
        return [[self.allPages objectAtIndex:section] count];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainPageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pageCell"];
    if (cell == nil) {
        cell = [[MainPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pageCell"];
        cell.backgroundColor = CustomUSAppBlueColor;
        cell.opaque = YES;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:16];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    }
    cell.contentWidth = self.view.frame.size.width - self.tableView.frame.origin.x - self.slidingViewController.anchorRightPeekAmount;
    Page *cellPage = [[self.allPages objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [cellPage localizedTitle];
    
    if ([cellPage.type isEqualToString:@"stps"] || [cellPage.type isEqualToString:@"menu"]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_more24x24.png"]];
        cell.accessoryView.frame = CGRectMake(0, 0, 12, 12);
    }
    else {
        cell.accessoryView = nil;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Page *pageToOpen = [[self.allPages objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    BaseViewController *topVc = ((UINavigationController*)self.slidingViewController.topViewController).viewControllers.firstObject;
    if ([topVc isKindOfClass:[HomePageViewController class]] && ((UINavigationController*)self.slidingViewController.topViewController).viewControllers.count > 1) {
        topVc = ((UINavigationController*)self.slidingViewController.topViewController).viewControllers.lastObject;
    }
    if ([topVc isKindOfClass:[BaseViewController class]] && [topVc page].pageId.intValue == pageToOpen.pageId.intValue && !([topVc isKindOfClass:[DetailMenuViewController class]] && ((DetailMenuViewController*)topVc).tableViewsStack.count > 1)) {
        [self.slidingViewController resetTopView];
    }
    else {
        [self openPage:pageToOpen];
    }
}

- (void)didChangeLanguage:(NSNotification*)notification {
    [self.tableView reloadData];
    
    
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        self.languageEnglishButton.selected = NO;
        self.languagePolishButton.selected = YES;
    }
    else {
        self.languageEnglishButton.selected = YES;
        self.languagePolishButton.selected = NO;
    }
}

- (void)didTapHomeButton {
    if ([[((UINavigationController*)self.slidingViewController.topViewController) viewControllers].firstObject isKindOfClass:[HomePageViewController class]] && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.slidingViewController resetTopView];
        HomePageViewController *homeVc = [((UINavigationController*)self.slidingViewController.topViewController) viewControllers].firstObject;
        [homeVc removeAllEmbeddedViewControllers];
    }
    else {
        if ([((UINavigationController*)self.slidingViewController.topViewController) viewControllers].count == 1) {
            [self.slidingViewController resetTopView];
        }
        else {
            [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
                [((UINavigationController*)self.slidingViewController.topViewController) popToRootViewControllerAnimated:NO];
                [self.slidingViewController resetTopView];
            }];
        }
    }
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate checkForUpdate];
}

- (void)openPage:(Page*)pageToOpen {
    if ([pageToOpen.type isEqualToString:@"face"]) {
        NSURL *fbUrl = [NSURL URLWithString:@"https://pl-pl.facebook.com/USEmbassyWarsaw"];
        if ([[UIApplication sharedApplication] canOpenURL:fbUrl]) {
            [[UIApplication sharedApplication] openURL:fbUrl];
        }
    }
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            id<EmbeddingViewController> homeVc = ((UINavigationController*)self.slidingViewController.topViewController).viewControllers.firstObject;
            if (![homeVc conformsToProtocol:@protocol(EmbeddingViewController)]) {
                return;
            }
            [homeVc removeAllEmbeddedViewControllers];
            if ([pageToOpen.type isEqualToString:@"menu"] || [pageToOpen.type isEqualToString:@"stps"]) {
                [homeVc openMenuPage:pageToOpen];
            }
            else {
                [homeVc openPage:pageToOpen];
            }
            
            [self.slidingViewController resetTopView];
        }
        else {
            [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
                if ([pageToOpen.type isEqualToString:@"stps"] || [pageToOpen.type isEqualToString:@"menu"]) {
                    [self openMenuPage:pageToOpen];
                }
                else if ([pageToOpen.type isEqualToString:@"text"] || [pageToOpen.type isEqualToString:@"cont"] || [pageToOpen.type isEqualToString:@"list"]) {
                    [self openContentPage:pageToOpen];
                }
                else if ([pageToOpen.type isEqualToString:@"file"]) {
                    [self openFileManager:pageToOpen];
                }
                else if ([pageToOpen.type isEqualToString:@"head"]) {
                    [self openNewsPage:pageToOpen];
                }
                else if ([pageToOpen.type isEqualToString:@"faqs"]) {
                    [self openFaqWithPage:pageToOpen];
                }
                else if ([pageToOpen.type isEqualToString:@"vids"]) {
                    [self openVideosPage:pageToOpen];
                }
                else if ([pageToOpen.type isEqualToString:@"pasp"]) {
                    [self openPassportPage:pageToOpen];
                }
                [self.slidingViewController resetTopView];
            }];
        }
        
    }
}

- (void)openPassportPage:(Page*)page {
    PassportStatusViewController *passportStatusVc = [[PassportStatusViewController alloc] init];
    passportStatusVc.page = page;
    [((UINavigationController*)self.slidingViewController.topViewController) popToRootViewControllerAnimated:NO];
    [((UINavigationController*)self.slidingViewController.topViewController) pushViewController:passportStatusVc animated:NO];
    
    [self.slidingViewController resetTopView];
}

- (void)openMenuPage:(Page*)page {
    DetailMenuViewController *detailMenuVc = [[DetailMenuViewController alloc] initWithPage:page];
    [((UINavigationController*)self.slidingViewController.topViewController) popToRootViewControllerAnimated:NO];
    [((UINavigationController*)self.slidingViewController.topViewController) pushViewController:detailMenuVc animated:NO];
}

- (void)openContentPage:(Page*)page {
    ContentPageViewController *contentVc = [[ContentPageViewController alloc] init];
    contentVc.page = page;
    [((UINavigationController*)self.slidingViewController.topViewController) popToRootViewControllerAnimated:NO];
    [((UINavigationController*)self.slidingViewController.topViewController) pushViewController:contentVc animated:NO];
    
}

- (void)openNewsPage:(Page*)page {
    NewsTableViewController *newsController = [[NewsTableViewController alloc] init];
    newsController.page = page;
    [((UINavigationController*)self.slidingViewController.topViewController) popToRootViewControllerAnimated:NO];
    [((UINavigationController*)self.slidingViewController.topViewController) pushViewController:newsController animated:NO];
}

- (void)openFaqWithPage:(Page*)page {
    FaqViewController *faqViewController = [[FaqViewController alloc] init];
    faqViewController.page = page;
    [((UINavigationController*)self.slidingViewController.topViewController) popToRootViewControllerAnimated:NO];
    [((UINavigationController*)self.slidingViewController.topViewController) pushViewController:faqViewController animated:NO];
    
}

- (void)openVideosPage:(Page*)page {
    VideoViewController *videoViewController = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
    videoViewController.page = page;
    [((UINavigationController*)self.slidingViewController.topViewController) popToRootViewControllerAnimated:NO];
    [((UINavigationController*)self.slidingViewController.topViewController) pushViewController:videoViewController animated:NO];
}

- (void)openFileManager:(Page*)page
{
    AGIPDFTableViewController *pdfController = [[AGIPDFTableViewController alloc] initWithNibName:@"AGIPDFTableViewController" bundle:nil];
    pdfController.page = page;
    [((UINavigationController*)self.slidingViewController.topViewController) popToRootViewControllerAnimated:NO];
    [((UINavigationController*)self.slidingViewController.topViewController) pushViewController:pdfController animated:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:duration + 0.1f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
