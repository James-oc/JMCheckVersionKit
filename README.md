# JMCheckVersionKit
### 当用户的应用程序有新版本可用时,通知他们到App Store更新。
---
## 特性
- [x] 支持 `UIAlertController` (iOS 8+) 和 `UIAlertView` (iOS 7)
- [x] 18种语言本地化 (看 **本地化** 部分)
- [x] 三种类型的警告弹出框 (看 **截图** 部分)
- [x] 可选 Block (看 **可选 Block(没有警告提示更新)** 部分)

## 截图

- **左边截图** 强制用户更新应用。
- **中间截图** 给用户更新应用程序的选项。
- **右边截图** 让用户可以选择跳过当前的更新。

<img src="https://github.com/James-oc/JMShareSource/raw/master/screenshots/OC/JMCheckVersionKit/IMG_Force.jpg?raw=true"  height="480"> <img src="https://github.com/James-oc/JMShareSource/raw/master/screenshots/OC/JMCheckVersionKit/IMG_Option.jpg?raw=true" height="480"> <img src="https://github.com/James-oc/JMShareSource/raw/master/screenshots/OC/JMCheckVersionKit/IMG_Skip.jpg?raw=true" height="480">

## 安装
1. 将项目中的JMCheckVersionKit文件夹以及JMCheckVersion.bundle拉入自己的工程项目里面。
2. #import "JMCheckVersionKit.h"并开始代码编写。

## 用CocoaPods安装
CocoaPods是OSX和iOS下的一个第三类库管理工具,如果你还未安装请先查看[**CocoaPods安装和使用教程**](http://code4app.com/article/cocoapods-install-usage)

## Podfile
```OC
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '6.0'

pod 'JMCheckVersionKit', '~> 1.0.0'
```
执行命令
```OC
$ pod install
```
## 代码
以下是示例参考代码：

```OC
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // JMCheckVersion is a singleton
    JMCheckVersion *tool = [JMCheckVersion sharedInstace];
    
    // Required: Your app's iTunes App Store ID
    tool.appId = <#Your_App_ID#>;
    
    // Optional: Your app's iTunes App Store URL
    tool.updateURL = <#Your_App_URL#>;
    
    // Required: AlertView display position 
    tool.presentingViewController = <#Your_App_Controller#>;

    /*
        Replace JMCheckVersionTypeWithImmediately with JMCheckVersionTypeWithDaily or JMCheckVersionTypeWithWeekly to specify a maximum         daily or weekly frequency for version
        checks.
    */
    [tool checkVersion:JMCheckVersionTypeWithImmediately];
    
    return YES;
}
```
## 本地化
这里支持的语言有： Arabic, Armenian, Basque, Chinese (Simplified), Chinese (Traditional), Danish, Dutch, English, Estonian, French, German, Hebrew, Hungarian, Italian, Japanese, Korean, Latvian, Lithuanian, Malay, Polish, Portuguese (Brazil), Portuguese (Portugal), Russian, Slovenian, Swedish, Spanish, Thai, and Turkish

您可以这样调用:

```OC
[JMCheckVersion sharedInstace].forceLanguageLocalization = <#JMLanguageType_Enum_Value#>
```
## 可选 Block(没有警告提示更新)

你如果要禁用警告框，你可以遵照以下设置:
```OC
[JMCheckVersion sharedInstace].alertType = JMCheckVersionAlertTypeWithNone;
[JMCheckVersion sharedInstace].didDetectNewVersionWithoutAlert = ^(NSString *newMessage) {
    NSLog(@"%@",newMessage);
};
```
## 应用程序商店提交
当应用程序商店的应用版本号比当前设备安装的应用版本号大时才会提示更新，所以App Store审核人员将看不到警告。

## 作者
James.xiao

