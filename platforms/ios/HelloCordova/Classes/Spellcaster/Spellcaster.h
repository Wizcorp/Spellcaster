/*
 *
 *
 *
 *      ...                                        ..       ..                          .x+=:.        s
 *     88888hx    :                          x .d88"  x .d88"                          z`    ^%      :8
 *  d88888888888hxx   .d``                     5888R    5888R                              .   <k    .88                  .u    .
 *  8" ... `"*8888%`   @8Ne.   .u        .u     '888R    '888R         .         u        .@8Ned8"   :888ooo      .u     .d88B :@8c
 * !  "   ` .xnxx.     %8888:u@88N    ud8888.    888R     888R    .udR88N     us888u.   .@^%8888"  -*8888888   ud8888.  ="8888f8888r
 * X X   .H8888888%:    `888I  888. :888'8888.   888R     888R   <888'888k .@88 "8888" x88:  `)8b.   8888    :888'8888.   4888>'88"
 * X 'hn8888888*"   >    888I  888I d888 '88%"   888R     888R   9888 'Y"  9888  9888  8888N=*8888   8888    d888 '88%"   4888> '
 * X: `*88888%`     !    888I  888I 8888.+"      888R     888R   9888      9888  9888   %8"    R88   8888    8888.+"      4888>
 * '8h.. ``     ..x8>  uW888L  888' 8888L        888R     888R   9888      9888  9888    @8Wou 9%   .8888Lu= 8888L       .d888L .+
 *  `88888888888888f  '*88888Nu88P  '8888c. .+  .888B .  .888B . ?8888u../ 9888  9888  .888888P`    ^%888*   '8888c. .+  ^"8888*"
 *   '%8888888888*"   ~ '88888F`     "88888%    ^*888%   ^*888%   "8888P'  "888*""888" `   ^"F        'Y"     "88888%       "Y"
 *     ^"****""`        888 ^         "YP'       "%       "%       "P'     ^Y"   ^Y'                           "YP'
 *                      *8E
 *                      '8>
 *                       "
 *  For Cordova based applications
 *
 *  Author      : Ally Ogilvie | aogilvie@wizcorp.jp
 *  File        : Spellcaster.h
 *  Copyright   : Wizcorp 2013
 *
 *  Requirements: SystemConfiguration.framework
 */

#import <Foundation/Foundation.h>
#import <Cordova/CDVViewController.h>
#import <Cordova/CDVConfigParser.h>

@class CDVViewController;

@interface Spellcaster : NSObject <NSXMLParserDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) CDVViewController *cordovaController;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) NSTimer *timer;

/**
 * This method is our init used to start the native loader.
 *
 * @param viewController is our Cordova view controller we need to attach to for controlling the UIWebView
 *
 */
- (void)init:(CDVViewController *)viewController;

/**
* This method is used to create the XML parser for the config.xml file that is provided by Cordova.
* NSXMLParserDelegate must be set on MageSpellCaster Class to obtain the override methods for parsing.
*
*/
- (void)parseConfig;

/**
* This method contains simple download logic followed by load instruction to Cordova's UIWebView.
*
* @param path is string that will be used as the URL to download the loader from.
*
*/
- (void)downloadAndBoot:(NSString *)path;

/**
* This method is the selector for our retry timer.
*
* @param sender is additional information that was sent to the selector.
*
*/
- (void)onRetry:(id)sender;

/**
* This method is triggered in the event of a file write error.
*
* @param error as error.
* @param path is the location where write error occurred.
*
*/
- (void)onWriteError:(NSError *)error forPath:(NSString *)path;

/**
* This method is triggered in the event of a download error, usually caused by connectivity issues.
*
* @param error as error.
* @param path is the location where downloaded data was supposed to be stored.
*
*/
- (void)onDownloadError:(NSError *)error forPath:(NSString *)path;

/**
* This method is provided as-is from the NSXMLParserDelegate.
* For more information see;
* https://developer.apple.com/library/ios/documentation/Cocoa/Reference/NSXMLParserDelegate_Protocol/Reference/Reference.html.
*
*/
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
   attributes:(NSDictionary *)attributeDict;

@end