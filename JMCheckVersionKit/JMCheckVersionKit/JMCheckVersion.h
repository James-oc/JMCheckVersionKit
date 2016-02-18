//
//  JMCheckVersionTool.h
//  JMCheckVersion
//
//  Created by james on 15/2/10.
//  Copyright (c) 2015年 james. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JMCheckVersionAlertType) {
    JMCheckVersionAlertTypeWithForce,  // Forces user to update your app (1 button alert)
    JMCheckVersionAlertTypeWithOption, // (DEFAULT) Presents user with option to update app now or at next launch (2 button alert)
    JMCheckVersionAlertTypeWithSkip,   // Presents user with option to update the app now, at next launch, or to skip this version all together (3 button alert)
    JMCheckVersionAlertTypeWithNone    // Doesn't show the alert, but instead returns a localized message for use in a custom UI within the sirenDidDetectNewVersionWithoutAlert() delegate method
};

typedef NS_ENUM(NSInteger, JMCheckVersionType) {
    JMCheckVersionTypeWithImmediately = 0,  // Version check performed every time the app is launched
    JMCheckVersionTypeWithDaily = 1,        // Version check performed once a day
    JMCheckVersionTypeWithWeekly = 7        // Version check performed once a week
};

typedef NS_ENUM(NSInteger, JMLanguageType) {
     Default,           // 默认跟系统语言一致（中英文两种）
     Basque ,
     ChineseSimplified ,
     ChineseTraditional ,
     Danish ,
     Dutch  ,
     English,
     French ,
     Hebrew ,
     German ,
     Italian,
     Japanese,
     Korean ,
     Portuguese,
     Russian,
     Slovenian,
     Spanish,
     Swedish,
     Turkish
};

@interface JMCheckVersion : NSObject<UIAlertViewDelegate>

/**
 *@description Initialization
 */
+(instancetype) sharedInstace;

/**
 *@description Check Version
 */
-(void) checkVersion:(JMCheckVersionType) checkType;

/**
 *@description The App Store / iTunes Connect ID for your app.
 */
@property (nonatomic,strong) NSString *appId;

/**
 *@description The view controller that will present the instance of UIAlertController.
 */
@property (nonatomic,strong) UIViewController *presentingViewController;

/**
 *@description The debug flag, which is disabled by default.
 *When enabled, a stream of println() statements are logged to your console when a version check is performed.
 */
@property (nonatomic,assign) BOOL debugEnabled;

/**
 *@description Determines the type of alert that should be shown.
 *See the JMCheckVersionAlertType enum for full details.
 */
@property (nonatomic,assign) JMCheckVersionAlertType alertType;

/**
 *@description Determines the type of alert that should be shown.
 *See the JMCheckVersionAlertType enum for full details.
 */
@property (nonatomic,strong) NSString *countryCode;

/**
 *@description Language set
 */
@property (nonatomic,assign) JMLanguageType forceLanguageLocalization;

/**
 *@description Available Message Title
 */
@property (nonatomic,strong) NSString *availableMessageTitle;

/**
 *@description New Version Message
 * Like this: A new version of %@ is available. Please update to version %@ now.
 */
@property (nonatomic,strong) NSString *versionMessage;

/**
 *@description Updating Button Title
 */
@property (nonatomic,strong) NSString *updatingButtonTitle;

/**
 *@description next Time Button Title
 */
@property (nonatomic,strong) NSString *nextTimeButtonTitle;

/**
 *@description Skip Button Title
 */
@property (nonatomic,strong) NSString *skippingButtonTitle;

/**
 *@description Update URL
 */
@property (nonatomic,strong) NSString *updateURL;

@end

