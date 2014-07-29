//
//  DetailMenuViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/26/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "DetailMenuViewController.h"
#import "AppDelegate.h"
#import "MainPageCell.h"
#import "ContentPageViewController.h"
#import "FaqViewController.h"
#import "VideoViewController.h"
#import "AGIPDFTableViewController.h"
#import "NewsTableViewController.h"
#import "CustomNavigationController.h"
#import "DetailPageCell.h"
#import "PassportStatusViewController.h"

@interface DetailMenuViewController ()

@end

@implementation DetailMenuViewController

- (id)initWithPage:(Page *)page
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.page = page;
        self.menuPagesArray = [NSMutableArray arrayWithObject:page];
        self.menuItemsPagesArrays = [NSMutableArray arrayWithObject:[self.page childrenPagesArray]];
        self.tableViewsStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = CustomUSAppBlueColor;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame)) style:UITableViewStylePlain];
    tableView.backgroundColor = CustomUSAppBlueColor;
    tableView.separatorColor = CustomUSAppLightBlueColor;
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    [self.view addSubview:tableView];
    [self.tableViewsStack removeAllObjects];
    [self.tableViewsStack addObject:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    for (int i = 1; i < self.menuPagesArray.count; ++i) {
        
        UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame)) style:UITableViewStylePlain];
        newTableView.backgroundColor = CustomUSAppBlueColor;
        newTableView.separatorColor = CustomUSAppLightBlueColor;
        if ([newTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            newTableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
        }
        [self.view addSubview:newTableView];
        [self.tableViewsStack addObject:newTableView];
        newTableView.delegate = self;
        newTableView.dataSource = self;
    }
    
}

- (void)makeNavigationBar {
    [super makeNavigationBar];
    if ([self.navBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navBar.barTintColor = CustomUSAppLightBlueColor;
        self.navBar.tintColor = [UIColor whiteColor];
    }
    else {
        self.navBar.tintColor = CustomUSAppLightBlueColor;
    }
    self.navBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor], UITextAttributeFont : [UIFont fontWithName:DEFAULT_FONT_BOLD size:16]};
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger tableIndex = [self.tableViewsStack indexOfObject:tableView];
    if (tableIndex == NSNotFound) {
        return 0;
    }
    return ceilf( [[((Page*)[[self.menuItemsPagesArrays objectAtIndex:tableIndex] objectAtIndex:indexPath.row]) localizedTitle] sizeWithFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:16] constrainedToSize:CGSizeMake(self.view.frame.size.width - 50, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height ) + 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger tableIndex = [self.tableViewsStack indexOfObject:tableView];
    return [[self.menuItemsPagesArrays objectAtIndex:tableIndex] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pageCell"];
    if (cell == nil) {
        cell = [[DetailPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pageCell"];
        cell.backgroundColor = CustomUSAppBlueColor;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:16];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    }
    
    NSInteger tableIndex = [self.tableViewsStack indexOfObject:tableView];
    Page *cellPage = [[self.menuItemsPagesArrays objectAtIndex:tableIndex] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [cellPage localizedTitle];
    
    if ([cellPage.type isEqualToString:@"menu"] || ([cellPage.type isEqualToString:@"stps"] && [cellPage.pageId intValue] != [((Page*)[self.menuPagesArray objectAtIndex:tableIndex]).pageId intValue])) {
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
    
    NSInteger tableIndex = [self.tableViewsStack indexOfObject:tableView];
    Page *pageToOpen = [[self.menuItemsPagesArrays objectAtIndex:tableIndex] objectAtIndex:indexPath.row];
    if ([pageToOpen.type isEqualToString:@"menu"] || ([pageToOpen.type isEqualToString:@"stps"] && [pageToOpen.pageId intValue] != [((Page*)[self.menuPagesArray objectAtIndex:tableIndex]).pageId intValue])) {
        [self.menuPagesArray addObject:pageToOpen];
        
        [self.menuItemsPagesArrays addObject:[pageToOpen childrenPagesArray]];
        
        
        UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame)) style:UITableViewStylePlain];
        newTableView.backgroundColor = CustomUSAppBlueColor;
        newTableView.separatorColor = CustomUSAppLightBlueColor;
        if ([newTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            newTableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
        }
        [self.view addSubview:newTableView];
        [self.tableViewsStack addObject:newTableView];
        newTableView.delegate = self;
        newTableView.dataSource = self;
        
        
        UINavigationItem *newNavigationItem = [[UINavigationItem alloc] initWithTitle:[[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? pageToOpen.titlePL : pageToOpen.titleEN];
        newNavigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navBar pushNavigationItem:newNavigationItem animated:YES];
        
    }
    else {
        [self openPage:pageToOpen];
    }
    
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    UITableView *topTableView = self.tableViewsStack.lastObject;
    UITableView *prevTableView;
    if (self.tableViewsStack.count > 1) {
        prevTableView = [self.tableViewsStack objectAtIndex:self.tableViewsStack.count - 2];
    }
    
    topTableView.frame = CGRectMake(self.view.frame.size.width, topTableView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame));
    [UIView animateWithDuration:0.3f animations:^{
        topTableView.frame = CGRectMake(0, topTableView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame));
        prevTableView.frame = CGRectMake(-self.view.frame.size.width/4, prevTableView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame));
    }completion:^(BOOL finished) {
        
    }];
    
    
    return YES;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (navigationBar.items.count <= 2) {
        return [super navigationBar:navigationBar shouldPopItem:item];
    }
    [self.menuPagesArray removeLastObject];
    [self.menuItemsPagesArrays removeLastObject];
    UITableView *topTableView = self.tableViewsStack.lastObject;
    [self.tableViewsStack removeLastObject];
    UITableView *prevTableView = self.tableViewsStack.lastObject;
    
    [UIView animateWithDuration:0.3f animations:^{
        topTableView.frame = CGRectMake(self.view.frame.size.width, topTableView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame));
        prevTableView.frame = CGRectMake(0, prevTableView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame));
    }completion:^(BOOL finished) {
        [topTableView removeFromSuperview];
    }];
    
    
    return YES;
}

- (void)openPage:(Page*)pageToOpen {
    if ([pageToOpen.type isEqualToString:@"face"]) {
        NSURL *fbUrl = [NSURL URLWithString:@"https://pl-pl.facebook.com/USEmbassyWarsaw"];
        if ([[UIApplication sharedApplication] canOpenURL:fbUrl]) {
            [[UIApplication sharedApplication] openURL:fbUrl];
        }
    }
    else {
        if ([pageToOpen.type isEqualToString:@"text"] || [pageToOpen.type isEqualToString:@"cont"] || [pageToOpen.type isEqualToString:@"list"] || [pageToOpen.type isEqualToString:@"stps"]) {
            [self openContentPage:pageToOpen];
        }
        else if ([pageToOpen.type isEqualToString:@"file"]) {
            [self openFileManager];
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
        
    }
}

- (void)openPassportPage:(Page*)page {
    PassportStatusViewController *passportStatusVc = [[PassportStatusViewController alloc] init];
    passportStatusVc.page = page;
    passportStatusVc.isStep = [((Page*)self.menuPagesArray.lastObject).type isEqualToString:@"stps"];
    [self.navigationController pushViewController:passportStatusVc animated:YES];
}

- (void)openContentPage:(Page*)page {
    ContentPageViewController *contentVc = [[ContentPageViewController alloc] init];
    contentVc.page = page;
    contentVc.isStep = [((Page*)self.menuPagesArray.lastObject).type isEqualToString:@"stps"];
    [self.navigationController pushViewController:contentVc animated:YES];
    
}

- (void)openNewsPage:(Page*)page {
    NewsTableViewController *newsController = [[NewsTableViewController alloc] init];
    newsController.page = page;
    [self.navigationController pushViewController:newsController animated:YES];
}

- (void)openFaqWithPage:(Page*)page {
    FaqViewController *faqViewController = [[FaqViewController alloc] init];
    faqViewController.page = page;
    faqViewController.isStep = [((Page*)self.menuPagesArray.lastObject).type isEqualToString:@"stps"];
    [self.navigationController pushViewController:faqViewController animated:YES];
    
}

- (void)openVideosPage:(Page*)page {
    VideoViewController *videoViewController = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
    videoViewController.page = page;
    [self.navigationController pushViewController:videoViewController animated:YES];
}


- (void)openFileManager
{
    AGIPDFTableViewController *pdfController = [[AGIPDFTableViewController alloc] initWithNibName:@"AGIPDFTableViewController" bundle:nil];
    
    [self.navigationController pushViewController:pdfController animated:YES];
}

- (void)didChangeLanguage:(NSNotification *)notification {
    [super didChangeLanguage:notification];
    
    for (NSUInteger i = 0; i < self.tableViewsStack.count; ++i) {
        UITableView *tableView = [self.tableViewsStack objectAtIndex:i];
        [tableView reloadData];
    }
    
    for (NSUInteger i = 1; i < self.navBar.items.count; ++i) {
        UINavigationItem *navItem = [self.navBar.items objectAtIndex:i];
        Page *page = [self.menuPagesArray objectAtIndex:i-1];
        navItem.title = [page localizedTitle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
