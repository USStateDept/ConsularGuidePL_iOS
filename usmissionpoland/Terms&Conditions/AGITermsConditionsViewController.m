//
//  AGITermsConditionsViewController.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 05.03.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AGITermsConditionsViewController.h"
#import "BilingualLabel.h"
#import "AppDelegate.h"
#import "ECSlidingViewController.h"

@interface AGITermsConditionsViewController ()

@property (weak, nonatomic) UIScrollView *welcomeView;
@property (weak, nonatomic) BilingualLabel *welcomeLabel;
@property (weak, nonatomic) UITextView *welcomeTextView;

@property (weak, nonatomic) UIView *termsConditionsView;
@property (weak, nonatomic) UITextView *termsInfoView;
@property (weak, nonatomic) UIButton *acceptButton;

@property (weak, nonatomic) UIImageView *logoView;

@property (strong, nonatomic) BilingualLabel *updatingLabel;

@end

@implementation AGITermsConditionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithContentViews:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self loadContentViews:@[[self createWelcomeView], [self createTermsConditionsView]]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablet_usa.png"]];
        logoView.frame = CGRectMake(self.view.frame.size.width /2 - 38.5, [[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending ? 26 : 6, 77, 76);
        logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:logoView];
        self.logoView = logoView;
    }
    else {
        UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile_welcome_usa_big.png"]];
        logoView.frame = CGRectMake(self.view.frame.size.width /2 - 81.5, [[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending ? 50 : 30, 163, 162);
        logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:logoView];
        self.logoView = logoView;
    }
}

- (UIView *)createWelcomeView
{
    UIScrollView *welcomeView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    welcomeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.welcomeView = welcomeView;
    
    BilingualLabel *welcomeLabel = [[BilingualLabel alloc] initWithTextEnglish:@"Welcome" polish:@"Witamy"];
    welcomeLabel.textColor = [UIColor whiteColor];
    welcomeLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:36];
    welcomeLabel.frame = (CGRect){ .origin = CGPointZero, .size = CGSizeZero };
    welcomeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [welcomeLabel sizeToFit];
    [welcomeView addSubview:welcomeLabel];
    self.welcomeLabel = welcomeLabel;
    
    UITextView *welcomeTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(welcomeLabel.frame) + [AppDelegate largeSpace], self.contentBounds.width, 0.0f)];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        welcomeTextView.text = @"Witamy w “US Embassy Mobile” Departamentu Stanu Stanów Zjednoczonych Ameryki – Twoim źródle informacji konsularnej z Ambasady USA w Warszawie, Konsulatu w Krakowie oraz Agencji Konsularnej w Poznaniu. Przygotowaliśmy ją tak, by umożliwić łatwe i szybkie znalezienie odpowiedzi na pytania związane z wizami, zapewnić pomoc obywatelom Stanów Zjednoczonych mieszkającym lub przebywającym w Polsce, a także dostarczać najświeższych wiadomości z konta Ambasady na Twitterze. Odpowiedzi na Twoje pytania - tu i teraz.\n\nPrzesuń w lewo aby zaakceptować warunki użytkowania";
    }
    else {
        welcomeTextView.text = @"Welcome to the U.S. Department of State’s “US Embassy Mobile”! This is your source of all consular information for the U.S. Embassy Warsaw, the U.S. Consulate Krakow and Consular Agency Poznan. It is designed to help you quickly and easily find answers to your visa questions, provide assistance to both resident and visiting U.S. citizens, and supply you with the latest U.S news from the Embassy news feed and twitter account. Get your answers right here, right now.\n\nPlease swipe to the left to accept terms and conditions";
    }
    
    welcomeTextView.backgroundColor = [UIColor clearColor];
    welcomeTextView.textColor = [UIColor whiteColor];
    welcomeTextView.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)];
    welcomeTextView.editable = NO;
    if ([welcomeTextView respondsToSelector:@selector(setSelectable:)]) {
        welcomeTextView.selectable = NO;
    }
    welcomeTextView.delegate = self;
    [welcomeView addSubview:welcomeTextView];
    self.welcomeTextView = welcomeTextView;
    
    return welcomeView;
}

- (UIView *)createTermsConditionsView
{
    UIView *termsConditionsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.termsConditionsView = termsConditionsView;
    
    UITextView *termsInfoView = [[UITextView alloc] initWithFrame:(CGRect){ .origin = CGPointZero, .size = self.contentBounds }];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        NSMutableAttributedString *termsFullText = [[NSMutableAttributedString alloc] initWithString:@"Aby kontynuować, należy wybrać „Akceptuję”\n\n" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 17 : 20)]}];
        
        NSAttributedString *termsTextPart = [[NSAttributedString alloc] initWithString:@"Oświadczenie o prywatności" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_BOLD size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 22 : 28)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"\n\nNie zbieramy żadnych państwa danych osobowych (PII), kiedy odwiedzacie państwo naszą stronę internetową, jeśli sami nie zdecydujecie się państwo ich nam przekazywać. Przekazywanie informacji umożliwiających identyfikację osób (PII) poprzez naszą stronę internetową jest dobrowolne, a dokonując tego, wyrażacie państwo zgodę na wykorzystanie informacji w określonym celu. Nieprzekazanie pewnych informacji może skutkować brakiem możliwości świadczenia przez nas usług, jakimi mogą być państwo zainteresowani. Jeśli wybiorą państwo opcję przekazania informacji PII stronie Departamentu Stany USA np. poprzez wypełnienie formularza internetowego lub wysłanie do nas maila, wykorzystamy te informacje do tego, by dostarczyć wymagane przez państwa informacje lub usługę lub do udzielenia odpowiedzi. Rodzaje informacji, jakie możemy od państwa dostawać, zależą od tego, co państwo robicie, gdy odwiedzacie naszą stronę.\nNatomiast automatycznie zbierane są i przechowywane nazwy domen, z których następuje połączenie z Internetem (.com, .edu, itp.); data i czas korzystania z naszej strony oraz adres internetowy strony, poprzez którą weszli państwo na nasze strony (np. wyszukiwarki lub strony linkującej). Zebrane informacje wykorzystujemy w celach statystycznych, aby określić ilość osób odwiedzających poszczególne podstrony na naszej stronie oraz po to, by uczynić ją bardziej użyteczną dla państwa.\n\n" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"Jeśli wysyłacie państwo do nas e-mail" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_BOLD size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"\nMogą się państwo zdecydować na przesłanie nam swoich danych osobowych, np. w e-mailu z komentarzem lub pytaniem. Wykorzystujemy te informacje w celu poprawienia świadczonych państwu usług lub by odpowiedzieć na państwa prośbę. Czasami przesyłamy państwa e-mail innym agencjom rządu amerykańskiego, które mogą lepiej państwu pomóc. Z wyjątkiem nakazanych prawem dochodzeń nie przekazujemy naszych e-maili żadnym innym organizacjom zewnętrznym.\n\n" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"Strony internetowe i aplikacje stron trzecich" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_BOLD size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"\nZamieszczamy linki do serwisów społecznościowych i innych rodzajów witryn stron trzecich. Wykorzystujemy strony serwisów społecznościowych do kontaktu z zagranicznymi użytkownikami oraz by prowadzić działania w ramach dyplomacji publicznej na całym świecie. Serwisy społecznościowe są wykorzystywane do informowania o organizowanych przez ambasadę wydarzeniach i do nawiązywania kontaktu z użytkownikami. Korzystamy również z technologii do pomiaru i dostosowania do użytkowników, by mierzyć liczbę osób odwiedzających nasze strony i podstrony, a także by uczynić nasze strony bardziej pożytecznymi dla użytkowników. W niektórych przypadkach aplikacje stron trzecich mogą wymagać podania adresu e-mailowego, nazwy użytkownika, hasła czy lokalizacji geograficznej w celu zarejestrowania konta. Nie wykorzystujemy stron internetowych stron trzecich do uzyskiwania ani zbierania informacji PII od użytkowników. Nie gromadzimy i nie przechowujemy żadnych umożliwiających identyfikację informacji zebranych przez jakiekolwiek witryny stron trzecich, żadne informacje PII nie będą ujawniane, sprzedawane czy przekazywane jakiemukolwiek podmiotowi poza Departamentem Stanu, z wyjątkiem przypadków zaistnienia takiego wymogu w ramach stosowania prawa przez organy ścigania lub w związku z realizacją aktu prawnego.\nMożemy przeprowadzać różnego rodzaju ankiety internetowe w celu zebrania opinii i komentarzy od losowo wybranej grupy użytkowników. Przede wszystkim Departament Stanu na bieżąco korzysta z internetowej ankiety ForeSee Results American Customer Satisfaction Index (ACSI) w celu uzyskania ocen oraz danych dot. zadowolenia użytkowników odwiedzających nasze strony. Ankieta ta nie gromadzi danych PII. Losowo wybranej grupie użytkowników wyświetla się zaproszenie do wzięcia udziału w badaniu, jednakże jest ono opcjonalne i nie na wszystkich stronach ambasady jest przeprowadzane. Jeśli nie zechcą państwo wziąć udziału w ankiecie, nadal będziecie państwo mieli dostęp do identycznych informacji i zasobów na naszej stronie – takich samych, do jakich dostęp mają użytkownicy biorący udział w ankiecie. Raporty z ankiet są widoczne tylko dla administratorów sieci i innych pracowników, którzy potrzebują tego rodzaju informacji do wykonywania swoich obowiązków. Możemy korzystać również z innych ograniczonych czasowo ankiet przygotowanych do określonych celów, wyszczególnionych w momencie zamieszczenia ich na stronie.\n\n" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"Linki do stron zewnętrznych" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_BOLD size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"\nNa naszej stronie znajduje się dużo linków do innych amerykańskich agencji, ambasad, organizacji międzynarodowych i prywatnych, zarówno w Stanach Zjednoczonych, jak i w innych krajach. Jeśli przechodzą państwo za pomocą tych linków na inne strony, wychodzą państwo z naszej strony, a na innych odwiedzanych stronach podlegają państwo zasadom prywatności tychże innych stron.\nDokładamy wszelkich starań, aby dostarczyć państwu dokładnych i wyczerpujących informacji. Jednakże nie możemy zagwarantować, że nie pojawią się żadne błędy. W odniesieniu do dokumentów i informacji dostępnych na niniejszej stronie internetowej ani ambasada, ani stali lub kontraktowi pracownicy nie udzielają żadnych gwarancji - wyraźnych bądź dorozumianych – włączywszy w to gwarancje przydatności handlowej lub przydatności do określonego celu. Ponadto ambasada nie ponosi odpowiedzialności prawnej za dokładność, wyczerpujący charakter czy przydatność jakichkolwiek informacji, produktów lub procesów wspomnianych na niniejszych stronach i nie stanowi, że wykorzystanie takich informacji, produktów lub procesów nie naruszałoby prywatnych praw.\nZe względu na bezpieczeństwo strony oraz aby zapewnić dostępność usługi dla wszystkich użytkowników Departament Stanu korzysta z programów monitorujących ruch na stronie w celu identyfikacji nieuprawnionych prób załadowania lub zmienienia informacji lub wyrządzenia innych szkód. Nieuprawnione próby załadowania informacji lub zmiany informacji w tym serwisie są ściśle zakazane i mogą być karalne na mocy ustawy Computer Fraud and Abuse Act z 1986 r. Informacje mogą być wykorzystywane w przypadku nakazanych prawem dochodzeń. Z wyjątkiem wyżej wymienionych przypadków nie są podejmowane żadne inne próby w celu zidentyfikowania poszczególnych użytkowników lub ich zwyczajów korzystania ze strony. Nieupoważnione próby załadowania informacji i/lub zmiany informacji na tej stronie są ściśle zakazane i podlegają ściganiu na mocy ustawy Computer Fraud and Abuse Act z 1986 roku oraz Title 18 U.S.C. Sec.1001 i 1030." attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        
        termsInfoView.attributedText = termsFullText;
    }
    else {
        NSMutableAttributedString *termsFullText = [[NSMutableAttributedString alloc] initWithString:@"To continue using the app please read the Terms & Conditions below and press Accept\n\n" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 17 : 20)]}];
        
        NSAttributedString *termsTextPart = [[NSAttributedString alloc] initWithString:@"Privacy Statement" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_BOLD size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 22 : 28)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"\n\nWe collect no personal information (PII) about you when you visit our site unless you choose to provide this information to us. Submitting personally identifiable information through our website is voluntary, but by doing so, you are giving your permission to use the information for the stated purpose. Not providing certain information may result in our inability to provide you with a service you desire. If you choose to provide us with PII on a Department website, through such methods as completing a web form or sending us an email, we will use that information to help us provide you the information or service you have requested or to respond to your message. The information we may receive from you varies based on what you do when visiting our site.\nWe do automatically collect and store the name of the domain from which you access the Internet (.com, .edu, etc.); the date and time you access our site; and the Internet address of the website (such as a search engine or referring page) from which you reached our site. We use the information we collect to count the number of visitors to the different pages on our site, and to help us make our site more useful to visitors like you.\n\n" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"If You Send Us Feedback" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_BOLD size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"\nYou may choose to provide us with personal information via our feedback capability. We use the information to improve our service to you or to respond to your request. Sometimes we forward your e-mail to other U.S. government agencies who may be better able to help you. Except for authorized law enforcement investigations, we do not share our e-mail with any other outside organizations.\n\n" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"Third-Party Websites and Applications" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_BOLD size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"\nWe link to social networking and other kinds of third-party websites. We use social networking websites to interact with the foreign audiences and to engage in public diplomacy worldwide. Social networking websites are used to publicize embassy events, and engage with members of the public. We also use web measurement and customization technologies to measure the number of visitors to our websites and their various sections and to help make our websites more useful to visitors. In some cases, the third-party application may request an email address, username, password, and geographic location for account registration purposes. We do not use third-party websites to solicit and collect PII from individuals. We do not collect or store any PII collected by any third-party website, and no PII will be disclosed, sold or transferred to any other entity outside the Department of State, unless required for law enforcement purposes or by statute.\nWe may use various types of online surveys to collect opinions and feedback from a random sample of visitors. Primarily, the State Department uses the ForeSee Results American Customer Satisfaction Index (ACSI) online survey on an ongoing basis to obtain feedback and data on visitor satisfaction with our websites. This survey does not collect PII. Although the survey invitation pops up for a random sample of visitors, it is optional, and not all embassy websites carry the survey. If you decline the survey, you will still have access to the identical information and resources at our site as those who do take the survey. The survey reports are available only to web managers and other designated staff who require this information to perform their duties. We may use other limited-time surveys for specific purposes, which are explained at the time they are posted.\n\n" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"Links to External Websites" attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_BOLD size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        termsTextPart = [[NSAttributedString alloc] initWithString:@"\nOur app may have links to other U.S. agencies, embassies, multilateral organizations, and private organizations in both the United States and other nations. When you follow a link and visit a website, you are no longer in our app and are subject to the privacy policy of the web site.\nEvery effort is made to provide accurate and complete information. However, we cannot guarantee that there will be no errors. With respect to documents and information on this app, neither the embassy nor its employees or contractors make any warranty, expressed or implied, including the warranties of merchantability and fitness for a particular purpose with respect to documents available from this app. Additionally, the embassy assumes no legal liability for the accuracy, completeness, or usefulness of any information, product, or process disclosed herein and does not represent that use of such information, product, or process would not infringe on privately owned rights.\nFor app security purposes and to ensure that this service remains available to all users, this app may use software programs to monitor usage traffic to identify unauthorized attempts to upload or change information or otherwise cause damage. Unauthorized attempts to upload information or change information on this service are strictly prohibited and may be punishable under the Computer Fraud and Abuse Act of 1986. Information also may be used for authorized law enforcement investigations. Except for the above purposes, no other attempts are made to identify individual users or their usage habits. Unauthorized attempts to upload information and/or change information on these web sites are strictly prohibited and are subject to prosecution under the Computer Fraud and Abuse Act of 1986 and Title 18 U.S.C. Sec.1001 and 1030." attributes:@{NSFontAttributeName : [UIFont fontWithName:DEFAULT_FONT_REGULAR size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 14 : 18)]}];
        [termsFullText appendAttributedString:termsTextPart];
        
        
        termsInfoView.attributedText = termsFullText;
        
    }
    
    termsInfoView.backgroundColor = [UIColor clearColor];
    termsInfoView.textColor = [UIColor whiteColor];
    termsInfoView.editable = NO;
    if ([termsInfoView respondsToSelector:@selector(setSelectable:)]) {
        termsInfoView.selectable = NO;
    }
    termsInfoView.delegate = self;
    [termsConditionsView addSubview:termsInfoView];
    self.termsInfoView = termsInfoView;
    
    UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectZero];
    acceptButton.backgroundColor = [UIColor whiteColor];
    acceptButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [acceptButton setTitleColor:CustomUSAppBlueColor forState:UIControlStateNormal];
    [acceptButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        [acceptButton setTitle:@"Akceptuję" forState:UIControlStateNormal];
    }
    else {
        [acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
    }
    [acceptButton addTarget:self action:@selector(didTapAcceptButton:) forControlEvents:UIControlEventTouchUpInside];
    [termsConditionsView addSubview:acceptButton];
    acceptButton.enabled = NO;
    self.acceptButton = acceptButton;
    
    
    return termsConditionsView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.welcomeTextView setFrame:(CGRect){ .origin = CGPointMake(0.0f, CGRectGetMaxY(self.welcomeLabel.frame)), .size = CGSizeMake(self.contentBounds.width, self.contentBounds.height - self.welcomeLabel.frame.size.height - [AppDelegate largeSpace]) }];
    
    CGFloat acceptButtonHeight = 40.0f;
    [self.termsInfoView setFrame:(CGRect){ .origin = CGPointZero, .size = CGSizeMake(self.contentBounds.width, self.contentBounds.height - acceptButtonHeight - [AppDelegate largeSpace]) }];
    [self.acceptButton setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.termsInfoView.frame) + [AppDelegate largeSpace], 234.0f, acceptButtonHeight)];
    [self.acceptButton setCenter:CGPointMake(self.acceptButton.superview.frame.size.width/2, self.acceptButton.center.y)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    if (!CGSizeEqualToSize(self.termsInfoView.frame.size, CGSizeZero) && !CGSizeEqualToSize(self.termsInfoView.contentSize, CGSizeZero)) {
        if (self.termsInfoView.frame.size.height + self.termsInfoView.contentOffset.y >= self.termsInfoView.contentSize.height) {
            self.acceptButton.enabled = YES;
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.slidingViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.slidingViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUpdateInProgressIndicator) name:POST_NOTIFICATION_DID_START_DATABASE_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideUpdateInProgressIndicator) name:POST_NOTIFICATION_DID_END_DATABASE_UPDATE object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POST_NOTIFICATION_DID_START_DATABASE_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POST_NOTIFICATION_DID_END_DATABASE_UPDATE object:nil];
}

- (void)showUpdateInProgressIndicator {
    self.updatingLabel = [[BilingualLabel alloc] initWithTextEnglish:@"Updating..." polish:@"Aktualizuję..."];
    self.updatingLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.updatingLabel.textAlignment = NSTextAlignmentCenter;
    self.updatingLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:36];
    self.updatingLabel.textColor = [UIColor whiteColor];
    self.updatingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.updatingLabel.frame = self.view.bounds;
    [self.view addSubview:self.updatingLabel];
}

- (void)hideUpdateInProgressIndicator {
    [self.updatingLabel removeFromSuperview];
    self.updatingLabel = nil;
}

#pragma mark - Actions

- (IBAction)didTapAcceptButton:(id)sender
{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:@"appVersion"];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.logoView.frame = CGRectMake(self.view.bounds.size.width/2 - 27, [[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending ? 23 : 3, 54, 54);
    }completion:^(BOOL finished){
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
}

@end
