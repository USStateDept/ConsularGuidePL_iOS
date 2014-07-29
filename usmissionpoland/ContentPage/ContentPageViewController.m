//
//  ContentPageViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/2/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageViewController.h"

#import "ContentPageLabelHeader1.h"
#import "ContentPageLabelHeader2.h"
#import "ContentPageLabelParagraph.h"
#import "ContentPageImageView.h"
#import "ContentPageOrderedListView.h"
#import "ContentPageOrderedListItemView.h"
#import "ContentPageUnorderedListView.h"
#import "ContentPageUnorderedListItemView.h"
#import "ContentPagePhoneView.h"
#import "ContentPageHoursView.h"
#import "ContentPageCategoriesView.h"
#import "ContentPageCategoryItemView.h"
#import "ContentPageCategoryItemNameLabel.h"
#import "ContentPageCategoryItemTextLabel.h"
#import "ContentPageMailView.h"
#import "ContentPageMapView.h"
#import "ContentPageInfoView.h"
#import "ContentPageInfoDetailView.h"
#import "ContentPageInfoContentView.h"
#import "ContentPageInfoDetailContentView.h"
#import "ContentPageListButton.h"
#import "ContentPageTightLabelsContainerView.h"

#import "AppDelegate.h"
#import "AGIPDFTableViewController.h"
#import "FaqViewController.h"
#import "NewsTableViewController.h"

#import "AdditionalContentViewController.h"

@interface ContentPageViewController ()
/** Used to keep the value of string currently being parsed */
@property (nonatomic, retain) NSMutableAttributedString *currentString;
/** Used to determine whether the text that parser finds next should be written in bold font or not (set to bold when <strong> token is encountered) */
@property (nonatomic, assign) TextParsingState textParsingState;
/** Keeps views that were not yet added to the view hierarchy, because parsing of their content hasn't finished yet */
@property (nonatomic, retain) NSMutableArray *viewStack;
/** When creating ordered list, the number at the next list item is determined by this property */
@property (nonatomic, assign) NSInteger lastListItemIndex;
/** Needed to determine the top margin of a view we're trying to add as a subview */
@property (nonatomic, retain) UIView *lastAddedView;

/** If a button is between two lists, we're making an impression that it is part of a list item, hence we need to keep pointer to that button here to reposition/resize it once we make sure that it is between two lists */
@property (nonatomic, weak) ContentPageButtonView *buttonIfWasLast;
@property (nonatomic, assign) BOOL wasListLast;

@end

@implementation ContentPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewStack = [[NSMutableArray alloc] init];
        self.lastListItemIndex = 0;
        self.buttonDelegate = self;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareLayoutFromXml) name:POST_NOTIFICATION_SWITCH_LANGUAGE object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.masksToBounds = YES;
    
    [self makeStepBarIfNeeded];
    
    [self prepareLayoutFromXml];
}

- (CGPoint)scrollViewOrigin {
    return CGPointMake([AppDelegate marginSpace], 0);
}

- (NSString*)contentString {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        return self.page.contentPL;
    }
    else {
        return self.page.contentEN;
    }
}

/** The page is saved in database as XML string. Here we prepare for and then start the parsing of that XML to create the layout of this page */
- (void)prepareLayoutFromXml {
    for (UIView *subview in self.view.subviews) {
        if (subview != self.navBar && subview != self.stepPageControl && (![self isKindOfClass:[AdditionalContentViewController class]] || subview != ((AdditionalContentViewController*)self).separatorLine)) {
            [subview removeFromSuperview];
        }
    }
    self.lastAddedView = nil;
    
    NSString *contentString = [self contentString];
    
    CGPoint scrollViewOrigin = [self scrollViewOrigin];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollViewOrigin.x, scrollViewOrigin.y + self.navBar.frame.size.height, self.view.bounds.size.width - 2 * scrollViewOrigin.x, self.view.bounds.size.height - self.navBar.frame.size.height - self.stepPageControl.frame.size.height - 2*scrollViewOrigin.y)];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 0);
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, scrollView.frame.size.width + scrollView.frame.origin.x - self.view.frame.size.width);
    [self.view addSubview:scrollView];
    [self.view bringSubviewToFront:self.navBar];
    self.scrollView = scrollView;
    
    [self.view bringSubviewToFront:self.stepPageControl];
    
    [self.viewStack addObject:scrollView];
    
    if ([self.page.type isEqualToString:@"cont"]) {
        scrollView.layer.masksToBounds = NO;
        ContentPageMapView *mapView = [[ContentPageMapView alloc] initWithFrame:CGRectMake(-self.scrollView.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height *0.4f) latitude:self.page.latitude longitude:self.page.longitude zoom:self.page.mapZoom locationName:[self.page localizedTitle]];
        
        [self enlargeView:self.scrollView byAddingSubview:mapView];
        
        mapView.frame = CGRectMake(mapView.frame.origin.x, -self.scrollView.frame.origin.y - self.scrollView.contentInset.top + self.navBar.frame.size.height, mapView.frame.size.width, mapView.frame.size.height); //setting origin.y gets cancelled by enlargeView:byAddingSubview:(...), so we have to set it here again
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + mapView.frame.origin.y + 5);
        
    }
    
    NSXMLParser *contentParser = [[NSXMLParser alloc] initWithData:[contentString dataUsingEncoding:NSUTF8StringEncoding]];
    contentParser.delegate = self;
    
    [contentParser parse];
}

/** This method creates a new view appropriate to the token that the parser encountered */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //calculate initial frame for the new view
    CGRect initialFrame;
    UIView *lastView = [self.viewStack lastObject];
    if ([lastView class] == [UIScrollView class]) {
        UIScrollView *scrollView = (UIScrollView*)lastView;
        initialFrame = CGRectMake(0, 0, scrollView.contentSize.width, 0);
    }
    else if ([lastView respondsToSelector:@selector(leftSubviewOffset)]){
        ContentPageViewBase *view = (ContentPageViewBase*)lastView;
        initialFrame = CGRectMake(view.leftSubviewOffset, 0, view.frame.size.width - view.leftSubviewOffset, 0);
    }
    else { //this will get called only if we have some object inside paragraph <p>; therefore if data is valid, should never be called
        initialFrame = CGRectMake(0, 0, lastView.frame.size.width, 0);
    }
    
    if ([elementName isEqualToString:@"content"]) {
        return;
    }
    else if ([elementName isEqualToString:@"p"]) {
        ContentPageLabelParagraph *paragraphLabel = [[ContentPageLabelParagraph alloc] initWithFrame:initialFrame];
        [self.viewStack addObject:paragraphLabel];
        self.currentString = [[NSMutableAttributedString alloc] init];
        self.textParsingState = TextParsingStateNormal;
    }
    else if ([elementName isEqualToString:@"h1"]) {
        ContentPageLabelHeader1 *h1Label = [[ContentPageLabelHeader1 alloc] initWithFrame:initialFrame];
        [self.viewStack addObject:h1Label];
        self.currentString = [[NSMutableAttributedString alloc] init];
        self.textParsingState = TextParsingStateStrong;
    }
    else if ([elementName isEqualToString:@"h2"]) {
        ContentPageLabelHeader2 *h2Label = [[ContentPageLabelHeader2 alloc] initWithFrame:initialFrame];
        [self.viewStack addObject:h2Label];
        self.currentString = [[NSMutableAttributedString alloc] init];
        self.textParsingState = TextParsingStateStrong;
    }
    else if ([elementName isEqualToString:@"strong"]) {
        self.textParsingState = TextParsingStateStrong;
        return;
    }
    else if ([elementName isEqualToString:@"img"]) {
        ContentPageImageView *imageView = [[ContentPageImageView alloc] initWithFrame:initialFrame imageUrlString:[attributeDict objectForKey:@"src"]];
        [self.viewStack addObject:imageView];
    }
    else if ([elementName isEqualToString:@"ul"]) {
        ContentPageUnorderedListView *ulView = [[ContentPageUnorderedListView alloc] initWithFrame:initialFrame];
        [self.viewStack addObject:ulView];
    }
    else if ([elementName isEqualToString:@"ol"]) {
        ContentPageOrderedListView *olView = [[ContentPageOrderedListView alloc] initWithFrame:initialFrame];
        [self.viewStack addObject:olView];
    }
    else if ([elementName isEqualToString:@"li"]) {
        id listView = [self.viewStack lastObject];
        if ([listView class] == [ContentPageOrderedListView class]) {
            self.lastListItemIndex += 1;
            ContentPageOrderedListItemView *liView = [[ContentPageOrderedListItemView alloc] initWithFrame:initialFrame index:self.lastListItemIndex];
            [self.viewStack addObject:liView];
            
            initialFrame = CGRectMake(liView.leftSubviewOffset, 0, liView.frame.size.width - liView.leftSubviewOffset, 0);
            
            ContentPageLabelParagraph *paragraphLabel = [[ContentPageLabelParagraph alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:paragraphLabel];
            self.currentString = [[NSMutableAttributedString alloc] init];
            self.textParsingState = TextParsingStateNormal;
        }
        else if ([listView class] == [ContentPageUnorderedListView class]) {
            ContentPageUnorderedListItemView *liView = [[ContentPageUnorderedListItemView alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:liView];
            
            initialFrame = CGRectMake(liView.leftSubviewOffset, 0, liView.frame.size.width - liView.leftSubviewOffset, 0);
            
            ContentPageLabelParagraph *paragraphLabel = [[ContentPageLabelParagraph alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:paragraphLabel];
            self.currentString = [[NSMutableAttributedString alloc] init];
            self.textParsingState = TextParsingStateNormal;
        }
    }
    else if ([elementName isEqualToString:@"a"]) {
        ContentPageButtonView *button;
        initialFrame.size.width *= 0.75f;
        if ([attributeDict objectForKey:@"data-url"]) {
            button = [[ContentPageButtonView alloc] initWithFrame:initialFrame urlString:[attributeDict objectForKey:@"data-url"]];
        }
        else if ([attributeDict objectForKey:@"data-page"]) {
            button = [[ContentPageButtonView alloc] initWithFrame:initialFrame pageString:[attributeDict objectForKey:@"data-page"] delegate:self.buttonDelegate];
        }
        
        if (button != nil) {
            [self.viewStack addObject:button];
            self.currentString = [[NSMutableAttributedString alloc] init];
            self.textParsingState = TextParsingStateNormal;
        }
    }
    else if ([elementName isEqualToString:@"div"]) {
        NSString *className = [attributeDict objectForKey:@"class"];
        if (className == nil) {
            return;
        }
        else if ([className isEqualToString:@"name"]) {
            ContentPageLabelParagraph *paragraphLabel = [[ContentPageLabelParagraph alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:paragraphLabel];
            self.currentString = [[NSMutableAttributedString alloc] init];
            self.textParsingState = TextParsingStateStrong;
        }
        else if ([className isEqualToString:@"row"]) {
            ContentPageLabelParagraph *paragraphLabel = [[ContentPageLabelParagraph alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:paragraphLabel];
            self.currentString = [[NSMutableAttributedString alloc] init];
            self.textParsingState = TextParsingStateNormal;
        }
        else if ([className isEqualToString:@"place"] || [className isEqualToString:@"contact"]) {
            ContentPageTightLabelsContainerView *placeView = [[ContentPageTightLabelsContainerView alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:placeView];
        }
        else if ([className isEqualToString:@"phone"]) {
            ContentPagePhoneView *phoneView = [[ContentPagePhoneView alloc] initWithFrame:CGRectMake(initialFrame.origin.x, initialFrame.origin.y, initialFrame.size.width, 2) phoneNumber:[attributeDict objectForKey:@"data-number"]];
            [self.viewStack addObject:phoneView];
        }
        else if ([className isEqualToString:@"hours"]) {
            ContentPageHoursView *hoursView = [[ContentPageHoursView alloc] initWithFrame:CGRectMake(initialFrame.origin.x, initialFrame.origin.y, initialFrame.size.width, 2)];
            [self.viewStack addObject:hoursView];
        }
        else if ([className isEqualToString:@"mail"]) {
            ContentPageMailView *mailView = [[ContentPageMailView alloc] initWithFrame:CGRectMake(initialFrame.origin.x, initialFrame.origin.y, initialFrame.size.width, 2)];
            mailView.mailAdress = [attributeDict objectForKey:@"data-address"];
            [self.viewStack addObject:mailView];
        }
        else if ([className isEqualToString:@"categories"]) {
            ContentPageCategoriesView *categoriesView = [[ContentPageCategoriesView alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:categoriesView];
        }
        else if ([className isEqualToString:@"citem"]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
                initialFrame.size.width = initialFrame.size.width/2 - 10;
            }
            ContentPageCategoryItemView *itemView = [[ContentPageCategoryItemView alloc] initWithFrame:initialFrame delegate:self.buttonDelegate];
            if (attributeDict[@"data-page"] != nil) {
                itemView.pageToOpenString = attributeDict[@"data-page"];
            }
            [self.viewStack addObject:itemView];
        }
        else if ([className isEqualToString:@"cname"]) {
            initialFrame.size = CGSizeMake(50, 50);
            ContentPageCategoryItemNameLabel *nameLabel = [[ContentPageCategoryItemNameLabel alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:nameLabel];
            self.currentString = [[NSMutableAttributedString alloc] init];
            self.textParsingState = TextParsingStateNormal;
        }
        else if ([className isEqualToString:@"ctext"]) {
            initialFrame.size.width = initialFrame.size.width - 50;
            ContentPageCategoryItemTextLabel *textLabel = [[ContentPageCategoryItemTextLabel alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:textLabel];
            self.currentString = [[NSMutableAttributedString alloc] init];
            self.textParsingState = TextParsingStateNormal;
        }
        else if ([className isEqualToString:@"info"]) {
            ContentPageInfoView *infoView = [[ContentPageInfoView alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:infoView];
        }
        else if ([className isEqualToString:@"shortinfo"]) {
            ContentPageInfoContentView *infoContentView = [[ContentPageInfoContentView alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:infoContentView];
        }
        else if ([className isEqualToString:@"longinfo"]) {
            ContentPageInfoDetailView *infoDetailView = [[ContentPageInfoDetailView alloc] initWithFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y + 20, self.scrollView.frame.size.width, 0)];
            [self.viewStack addObject:infoDetailView];
            
            initialFrame = CGRectMake(infoDetailView.leftSubviewOffset, 0, infoDetailView.frame.size.width - infoDetailView.leftSubviewOffset, 0);
            
            ContentPageInfoDetailContentView *infoDetailContentView = [[ContentPageInfoDetailContentView alloc] initWithFrame:initialFrame];
            [self.view addSubview:infoDetailContentView]; //needed for correct resizing of this view
            [self.viewStack addObject:infoDetailContentView];
        }
        else {
            ContentPageViewBase *view = [[ContentPageViewBase alloc] initWithFrame:initialFrame];
            [self.viewStack addObject:view];
        }
    }
} 

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    self.buttonIfWasLast = nil;
    if ([elementName isEqualToString:@"content"]) {
        return;
    }
    else if ([elementName isEqualToString:@"p"]) {
        ContentPageLabelParagraph *label = [self.viewStack lastObject];
        if ([label class] != [ContentPageLabelParagraph class]) {
            return;
        }
        [self.viewStack removeLastObject];
        if ((self.currentString.length == 0 || [[self.currentString string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) && label.frame.size.height == 0) {
            return;
        }
        label.attributedText = self.currentString;
        
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, [self.currentString boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
        
        [self enlargeView:self.viewStack.lastObject byAddingSubview:label];
        
        self.currentString = nil;
    }
    else if ([elementName isEqualToString:@"h1"]) {
        ContentPageLabelHeader1 *header = [self.viewStack lastObject];
        if ([header class] != [ContentPageLabelHeader1 class]) {
            return;
        }
        [self.viewStack removeLastObject];
        if ((self.currentString.length == 0 || [[self.currentString string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) && header.frame.size.height == 0) {
            return;
        }
        header.attributedText = self.currentString;
        
        header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y, header.frame.size.width, [self.currentString boundingRectWithSize:CGSizeMake(header.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
        
        [self enlargeView:self.viewStack.lastObject byAddingSubview:header];
        
        self.currentString = nil;
    }
    else if ([elementName isEqualToString:@"h2"]) {
        ContentPageLabelHeader2 *header = [self.viewStack lastObject];
        if ([header class] != [ContentPageLabelHeader2 class]) {
            return;
        }
        [self.viewStack removeLastObject];
        if ((self.currentString.length == 0 || [[self.currentString string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) && header.frame.size.height == 0) {
            return;
        }
        header.attributedText = self.currentString;
        
        header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y, header.frame.size.width, [self.currentString boundingRectWithSize:CGSizeMake(header.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
        
        [self enlargeView:self.viewStack.lastObject byAddingSubview:header];
        
        self.currentString = nil;
    }
    else if ([elementName isEqualToString:@"strong"]) {
        self.textParsingState = TextParsingStateNormal;
    }
    else if ([elementName isEqualToString:@"img"]) {
        ContentPageImageView *imageView = [self.viewStack lastObject];
        if ([imageView class] != [ContentPageImageView class]) {
            return;
        }
        [self.viewStack removeLastObject];
        [self enlargeView:self.viewStack.lastObject byAddingSubview:imageView];
    }
    else if ([elementName isEqualToString:@"ul"]) {
        ContentPageUnorderedListView *ulView = [self.viewStack lastObject];
        if ([ulView class] != [ContentPageUnorderedListView class]) {
            return;
        }
        [self.viewStack removeLastObject];
        
        [self enlargeView:[self.viewStack lastObject] byAddingSubview:ulView];
    }
    else if ([elementName isEqualToString:@"ol"]) {
        ContentPageOrderedListView *olView = [self.viewStack lastObject];
        if ([olView class] != [ContentPageOrderedListView class]) {
            return;
        }
        [self.viewStack removeLastObject];
        self.lastListItemIndex = 0;
        
        [self enlargeView:[self.viewStack lastObject] byAddingSubview:olView];
    }
    else if ([elementName isEqualToString:@"li"]) {
        ContentPageLabelParagraph *label = [self.viewStack lastObject];
        if ([label class] != [ContentPageLabelParagraph class]) {
            return;
        }
        [self.viewStack removeLastObject];
        if ((self.currentString.length == 0 || [[self.currentString string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) && label.frame.size.height == 0) {
            return;
        }
        label.attributedText = self.currentString;
        
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, [self.currentString boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
        
        [self enlargeView:self.viewStack.lastObject byAddingSubview:label];
        
        self.currentString = nil;
        
        id unknownTypeListItemView = [self.viewStack lastObject];
        if ([unknownTypeListItemView class] == [ContentPageUnorderedListItemView class]) {
            ContentPageUnorderedListItemView *liView = unknownTypeListItemView;
            [self.viewStack removeLastObject];
            
            [self enlargeView:[self.viewStack lastObject] byAddingSubview:liView];
        }
        else if ([unknownTypeListItemView class] == [ContentPageOrderedListItemView class]) {
            ContentPageOrderedListItemView *liView = unknownTypeListItemView;
            [self.viewStack removeLastObject];
            
            [self enlargeView:[self.viewStack lastObject] byAddingSubview:liView];
        }
        else return;
    }
    else if ([elementName isEqualToString:@"a"]) {
        ContentPageButtonView *buttonView = self.viewStack.lastObject;
        if ([buttonView class] != [ContentPageButtonView class]) {
            return;
        }
        [self.viewStack removeLastObject];
        
        if ((self.currentString.length == 0 || [[self.currentString string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) && buttonView.frame.size.height == 0) {
            return;
        }
        buttonView.label.attributedText = self.currentString;
        
        CGRect frame = buttonView.frame;
        frame.size.height = [self.currentString boundingRectWithSize:CGSizeMake(buttonView.label.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height + 20;
        
        buttonView.frame = frame;
        
        [self enlargeView:self.viewStack.lastObject byAddingSubview:buttonView];
        
        self.buttonIfWasLast = buttonView;
        
        self.currentString = nil;
    }
    else if ([elementName isEqualToString:@"div"]) {
        UIView *unknownTypeView = [self.viewStack lastObject];
        if ([unknownTypeView class] == [ContentPageCategoriesView class]) {
            ContentPageCategoriesView *categoriesView = (ContentPageCategoriesView*)unknownTypeView;
            [self.viewStack removeLastObject];
            
            [self enlargeView:[self.viewStack lastObject] byAddingSubview:categoriesView];
        }
        else if ([unknownTypeView class] == [ContentPageCategoryItemView class]) {
            ContentPageCategoryItemView *itemView = (ContentPageCategoryItemView*)unknownTypeView;
            [self.viewStack removeLastObject];
            
            [self addCategoryItemView:itemView toCategoriesView:self.viewStack.lastObject];
        }
        else if ([unknownTypeView class] == [ContentPageCategoryItemNameLabel class]) {
            ContentPageCategoryItemNameLabel *nameLabel = (ContentPageCategoryItemNameLabel*)unknownTypeView;
            [self.viewStack removeLastObject];
            if ((self.currentString.length == 0 || [[self.currentString string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) && nameLabel.frame.size.height == 0) {
                return;
            }
            nameLabel.attributedText = self.currentString;
            
            nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, nameLabel.frame.size.width, [self.currentString boundingRectWithSize:CGSizeMake(nameLabel.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
            
            [self addCategoryNameLabel:nameLabel toCategoryItemView:self.viewStack.lastObject];
            
            self.currentString = nil;

        }
        else if ([unknownTypeView class] == [ContentPageCategoryItemTextLabel class]) {
            ContentPageCategoryItemTextLabel *textLabel = (ContentPageCategoryItemTextLabel*)unknownTypeView;
            [self.viewStack removeLastObject];
            if ((self.currentString.length == 0 || [[self.currentString string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) && textLabel.frame.size.height == 0) {
                return;
            }
            textLabel.attributedText = self.currentString;
            
            textLabel.frame = CGRectMake(textLabel.frame.origin.x, textLabel.frame.origin.y, textLabel.frame.size.width, [self.currentString boundingRectWithSize:CGSizeMake(textLabel.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
            
            [self addCategoryTextLabel:textLabel toCategoryItemView:self.viewStack.lastObject];
            
            self.currentString = nil;
        }
        else if ([unknownTypeView class] == [ContentPageMailView class]) {
            ContentPageMailView *mailView = (ContentPageMailView*)unknownTypeView;
            [self.viewStack removeLastObject];
            
            if (mailView.frame.size.height == 2) {
                return;
            }
            
            if (mailView.frame.size.height < 24) {
                mailView.frame = CGRectMake(mailView.frame.origin.x, mailView.frame.origin.y, mailView.frame.size.width, 24);
            }
            
            [self enlargeView:[self.viewStack lastObject] byAddingSubview:mailView];
        }
        else if ([unknownTypeView class] == [ContentPagePhoneView class]) {
            ContentPagePhoneView *phoneView = (ContentPagePhoneView*)unknownTypeView;
            [self.viewStack removeLastObject];
            
            if (phoneView.frame.size.height == 2) {
                return;
            }
            
            if (phoneView.frame.size.height < 24) {
                phoneView.frame = CGRectMake(phoneView.frame.origin.x, phoneView.frame.origin.y, phoneView.frame.size.width, 24);
            }
            
            [self enlargeView:[self.viewStack lastObject] byAddingSubview:phoneView];
        }
        else if ([unknownTypeView class] == [ContentPageHoursView class]) {
            ContentPageHoursView *hoursView = (ContentPageHoursView*)unknownTypeView;
            [self.viewStack removeLastObject];
            
            if (hoursView.frame.size.height == 2) {
                return;
            }
            
            if (hoursView.frame.size.height < 24) {
                hoursView.frame = CGRectMake(hoursView.frame.origin.x, hoursView.frame.origin.y, hoursView.frame.size.width, 24);
            }
            
            [self enlargeView:[self.viewStack lastObject] byAddingSubview:hoursView];
        }
        else if ([unknownTypeView class] == [ContentPageInfoView class]) {
            ContentPageInfoView *infoView = (ContentPageInfoView*)unknownTypeView;
            [self.viewStack removeLastObject];
            
            if (infoView.frame.size.height < 52) {
                CGRect infoFrame = infoView.frame;
                infoFrame.size.height = 52;
                infoView.frame = infoFrame;
            }
            [self enlargeView:self.viewStack.lastObject byAddingSubview:infoView];
        }
        else if ([unknownTypeView class] == [ContentPageInfoContentView class]) {
            ContentPageInfoContentView *infoContentView = (ContentPageInfoContentView*)unknownTypeView;
            [self.viewStack removeLastObject];
            
            if (infoContentView.frame.size.height < 52) {
                CGRect infoContentFrame = infoContentView.frame;
                for (UIView *subview in infoContentView.subviews) {
                    if ([subview isKindOfClass:[ContentPageViewBase class]] || [subview isKindOfClass:[ContentPageLabelBase class]]) {
                        CGRect subviewFrame = subview.frame;
                        subviewFrame.size.height = ceilf(subview.frame.size.height * 52.0 / infoContentFrame.size.height);
                        subview.frame = subviewFrame;
                    }
                }
                infoContentFrame.size.height = 52;
                infoContentView.frame = infoContentFrame;
            }
            
            [self enlargeView:self.viewStack.lastObject byAddingSubview:infoContentView];
        }
        else if ([unknownTypeView class] == [ContentPageInfoDetailContentView class]) {
            ContentPageInfoDetailContentView *infoDetailContentView = (ContentPageInfoDetailContentView*)unknownTypeView;
            [self.viewStack removeLastObject];
            if ([self.viewStack.lastObject class] != [ContentPageInfoDetailView class]) {
                return;
            }
            
            infoDetailContentView.scrollView.contentSize = CGSizeMake(infoDetailContentView.scrollView.frame.size.width, infoDetailContentView.scrollView.frame.size.height);
            if (infoDetailContentView.frame.size.height > 0.5f * self.view.frame.size.height) {
                CGRect infoDetContViewFrame = infoDetailContentView.frame;
                infoDetContViewFrame.size.height = self.view.frame.size.height * 0.5f;
                infoDetailContentView.frame = infoDetContViewFrame;
            }
            
            
            if (infoDetailContentView.frame.size.height < 52) {
                CGRect infoDetContViewFrame = infoDetailContentView.frame;
                for (UIView *subview in infoDetailContentView.scrollView.subviews) {
                    if ([subview isKindOfClass:[ContentPageViewBase class]] || [subview isKindOfClass:[ContentPageLabelBase class]]) {
                        CGRect subviewFrame = subview.frame;
                        subviewFrame.size.height = ceilf(subview.frame.size.height * 52.0 / infoDetContViewFrame.size.height);
                        subview.frame = subviewFrame;
                    }
                }
                infoDetContViewFrame.size.height = 52;
                infoDetailContentView.frame = infoDetContViewFrame;
                infoDetailContentView.scrollView.frame = infoDetailContentView.bounds;
                infoDetailContentView.scrollView.contentSize = infoDetContViewFrame.size;
                infoDetailContentView.scrollView.contentInset = UIEdgeInsetsZero;
            }
            else {
                CGRect infoDetContViewFrame = infoDetailContentView.frame;
                infoDetContViewFrame.size.height += infoDetailContentView.scrollView.contentInset.top + infoDetailContentView.scrollView.contentInset.bottom;
                infoDetailContentView.frame = infoDetContViewFrame;
            }
            
            ContentPageInfoDetailView *infoDetailView = self.viewStack.lastObject;
            
            [self enlargeView:infoDetailView byAddingSubview:infoDetailContentView];
            
            if (infoDetailView.frame.size.height < 52) {
                CGRect infoFrame = infoDetailView.frame;
                infoFrame.size.height = 52;
                infoDetailView.frame = infoFrame;
            }
            
            infoDetailView.hidden = YES;
            [self.view addSubview:infoDetailView];
            [self.viewStack removeLastObject];
            
            if ([self.viewStack.lastObject class] == [ContentPageInfoView class]) {
                ((ContentPageInfoView*)self.viewStack.lastObject).infoDetailView = infoDetailView;
            }
        }
        else if ([unknownTypeView respondsToSelector:@selector(setAttributedText:)]) {
            UILabel *label = (UILabel*)unknownTypeView;
            [self.viewStack removeLastObject];
            if ((self.currentString.length == 0 || [[self.currentString string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) && label.frame.size.height == 0) {
                return;
            }
            label.attributedText = self.currentString;
            
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, [self.currentString boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
            
            [self enlargeView:self.viewStack.lastObject byAddingSubview:label];
            
            self.currentString = nil;
        }
        else {
            [self.viewStack removeLastObject];
            
            [self enlargeView:[self.viewStack lastObject] byAddingSubview:unknownTypeView];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {
    return;
}

/** Parser encountered text. If we were expecting text, we add it to currentString with proper font, otherwise we ignore it */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([[self.viewStack lastObject] respondsToSelector:@selector(setAttributedText:)] || [[self.viewStack lastObject] class] == [ContentPageButtonView class]) {
        UIFont *font;
        if (self.textParsingState == TextParsingStateNormal) {
            font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:((UILabel*)[self.viewStack lastObject]).font.pointSize];
        }
        else {
            font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:((UILabel*)[self.viewStack lastObject]).font.pointSize];
        }
        
        NSAttributedString *stringToAppend = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: font, NSKernAttributeName: [NSNull null]}];
        if (self.currentString) {
            [self.currentString appendAttributedString:stringToAppend];
        }
        else {
            self.currentString = [stringToAppend mutableCopy];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"parser failed with error %@", [parseError localizedDescription]);
    return;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.lastAddedView = nil;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + 17);
    
    /* We're finished with creation of the layout saved in page's XML, now, it it's list-type page, at the bottom of page we create a list of links to children pages */
    if ([self.page.type isEqualToString:@"list"]) {
        NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %d", [self.page.pageId  intValue]];
        
        NSArray *unorderedChildrenPagesArray = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        NSArray *childrenPagesArray = [unorderedChildrenPagesArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSNumber *first = [(Page*)a index];
            NSNumber *second = [(Page*)b index];
            return [first compare:second];
        }];
        
        
        for (Page *childPage in childrenPagesArray) {
            ContentPageListButton *button = [[ContentPageListButton alloc] initWithFrame:CGRectMake(-self.scrollView.frame.origin.x, self.scrollView.contentSize.height, self.view.frame.size.width, 0) page:childPage];
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width, button.label.frame.size.height + 20);
            [button addTarget:self action:@selector(didTapListButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:button];
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + button.frame.size.height);
        }
        
        UIView *lastLine = [[UIView alloc] initWithFrame:CGRectMake(-self.scrollView.frame.origin.x, self.scrollView.contentSize.height, self.view.frame.size.width, 1)];
        lastLine.backgroundColor = [UIColor grayColor];
        lastLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:lastLine];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + 1);
    }
}

/** This method adds another view that we just finished parsing and ensures its proper positioning. */
- (void)enlargeView:(UIView*)superView byAddingSubview:(UIView*)view {
    self.lastAddedView = nil;
    
    if ([view isKindOfClass:[ContentPageUnorderedListView class]] || [view isKindOfClass:[ContentPageOrderedListView class]]) {
        if (self.buttonIfWasLast) {
            CGRect btnFrame = self.buttonIfWasLast.frame;
            btnFrame.origin.x += ((ContentPageViewBase*)view).leftSubviewOffset;
            btnFrame.size.width -= ((ContentPageViewBase*)view).leftSubviewOffset;
        }
        self.wasListLast = YES;
    }
    else {
        self.wasListLast = NO;
    }
    
    if (superView != self.scrollView) {
        for (UIView *subview in superView.subviews) {
            if ([subview isKindOfClass:[ContentPageViewBase class]] || [subview isKindOfClass:[ContentPageLabelBase class]]) {
                self.lastAddedView = superView.subviews.lastObject;
            }
        }
    }
    else { //for scroll view we have to exclude scrolling indicators
        for (UIView *subview in superView.subviews) {
            if (![subview isKindOfClass:[UIImageView class]] && ![subview isKindOfClass:[ContentPageMapView class]]) {
                self.lastAddedView = subview;
            }
        }
    }
    CGFloat marginTop = [self topMarginForView:view withSuperview:superView];
    if (view.frame.size.height == 0 || view == self.scrollView || [superView respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    if (superView == self.scrollView) {
        view.frame = CGRectMake(view.frame.origin.x, self.scrollView.contentSize.height + marginTop, view.frame.size.width, ceilf(view.frame.size.height));
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + view.frame.size.height + marginTop);
    }
    else { //superView is instance of one of our custom view subclasses
        view.frame = CGRectMake(((ContentPageViewBase*)superView).leftSubviewOffset, superView.frame.size.height + marginTop, view.frame.size.width, ceilf(view.frame.size.height));
        CGRect superViewFrame = superView.frame;
        superViewFrame.size.height += view.frame.size.height + marginTop;
        superView.frame = superViewFrame;
    }
    
    [superView addSubview:view];
}

/** specialized version of the enlargeView:byAddingSubview: method */
- (void)addCategoryItemView:(ContentPageCategoryItemView*)itemView toCategoriesView:(ContentPageCategoriesView*)categoriesView {
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || UIInterfaceOrientationIsLandscape(self.interfaceOrientation))) {
        [self enlargeView:categoriesView byAddingSubview:itemView];
        return;
    }
    if (categoriesView.numberOfItems %2 == 0) {
        itemView.frame = CGRectMake(0, categoriesView.frame.size.height, itemView.frame.size.width, itemView.frame.size.height);
        
        CGRect categoriesFrame = categoriesView.frame;
        categoriesFrame.size.height = categoriesFrame.size.height + itemView.frame.size.height + 17;
        categoriesView.frame = categoriesFrame;
    }
    else {
        itemView.frame = CGRectMake(categoriesView.frame.size.width/2, ((UIView*)categoriesView.subviews.lastObject).frame.origin.y, itemView.frame.size.width, itemView.frame.size.height);
        
        if (itemView.frame.size.height > ((UIView*)categoriesView.subviews.lastObject).frame.size.height) {
            CGRect categoriesFrame = categoriesView.frame;
            categoriesFrame.size.height = categoriesFrame.size.height + (itemView.frame.size.height - ((UIView*)categoriesView.subviews.lastObject).frame.size.height);
            categoriesView.frame = categoriesFrame;
            
        }
    }
    categoriesView.numberOfItems = categoriesView.numberOfItems + 1;
    
    [categoriesView addSubview:itemView];
}

- (void)addCategoryNameLabel:(ContentPageCategoryItemNameLabel*)nameLabel toCategoryItemView:(ContentPageCategoryItemView*)itemView {
    nameLabel.frame = CGRectMake(0, 0, 50, 50);
    
    [itemView addSubview:nameLabel];
    CGRect itemFrame = itemView.frame;
    itemFrame.size.height += nameLabel.frame.size.height;
    itemView.frame = itemFrame;
    if (itemView.subviews.count == 2) {
        [itemView sizeToFit];
    }
}

- (void)addCategoryTextLabel:(ContentPageCategoryItemTextLabel*)textLabel toCategoryItemView:(ContentPageCategoryItemView*)itemView {
    textLabel.frame = CGRectMake(55, 0, itemView.frame.size.width - 60, MAX(50,textLabel.frame.size.height));
    
    [itemView addSubview:textLabel];
    CGRect itemFrame = itemView.frame;
    if (textLabel.frame.size.height > itemView.frame.size.height) {
        itemFrame.size.height = textLabel.frame.size.height;
    }
    itemView.frame = itemFrame;
    if (itemView.subviews.count == 2) {
        [itemView sizeToFit];
    }
}

- (CGFloat)topMarginForView:(UIView*)view withSuperview:(UIView*)superview{
    if (self.lastAddedView == nil) {
        if (superview == self.scrollView) {  // first view to be added to content page
            if ([view isKindOfClass:[ContentPageLabelBase class]]) {
                if ([view isKindOfClass:[ContentPageLabelHeader1 class]] || [view isKindOfClass:[ContentPageLabelHeader2 class]]) {
                    return [AppDelegate smallSpace];
                }
                else {
                    return [AppDelegate mediumSpace];
                }
            }
            else {
                return [AppDelegate mediumSpace];
            }
        }
        else if ([view isKindOfClass:[ContentPageButtonView class]]) {
            return [AppDelegate smallSpace];
        }
        else {
            return 0;
        }
    }
    else if (self.lastAddedView.superview != superview) { // first view inside a container
        return 0;
    }
    else {
        if ([superview isKindOfClass:[ContentPageTightLabelsContainerView class]] || [superview isKindOfClass:[ContentPagePhoneView class]] || [superview isKindOfClass:[ContentPageMailView class]] || [superview isKindOfClass:[ContentPageHoursView class]]) {
            return 0;
        }
        
        if ([view isKindOfClass:[ContentPageButtonView class]]) {
            if ([self.lastAddedView isKindOfClass:[ContentPageButtonView class]]) {
                return [AppDelegate smallSpace];
            }
        }
        else if (([view isKindOfClass:[ContentPageOrderedListItemView class]] || [view isKindOfClass:[ContentPageUnorderedListItemView class]]) && ([self.lastAddedView isKindOfClass:[ContentPageOrderedListItemView class]] || ([self.lastAddedView isKindOfClass:[ContentPageUnorderedListItemView class]]))) {
            return [AppDelegate smallSpace];
            
        }
        else if ([view isKindOfClass:[ContentPageLabelHeader1 class]]) {
            return [AppDelegate largeSpace];
        }
        else if ([view isKindOfClass:[ContentPageLabelHeader2 class]]) {
            return [AppDelegate largeSpace];
        }
        else if ([view isKindOfClass:[ContentPageLabelParagraph class]]) {
            if ([self.lastAddedView isKindOfClass:[ContentPageLabelParagraph class]]) {
                return [AppDelegate smallSpace];
            }
        }
        else if([view isKindOfClass:[ContentPageImageView class]]) {
            if ([self.lastAddedView isKindOfClass:[ContentPageImageView class]]) {
                return [AppDelegate smallSpace];
            }
        }
    }
    
    return [AppDelegate mediumSpace];
}

- (void)didChangeLanguage:(NSNotification *)notification {
    [super didChangeLanguage:notification];
    self.rightBarButton.selected = NO;
    [self prepareLayoutFromXml];
}

- (void)didTapListButton:(ContentPageListButton*)button {
    [self openPage:button.page];
}

- (void)openPage:(Page*)page {
    if (self.embeddingViewController != nil) {
        [self.embeddingViewController openPage:page];
    }
    else {
        BaseViewController *viewController;
        
        if ([page.type isEqualToString:@"text"] || [page.type isEqualToString:@"cont"] || [page.type isEqualToString:@"list"] || [page.type isEqualToString:@"stps"]) {
            viewController = [[ContentPageViewController alloc] init];
            if ([page.type isEqualToString:@"stps"]) {
                viewController.isStep = YES;
            }
            else {
                NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                fetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %@", page.pageId];
                
                Page *parentPage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] firstObject];
                if ([parentPage.type isEqualToString:@"stps"]) {
                    viewController.isStep = YES;
                }
            }
        }
        else if ([page.type isEqualToString:@"file"]) {
            viewController = [[AGIPDFTableViewController alloc] init];
        }
        else if ([page.type isEqualToString:@"head"]) {
            viewController = [[NewsTableViewController alloc] init];
        }
        else if ([page.type isEqualToString:@"faqs"]) {
            viewController = [[FaqViewController alloc] init];
        }
        
        if (viewController != nil) {
            viewController.page = page;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

/** Called when user taps a button linking to another page within application */
- (void)openPageWithString:(NSString *)pageString {
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pageId = %@", pageString];
    
    Page *pageToOpen = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] firstObject];
    
    [self openPage:pageToOpen];
}

@end
