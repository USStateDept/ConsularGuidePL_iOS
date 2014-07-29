//
//  AGIYTVideoModel.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 12.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIYTVideoModel.h"
#import "XCDYouTubeVideoPlayerViewController.h"

@interface AGIYTVideoModel ()

@property (nonatomic, copy, readwrite) NSString *ytVideoID;

@end

@implementation AGIYTVideoModel

static NSString *const APIResponseYTVideoURL = @"yt_url";

- (instancetype)initWithJSON:(NSDictionary *)jsonFeed
{
    self = [super initWithJSON:jsonFeed];
    if (self)
    {
        self.ytVideoID = [[[jsonFeed objectForKey:APIResponseYTVideoURL] lastPathComponent] stringByReplacingOccurrencesOfString:@"watch?v=" withString:@""];
    }
    
    return self;
}

- (void)playVideoInViewController:(UIViewController *)viewController
{
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.ytVideoID];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [viewController presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *playbackError = [userInfo objectForKey:XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
    if (playbackError)
    {
        NSString *titleEn = @"YouTube Video Error";
        NSString *titlePl = @"Błąd wideo YouTube";
        NSString *localizedTitle = ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? titlePl : titleEn;
        
        NSString *msgEn = @"There was an error with playing selected video in our application. Would You like to see it on YouTube web page?";
        NSString *msgPl = @"Wybrane wideo nie może zostać wyświetlone w aplikacji. Czy chcesz je zobaczyć w przeglądarce na stronie youtube.com?";
        NSString *localizedMsg = ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? msgPl : msgEn;
        
        UIAlertView *videoErrorAlert = [[UIAlertView alloc] initWithTitle:localizedTitle
                                                                  message:localizedMsg
                                                                 delegate:self
                                                        cancelButtonTitle:([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? @"Nie" : @"No"
                                                        otherButtonTitles:([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? @"Tak" : @"Yes", nil];
        [videoErrorAlert show];
        
        NSLog(@"Youtube error: %@", playbackError);
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? @"Tak" : @"Yes"])
    {
        NSString *ytVideoPath = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", self.ytVideoID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ytVideoPath]];
    }
}

@end
