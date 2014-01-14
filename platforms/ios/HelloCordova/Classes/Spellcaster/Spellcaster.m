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
 *  File        : SpellCaster.m
 *  Copyright   : Wizcorp 2013
 */

#import "Spellcaster.h"

// Retry download time (seconds)
#define RETRY_TIME 2.0;

@implementation Spellcaster

@synthesize cordovaController, alertView, timer;

- (void)init:(CDVViewController *)viewController {
    // nil or assign our class-wide vars
    alertView = nil;
    timer = nil;
    cordovaController = viewController;

    // Get application loader from config.xml
    [self parseConfig];
}

- (void)parseConfig {
    // Get application loader from config.xml in main bundle
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [NSString stringWithFormat:@"%@/config.xml", bundlePath];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];

    // Assign this class as delegate for parsing
    [parser setDelegate:self];

    // Start parsing the xml
    [parser parse];
}

- (void)downloadAndBoot:(NSString *)path {
    // Check path is no empty
    if (path.length > 0) {
        NSURL *url = [NSURL URLWithString:path];
        NSData *urlData = [NSData dataWithContentsOfURL:url];

        if (urlData) {
            // Got data, build download location path
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cacheDirectory = [paths objectAtIndex:0];

            // Download data to /library/cache/loader.html
            NSString *filePath = [NSString stringWithFormat:@"%@/loader.html", cacheDirectory];

            NSError *error = nil;
            [urlData writeToFile:filePath options:NSDataWritingAtomic error:&error];
            if (error != nil) {
                // Handle error
                [self onWriteError:error forPath:path];
            } else {
                // For debugging
                // NSLog(@"downloaded: %@", filePath);

                // Get loader as string
                NSString *loaderString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
                NSString *bundlePath = [[NSBundle mainBundle] bundlePath];

                // Cordova scripts
                NSString *scriptTags = [NSString stringWithFormat:
                        @"<head>\n"
                         "    <script type=\"text/javascript\" charset=\"utf-8\" src=\"%@/www/cordova.js\"></script>\n"
                         "    <script type=\"text/javascript\" charset=\"utf-8\" src=\"%@/www/cordova_plugins.js\"></script>\n",
                        bundlePath, bundlePath];

                // Replace string
                loaderString = [loaderString stringByReplacingOccurrencesOfString:@"<head>"
                                                     withString:scriptTags
                                                        options:NSCaseInsensitiveSearch
                                                          range:NSMakeRange(0, [loaderString length])];

                // Write to file, reusing NSError object here
                [loaderString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                if (error != nil) {
                    [self onWriteError:error forPath:path];
                } else {
                    cordovaController.startPage = [NSString stringWithFormat:@"file:///%@", filePath];
                    url = [[NSURL alloc] initFileURLWithPath:filePath isDirectory:FALSE];

                    if (url) {
                        // URL OK
                        // For debugging - NSLog(@"URL OK");
                    } else {
                        // CRITICAL - URL is null or nil, meaning string could not be turned into a valid URL
                        [NSException raise:@"<Spellcaster Critical Error>"
                                    format:@"Provided config String for URL is not a real URL, check <content src= > in config.xml"];
                    }

                    if (alertView != nil) {
                        // Out popup is active, remove it
                        [alertView dismissWithClickedButtonIndex:0 animated:FALSE];
                    }
                    // Load loader into Cordova UIWebView
                    [cordovaController.webView loadRequest:[NSURLRequest requestWithURL:url]];
                }
            }
        } else {
            // Failed to download
            NSError *failDownloadError =
                    [[NSError alloc] initWithDomain:@"spellcaster"
                                               code:1
                                           userInfo:@{ @"description" : @"Failed to download the file because of connection issues." }];
            [self onDownloadError:failDownloadError forPath:path];
        }
    } else {
        // CRITICAL - path is incorrect length
        [NSException raise:@"<Spellcaster Critical Error>"
                    format:@"Path for content to download is incorrect length (0), check <content src= > in config.xml"];
    }
}

- (void)onRetry:(id)sender {
    NSString *path = [sender userInfo];
    timer = nil;
    [self downloadAndBoot:path];
}

- (void)onWriteError:(NSError *)error forPath:(NSString *)path {
    // Retry to download and write the file to disk
    float retryTime = RETRY_TIME;
    timer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(onRetry:) userInfo:path repeats:NO];
}

- (void)onDownloadError:(NSError *)error forPath:(NSString *)path {
    if (alertView == nil) {
        // If this is the first time we come here show our localized connection requirement popup

        NSString *message =
                NSLocalizedString(@"CONNECTION_MESSAGE", @"Internet access is not available, an internet connection is required.\nRetrying...");
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONNECTION_TITLE", @"Connection Required")
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
        [alertView show];
    }
    float retryTime = RETRY_TIME;
    timer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(onRetry:) userInfo:path repeats:NO];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
   attributes:(NSDictionary *)attributeDict {
    // Parse through the xml doc
    if ([elementName isEqualToString:@"content"]) {
        if ([attributeDict objectForKey:@"src"]) {
            // For debug -
            // NSLog(@"src=%@", [attributeDict objectForKey:@"src"]);
            // Got source, download and load it
            [self downloadAndBoot:[attributeDict objectForKey:@"src"]];
        } else {
            // Critical error, throw an exception
            [NSException raise:@"<Spellcaster Critical Error>" format:@"Missing <Content src= > element or property in config.xml."];
        }
    } else {
        // Content cannot fail to be created because Cordova CLI injects this into the config.xml
        // We _could_ check for this error but it would require fixing Cordova...
    }
}

@end