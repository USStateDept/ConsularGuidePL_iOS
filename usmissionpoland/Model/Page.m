//
//  Page.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 12/18/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "Page.h"
#import "AppDelegate.h"


@implementation Page

@dynamic contentEN;
@dynamic contentPL;
@dynamic pageId;
@dynamic titleEN;
@dynamic parentId;
@dynamic type;
@dynamic version;
@dynamic titlePL;
@dynamic index;
@dynamic latitude;
@dynamic longitude;
@dynamic mapZoom;
@dynamic additionalEN;
@dynamic additionalPL;

- (NSString *)localizedContent {
    return [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? self.contentPL : self.contentEN;
}

- (NSString *)localizedTitle {
    return [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? self.titlePL : self.titleEN;
}

- (NSString *)localizedAdditionalContent {
    return [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? self.additionalPL : self.additionalEN;
}

- (NSArray *)childrenPagesArray {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %d", [self.pageId intValue]];
    NSArray *childrenPages = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    childrenPages = [childrenPages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(Page*)a index];
        NSNumber *second = [(Page*)b index];
        return [first compare:second];
    }];
    if ([self.type isEqualToString:@"stps"]) {
        childrenPages = [@[self] arrayByAddingObjectsFromArray:childrenPages];
    }
    
    return childrenPages;
}

@end
