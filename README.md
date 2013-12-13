
![image](logo.gif)



## About
---

SpellCaster for MAGE is a native loader to dynamically store and load a MAGE based application's dynamically generated loader file.

## Requirements
---

- Cordova v3.0+

## Install for iOS
---

#### Install

- Add SystemConfiguration.framework to your project. 
- Copy classes from `ios/` directory to your project.

#### Usage

- You are no longer required to include an index.html (removal is optional)
- Add `[[MageSpellCaster alloc] init:self.viewController];` to `- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions` method.
- Add your application URL to Cordova's `config.xml` in `<content src=YOUR_URL_HERE>`.

## How it works (step-by-step)
---

1. SpellCaster will check for an active internet connection.
2. SpellCaster downloads the content of the provided application URL and stores to application cache (overriding any existing loader).
3. SpellCaster injects Cordova script tags just the `<head>` tag.
4. SpellCaster loads the new loader into the WebView.

