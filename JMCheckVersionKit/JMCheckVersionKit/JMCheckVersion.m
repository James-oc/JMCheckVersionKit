//
//  JMCheckVersionTool.m
//  JMCheckVersion
//
//  Created by james on 15/2/10.
//  Copyright (c) 2015年 james. All rights reserved.
//

#import "JMCheckVersion.h"

#define DefaultStoredVersionCheckDate @"Stored Date From Last Version Check"
#define DefaultSkippedVersion @"User Decided To Skip Version Update"
#define IS_IOS8    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
#define Store_URL(appId) [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@",appId]
#define CurrentInstalledVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define App_Name [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]

static JMCheckVersion *_sharedInstance;

@interface JMCheckVersion()
{
    NSDate      *_lastVersionCheckPerformedOnDate; // The last update time
    NSString    *_currentAppStoreVersion ;
    NSString    *_languageTypeString;
}
@end

@implementation JMCheckVersion

+ (instancetype)sharedInstace {
    if (_sharedInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedInstance = [[JMCheckVersion alloc] init];
        });
    }
    
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _lastVersionCheckPerformedOnDate = [[NSUserDefaults standardUserDefaults] objectForKey:DefaultStoredVersionCheckDate];
        _debugEnabled = NO;
        self.forceLanguageLocalization = ChineseSimplified;
    }
    
    return self;
}

#pragma mark - Check Version
- (void) checkVersion:(JMCheckVersionType)checkType {
    if (_appId == nil) {
        if (_debugEnabled) {
            NSLog(@"[JMCheckVersion] Please make sure that you have set 'appID' before calling checkVersion.");
        }
    }else if (IS_IOS8 && _presentingViewController == nil) {
        if (_debugEnabled) {
            NSLog(@"[JMCheckVersion] Please make sure that you have set 'presentingViewController' before calling checkVersion.");
        }
    }else {
        if (checkType == JMCheckVersionTypeWithImmediately) {
            [self performVersionCheck];
        }else {
            if (_lastVersionCheckPerformedOnDate != nil && ![_lastVersionCheckPerformedOnDate isEqual:@""]) {
                if ([self daysSinceLastVersionCheckDate] >= checkType) {
                    [self performVersionCheck];
                }
            }else {
                [self performVersionCheck];
            }
        }
    }
}

- (void)performVersionCheck {
    // send Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[self iTunesURLFromString]];
    [request setHTTPMethod:@"POST"];
    
    // receive data
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data != nil) {
            if (data.length > 0) {
                if (_debugEnabled) {
                    NSLog(@"[JMCheckVersion] JSON results: %@",data);
                }
                
                [self processVersionCheckResults:data];
            }else {
                if (_debugEnabled) {
                    NSLog(@"[JMCheckVersion] Error retrieving App Store data as no data was returned: %@",connectionError.localizedDescription);
                }
            }
        }else {
            if (self.debugEnabled) {
                NSLog(@"[JMCheckVersion] Error retrieving App Store data as data was nil: %@",connectionError.localizedDescription);
            }
        }
    }];
}

- (void)processVersionCheckResults:(NSData *)recervedData {
    [self storeVersionCheckDate];
    
    NSError *error = nil;
    // parsing data
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:recervedData
                                                        options:NSJSONReadingMutableLeaves
                                                          error:&error];
    NSArray *infoArray = [dic objectForKey:@"results"];
    
    if (infoArray != nil && infoArray.count != 0) {
        _currentAppStoreVersion = [[infoArray objectAtIndex:0] objectForKey:@"version"];
        if (_currentAppStoreVersion) {
            if (![_currentAppStoreVersion isEqualToString:CurrentInstalledVersion] && [_currentAppStoreVersion compare:CurrentInstalledVersion options:NSNumericSearch] == NSOrderedDescending) {
                [self showAlertIfCurrentAppStoreVersionNotSkipped];
            }else {
                if (_debugEnabled) {
                    NSLog(@"[JMCheckVersion] App Store version of app is newer");
                }
            }
        }else {
            if (_debugEnabled) {
                NSLog(@"[JMCheckVersion] Error retrieving App Store verson number as results[0] does not contain a 'version' key");
            }
        }
    }else {
        if (_debugEnabled) {
            NSLog(@"[JMCheckVersion] Error retrieving App Store verson number as results returns an empty NSArray");
        }
    }
}

#pragma mark - Language Type
/**
 *@description set Language
 *@return void
 */
- (void)setForceLanguageLocalization:(JMLanguageType)forceLanguageLocalization {
    _forceLanguageLocalization = forceLanguageLocalization;
    [self getLanguageTypeString:_forceLanguageLocalization];
}

- (void)getLanguageTypeString:(JMLanguageType)languageType {
    switch (languageType) {
        case Default:
        {
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSArray *languages = [def valueForKey:@"AppleLanguages"];
            
            if(languages != nil && languages.count != 0){
                // Get the current system language version (Chinese:zh-Hans,English:en)
                NSString *current = [languages objectAtIndex:0];
                
                if (_debugEnabled) {
                    NSLog(@"The current language:%@",current);
                }
                
                if ([current hasPrefix:@"zh"]) {
                    _languageTypeString = @"zh-Hans";
                }else {
                    _languageTypeString = @"en";
                }
            }else {
                _languageTypeString = @"en";
            }
        }
            break;
        case Basque:
            _languageTypeString = @"eu";
            break;
        case ChineseSimplified:
            _languageTypeString = @"zh-Hans";
            break;
        case ChineseTraditional:
            _languageTypeString = @"zh-Hant";
            break;
        case Danish:
            _languageTypeString = @"da";
            break;
        case Dutch:
            _languageTypeString = @"nl";
            break;
        case English:
            _languageTypeString = @"en";
            break;
        case French:
            _languageTypeString = @"fr";
            break;
        case Hebrew:
            _languageTypeString = @"he";
            break;
        case German:
            _languageTypeString = @"de";
            break;
        case Italian:
            _languageTypeString = @"it";
            break;
        case Japanese:
            _languageTypeString = @"ja";
            break;
        case Korean:
            _languageTypeString = @"ko";
            break;
        case Portuguese:
            _languageTypeString = @"pt";
            break;
        case Russian:
            _languageTypeString = @"ru";
            break;
        case Slovenian:
            _languageTypeString = @"sl";
            break;
        case Spanish:
            _languageTypeString = @"es";
            break;
        case Swedish:
            _languageTypeString = @"sv";
            break;
        case Turkish:
            _languageTypeString = @"tr";
            break;
        default:
            break;
    }
}

#pragma mark - NSBundle Extends
- (NSString *)getBundlePath {
    return [[NSBundle mainBundle] pathForResource:@"JMCheckVersion"
                                           ofType:@"bundle"];
}

- (NSString *)getForceBundlePath:(NSString *)languageTypeString {
    return [[NSBundle bundleWithPath:[self getBundlePath]] pathForResource:languageTypeString ofType:@"lproj"];
}

/**
 *@description language transfer
 *@return void
 */
- (NSString *)localizedString:(NSString *)stringKey withJMLanguageTypeString:(NSString *)languageTypeString {
    NSString *path = nil;
    NSString *table = @"CheckVersionLocalizable";
    
    if (languageTypeString) {
        path = [self getForceBundlePath:languageTypeString];
    }else {
        path = [self getBundlePath];
    }
    
    return [[NSBundle bundleWithPath:path] localizedStringForKey:stringKey value:stringKey table:table];
}

#pragma mark - Message Show
- (NSString *)localizedNewVersionMessage {
    NSString *newVersionMessageToLocalize = @"A new version of %@ is available. Please update to version %@ now.";
    if (_versionMessage != nil || [_versionMessage isEqualToString:@""]) {
        newVersionMessageToLocalize = _versionMessage;
    }
    NSString *newVersionMessage = [self localizedString:newVersionMessageToLocalize withJMLanguageTypeString:_languageTypeString];
    newVersionMessage = [NSString stringWithFormat:newVersionMessage,App_Name,_currentAppStoreVersion];
    
    return newVersionMessage;
}

- (NSString *)localizedUpdateButtonTitle {
    NSString *title = @"Update";
    if (_updatingButtonTitle != nil && ![_updatingButtonTitle isEqualToString:@""]) {
        title = _updatingButtonTitle;
    }
    
    return [self localizedString:title withJMLanguageTypeString:_languageTypeString];
}

- (NSString *)localizedNextTimeButtonTitle {
    NSString *title = @"Next time";
    if (_nextTimeButtonTitle != nil && ![_nextTimeButtonTitle isEqualToString:@""]) {
        title = _nextTimeButtonTitle;
    }
    
    return [self localizedString:title withJMLanguageTypeString:_languageTypeString];
}

- (NSString *)localizedSkipButtonTitle {
    NSString *title = @"Skip this version";
    if (_skippingButtonTitle != nil && ![_skippingButtonTitle isEqualToString:@""]) {
        title = _skippingButtonTitle;
    }
    
    return [self localizedString:title withJMLanguageTypeString:_languageTypeString];
}

#pragma mark - UIAlertAction
/**
 *@description User Decided To Skip Version Update
 *@return void
 */
- (void)showAlertIfCurrentAppStoreVersionNotSkipped {
    NSString *previouslySkippedVersion = [[NSUserDefaults standardUserDefaults] objectForKey:DefaultSkippedVersion];
    
    if (previouslySkippedVersion != nil && ![previouslySkippedVersion isEqualToString:@""]) {
        if (![previouslySkippedVersion isEqualToString:_currentAppStoreVersion]) {
            [self showAlert];
        }
    }else {
        [self showAlert];
    }
}

/**
 *@description alert view
 *@return void
 */
- (void)showAlert {
    NSString *updateAvailableMessage;
    
    if (_availableMessageTitle != nil || [_availableMessageTitle isEqualToString:@""]) {
        updateAvailableMessage = [self localizedString:_availableMessageTitle withJMLanguageTypeString:_languageTypeString];
    }else {
        updateAvailableMessage = [self localizedString:@"Update Available" withJMLanguageTypeString:_languageTypeString];
    }
    
    NSString *newVersionMessage = [self localizedNewVersionMessage];
    
    if (IS_IOS8) {
        // IOS 8
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:updateAvailableMessage
                                                                                 message:newVersionMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        switch (_alertType) {
            case JMCheckVersionAlertTypeWithForce:
                [alertController addAction:[self updateAlertAction]];
                break;
            case JMCheckVersionAlertTypeWithOption:
                [alertController addAction:[self nextTimeAlertAction]];
                [alertController addAction:[self updateAlertAction]];
                break;
            case JMCheckVersionAlertTypeWithSkip:
                [alertController addAction:[self nextTimeAlertAction]];
                [alertController addAction:[self updateAlertAction]];
                [alertController addAction:[self skipAlertAction]];
                break;
            case JMCheckVersionAlertTypeWithNone:
                if (_debugEnabled) {
                    NSLog(@"[JMCheckVersion] No alert presented due to alertType == JMCheckVersionAlertTypeWithNone");
                    if (_didDetectNewVersionWithoutAlert != nil) {
                        _didDetectNewVersionWithoutAlert(newVersionMessage);
                    }
                }
                break;
            default:
                break;
        }
        
        if (_alertType != JMCheckVersionAlertTypeWithNone) {
            [_presentingViewController presentViewController:alertController animated:YES completion:nil];
        }
    }else {
        // IOS 7
        UIAlertView *alertView;
        switch (_alertType) {
            case JMCheckVersionAlertTypeWithForce:
                alertView = [[UIAlertView alloc] initWithTitle:updateAvailableMessage
                                                       message:newVersionMessage
                                                      delegate:self
                                             cancelButtonTitle:[self localizedUpdateButtonTitle]
                                             otherButtonTitles:nil];
                break;
            case JMCheckVersionAlertTypeWithOption:
                alertView = [[UIAlertView alloc] initWithTitle:updateAvailableMessage
                                                       message:newVersionMessage
                                                      delegate:self
                                             cancelButtonTitle:[self localizedNextTimeButtonTitle]
                                             otherButtonTitles:nil];
                [alertView addButtonWithTitle:[self localizedUpdateButtonTitle]];
                break;
            case JMCheckVersionAlertTypeWithSkip:
                alertView = [[UIAlertView alloc] initWithTitle:updateAvailableMessage
                                                       message:newVersionMessage
                                                      delegate:self
                                             cancelButtonTitle:[self localizedSkipButtonTitle]
                                             otherButtonTitles:nil];
                [alertView addButtonWithTitle:[self localizedUpdateButtonTitle]];
                [alertView addButtonWithTitle:[self localizedNextTimeButtonTitle]];
                break;
            case JMCheckVersionAlertTypeWithNone:
                if (_debugEnabled) {
                    NSLog(@"[JMCheckVersion] No alert presented due to alertType == JMCheckVersionAlertTypeWithNone");
                    if (_didDetectNewVersionWithoutAlert != nil) {
                        _didDetectNewVersionWithoutAlert(newVersionMessage);
                    }
                }
                break;
            default:
                break;
        }
        
        if (alertView) {
            [alertView show];
        }
    }
}

- (void)launchAppStore {
    NSString *iTunesString = _updateURL ? :Store_URL(_appId);
    NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
    [[UIApplication sharedApplication] openURL:iTunesURL];
}

- (UIAlertAction *)updateAlertAction {
    NSString *title = [self localizedUpdateButtonTitle];
    UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self launchAppStore];
                                                       return ;
                                                   }];
    
    return action;
}

- (UIAlertAction *)nextTimeAlertAction {
    NSString *title = [self localizedNextTimeButtonTitle];
    UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       return ;
                                                   }];
    
    return action;
}

- (UIAlertAction *)skipAlertAction {
    NSString *title = [self localizedSkipButtonTitle];
    UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [[NSUserDefaults standardUserDefaults] setObject:_currentAppStoreVersion forKey:DefaultSkippedVersion];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       return ;
                                                   }];
    
    return action;
}

#pragma mark - Utils
/**
 *@description Number of days difference
 *@return NSInteger
 */
- (NSInteger)daysSinceLastVersionCheckDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:_lastVersionCheckPerformedOnDate toDate:[NSDate date] options:0];
    
    return components.day;
}

/**
 *@description set check version date
 *@return void
 */
- (void)storeVersionCheckDate {
    _lastVersionCheckPerformedOnDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:_lastVersionCheckPerformedOnDate forKey:DefaultStoredVersionCheckDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *@description get app store link
 *@return NSURL
 */
- (NSURL *)iTunesURLFromString {
    NSString *storeURLString = Store_URL(_appId);
    
    if (_countryCode) {
        [storeURLString stringByAppendingString:[NSString stringWithFormat:@"&country=%@",_countryCode]];
    }
    
    if (_debugEnabled) {
        NSLog(@"[JMCheckVersion] iTunes Lookup URL: %@",storeURLString);
    }
    
    return [NSURL URLWithString:storeURLString];
}

#pragma mark - UIAlertAction Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (_alertType) {
        case JMCheckVersionAlertTypeWithForce:
            [self launchAppStore];
            break;
        case JMCheckVersionAlertTypeWithOption:
            if (buttonIndex == 1) {
                [self launchAppStore];
            }
            break;
        case JMCheckVersionAlertTypeWithSkip:
            if (buttonIndex == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:_currentAppStoreVersion forKey:DefaultSkippedVersion];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else if (buttonIndex == 1) {
                [self launchAppStore];
            }else {
                
            }
            break;
        case JMCheckVersionAlertTypeWithNone:
            if (_debugEnabled) {
                NSLog(@"[JMCheckVersion] No alert presented due to alertType == JMCheckVersionAlertTypeWithNone");
            }
            break;
        default:
            break;
    }
}

@end


