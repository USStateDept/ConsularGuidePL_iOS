//
//  PassportStatusViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 3/28/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "PassportStatusViewController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"

@interface PassportStatusViewController ()

@property (nonatomic, strong) NSXMLParser *serverAParser;
@property (nonatomic, strong) NSXMLParser *serverBParser;
@property (nonatomic, strong) NSXMLParser *serverCParser;

@property (nonatomic, strong) NSString *viewStateString;
@property (nonatomic, strong) NSString *viewStateVersionString;
@property (nonatomic, strong) NSString *viewStateMacString;

@property (nonatomic, strong) NSMutableString *resultString;

@end

@implementation PassportStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame))];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    BilingualLabel *infoLabel = [[BilingualLabel alloc] initWithTextEnglish:@"After your visa interview at the Embassy, you may wish to track the location of your passport. Please use the following form to check the status of your passport.\nIf your passport is ready for pick-up, please collect it in a timely manner and bring supporting documents.\nPlease note that TNT Express will only hold passports for 9 calendar days from the date that you receive confirmation that your passport has arrived at the pickup location. Failure to pick up your passport within this time may cause delays in the receipt of your passport." polish:@"Po rozmowie wizowej w Ambasadzie można sprawdzić, gdzie znajduje się paszport. Aby sprawdzić status paszportu, należy wypełnić ten formularz.\nJeśli paszport jest gotowy do odebrania, należy go odebrać w stosownym czasie i przedstawić wymagane dokumenty.\nPaszport będzie można odebrać w TNT Express przez 9 dni kalendarzowych od otrzymania potwierdzenia o dostarczeniu paszportu do wybranego punktu. Nieodebranie paszportu w wyznaczonym czasie może spowodować, że otrzymają go Państwo z opóźnieniem."];
    infoLabel.numberOfLines = 0;
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:16];
    infoLabel.frame = CGRectMake(16, [AppDelegate smallSpace], self.view.frame.size.width - 32, 1000);
    [infoLabel sizeToFit];
    [self.scrollView addSubview:infoLabel];
    self.infoLabel = infoLabel;
    
    id<ContentPageButtonDelegate> homeVc = ((AppDelegate*)[UIApplication sharedApplication].delegate).navController.viewControllers.firstObject;
    ContentPageButtonView *tntButtonView = [[ContentPageButtonView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(infoLabel.frame) + 10, self.view.frame.size.width - 32, 40) pageString:@"209" delegate:homeVc];
    tntButtonView.label.text = [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? @"Lokalizacja placówek TNT" : @"TNT Locations";
    tntButtonView.label.font = infoLabel.font;
    [self.scrollView addSubview:tntButtonView];
    self.tntButtonView = tntButtonView;
    
    UITextField *passportNumberField = [[UITextField alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.tntButtonView.frame) + 20, self.view.frame.size.width - 32, 40)];
    passportNumberField.placeholder = [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish? @"Wprowadź swój numer paszportu" : @"Enter your passport number";
    passportNumberField.delegate = self;
    passportNumberField.autocorrectionType = UITextAutocorrectionTypeNo;
    passportNumberField.returnKeyType = UIReturnKeySend;
    passportNumberField.font = infoLabel.font;
    [self.scrollView addSubview:passportNumberField];
    self.passportNumberField = passportNumberField;
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(passportNumberField.frame) + 20, self.view.frame.size.width - 32, 80)];
    statusLabel.numberOfLines = 2;
    statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    statusLabel.font = infoLabel.font;
    [self.scrollView addSubview:statusLabel];
    self.statusLabel = statusLabel;
    
    
    ((UINavigationItem*)self.navBar.items.lastObject).title = [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? @"Status Paszportu" : @"Passport Tracker";
    
    
    [self.view bringSubviewToFront:self.navBar];
}

- (void)viewDidLayoutSubviews {
    self.infoLabel.frame = CGRectMake(16, [AppDelegate smallSpace], self.view.frame.size.width - 20, 1000);
    [self.infoLabel sizeToFit];
    
    self.tntButtonView.frame = CGRectMake(16, CGRectGetMaxY(self.infoLabel.frame) + 10, self.view.frame.size.width - 32, 40);
    
    self.passportNumberField.frame = CGRectMake(16, CGRectGetMaxY(self.tntButtonView.frame) + 20, self.view.frame.size.width - 32, 40);
    
    self.statusLabel.frame = CGRectMake(16, CGRectGetMaxY(self.passportNumberField.frame) + 20, self.view.frame.size.width - 32, 80);
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.statusLabel.frame));
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    
    NSData *serverAResponseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? @"http://www.ustraveldocs.com/pl_pl/pl-niv-passporttrack.asp" : @"http://www.ustraveldocs.com/pl/pl-niv-passporttrack.asp"]];
    
    if (serverAResponseData) {
        NSString *responseString = [[NSString alloc] initWithData:serverAResponseData encoding:NSUTF8StringEncoding];
        responseString = [self xmlObjectStringFromString:responseString ContainingAttributeWithValue:@"instantIFrame"];
        
        NSXMLParser *serverAParser = [[NSXMLParser alloc] initWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]];
        self.serverAParser = serverAParser;
        serverAParser.delegate = self;
        [serverAParser parse];
    }
    else {
        self.statusLabel.text = [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? @"Błąd połączenia z serwerem. Spróbuj ponownie później." : @"Server connection error. Please try again later";
    }
    
    return NO;
}

- (void)sendRequestToServerB:(NSString*)serverBAddress {
    NSData *serverBResponseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:serverBAddress]];
    NSString *serverBResponseString = [[NSString alloc] initWithData:serverBResponseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"server B returned \n\n%@", [[NSString alloc] initWithData:serverBResponseData encoding:NSUTF8StringEncoding]);
    
    self.viewStateString = nil;
    self.viewStateVersionString = nil;
    self.viewStateMacString = nil;
    
    NSArray *searchObjectsArray = @[@"com.salesforce.visualforce.ViewState", @"com.salesforce.visualforce.ViewStateVersion", @"com.salesforce.visualforce.ViewStateMAC"];
    for (NSString *searchObject in searchObjectsArray) {
        NSString *xmlSubstring = [self xmlObjectStringFromString:serverBResponseString ContainingAttributeWithValue:searchObject];
        
        NSXMLParser *serverBParser = [[NSXMLParser alloc] initWithData:[xmlSubstring dataUsingEncoding:NSUTF8StringEncoding]];
        self.serverBParser = serverBParser;
        serverBParser.delegate = self;
        [serverBParser parse];
    }
    
    if (self.viewStateString && self.viewStateVersionString && self.viewStateMacString) {
        [self sendRequestToServerCWithReferer:serverBAddress];
    }
}

- (void)sendRequestToServerCWithReferer:(NSString*)referer {
    NSDictionary *paramsDict = @{@"AJAXREQUEST" : @"_viewRoot",
                                 @"passportTrackerPage:psptTrackerForm" : @"passportTrackerPage:psptTrackerForm",
                                 @"passportTrackerPage:psptTrackerForm:j_id34:j_id35:passportNo" : self.passportNumberField.text,
                                 @"com.salesforce.visualforce.ViewState" : self.viewStateString,
                                 @"com.salesforce.visualforce.ViewStateVersion" : self.viewStateVersionString,
                                 @"com.salesforce.visualforce.ViewStateMAC" : self.viewStateMacString,
                                 @"passportTrackerPage:psptTrackerForm:trackButton" : @"passportTrackerPage:psptTrackerForm:trackButton",
                                 @"Referer" : referer
                                 };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer = requestSerializer;
    
    
    [manager POST:@"http://cgifederal.force.com/passporttracker" parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Hey! Listen! Response!\n%@\n\n\n\nRequest!\n%@", operation, operation.request);
        NSString *serverCResponseString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Server C response: %@", serverCResponseString);
        
        NSString *resultXmlString = [self xmlObjectStringFromString:serverCResponseString ContainingAttributeWithValue:@"result"];
        
        self.resultString = nil;
        
        NSXMLParser *serverCParser = [[NSXMLParser alloc] initWithData:[resultXmlString dataUsingEncoding:NSUTF8StringEncoding]];
        self.serverCParser = serverCParser;
        serverCParser.delegate = self;
        [serverCParser parse];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error C: %@", [error localizedDescription]);
    }];
}

- (NSString*)xmlObjectStringFromString:(NSString*)superString ContainingAttributeWithValue:(NSString*)attributeString {
    NSRange attributeRange = [superString rangeOfString:attributeString];
    if (attributeRange.length == 0) {
        self.statusLabel.text = @"Error when connecting to server. Try again later.";
    }
    NSRange searchRange;
    searchRange.location = 0;
    searchRange.length = attributeRange.location;
    NSRange xmlObjectStartRange = [superString rangeOfString:@"<" options:NSBackwardsSearch range:searchRange];
    searchRange.location = attributeRange.location;
    searchRange.length = superString.length - searchRange.location;
    NSRange xmlObjectEndRange = [superString rangeOfString:@">" options:0 range:searchRange];
    searchRange.location = xmlObjectEndRange.location + xmlObjectEndRange.length;
    searchRange.length = superString.length - searchRange.location;
    xmlObjectEndRange = [superString rangeOfString:@">" options:0 range:searchRange]; //this is to get to the closing token of the object - with assumption that there are no tokens between the object's start and end token;
    
    NSRange xmlObjectRange;
    xmlObjectRange.location = xmlObjectStartRange.location;
    xmlObjectRange.length = xmlObjectEndRange.location + xmlObjectEndRange.length - xmlObjectStartRange.location;
    
    
    return [superString substringWithRange:xmlObjectRange];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if (parser == self.serverAParser) {
        if ([elementName isEqualToString:@"iframe"]) {
            for (id key in attributeDict) {
                if ([[attributeDict valueForKey:key] isEqualToString:@"instantIFrame"]) {
                    [parser abortParsing];
                    self.serverAParser = nil;
                    NSLog(@"success src = %@", [attributeDict objectForKey:@"src"]);
                    [self sendRequestToServerB:[attributeDict objectForKey:@"src"]];
                    break;
                }
            }
        }
    }
    
    if (parser == self.serverBParser) {
        if ([elementName isEqualToString:@"input"]) {
            for (id key in attributeDict) {
                if ([[attributeDict valueForKey:key] isEqualToString:@"com.salesforce.visualforce.ViewState"]) {
                    [parser abortParsing];
                    self.serverBParser = nil;
                    NSLog(@"success com.salesforce.visualforce.ViewState = %@", [attributeDict objectForKey:@"value"]);
                    self.viewStateString = [attributeDict objectForKey:@"value"];
                    break;
                }
            }
            for (id key in attributeDict) {
                if ([[attributeDict valueForKey:key] isEqualToString:@"com.salesforce.visualforce.ViewStateVersion"]) {
                    [parser abortParsing];
                    self.serverBParser = nil;
                    NSLog(@"success com.salesforce.visualforce.ViewStateVersion = %@", [attributeDict objectForKey:@"value"]);
                    self.viewStateVersionString = [attributeDict objectForKey:@"value"];
                    break;
                }
            }
            for (id key in attributeDict) {
                if ([[attributeDict valueForKey:key] isEqualToString:@"com.salesforce.visualforce.ViewStateMAC"]) {
                    [parser abortParsing];
                    self.serverBParser = nil;
                    NSLog(@"success com.salesforce.visualforce.ViewStateMAC = %@", [attributeDict objectForKey:@"value"]);
                    self.viewStateMacString = [attributeDict objectForKey:@"value"];
                    break;
                }
            }
        }
    }
    
    if (parser == self.serverCParser) {
        self.resultString = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (parser == self.serverCParser) {
        if (self.resultString) {
            [self.resultString appendString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Parser error %@", parseError);
    if (parser == self.serverCParser) {
        self.serverCParser = nil;
        self.statusLabel.text = [NSString stringWithString:self.resultString];
        self.resultString = nil;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Parsing finished");
    if (parser == self.serverCParser) {
        self.serverCParser = nil;
        if (self.resultString.length > 0) {
            self.statusLabel.text = [NSString stringWithString:self.resultString];
        }
        else {
            self.statusLabel.text = [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? @"Błąd połączenia z serwerem. Spróbuj ponownie później." : @"Server connection error. Please try again later";
        }
        self.resultString = nil;
    }
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)notification {
    self.offsetBeforeKeyboardWasShown = self.scrollView.contentOffset;
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.navBar.frame) * 2 - CGRectGetMaxY(self.tntButtonView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame));
        self.scrollView.contentOffset = CGPointZero;
        self.scrollView.scrollEnabled = NO;
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.navBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navBar.frame));
        self.scrollView.contentOffset = self.offsetBeforeKeyboardWasShown;
        self.scrollView.scrollEnabled = YES;
    }];
}

- (void)didChangeLanguage:(NSNotification *)notification {
    [super didChangeLanguage:notification];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        self.tntButtonView.label.text = @"Lokalizacja placówek TNT";
        self.passportNumberField.placeholder = @"Wprowadź swój numer paszportu";
        ((UINavigationItem*)self.navBar.items.lastObject).title = @"Status Paszportu";
    }
    else {
        self.tntButtonView.label.text = @"TNT Locations";
        self.passportNumberField.placeholder = @"Enter your passport number";
        ((UINavigationItem*)self.navBar.items.lastObject).title = @"Pasport tracker";
    }
    [self.view setNeedsLayout];
}

@end
