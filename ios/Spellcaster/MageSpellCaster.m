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
 *  For M.A.G.E
 *
 *  Author      : Ally Ogilvie | aogilvie@wizcorp.jp
 *  File        : MageSpellCaster.m
 *  Copyright   : Wizcorp 2013
 */

#import "MageSpellCaster.h"

// Max retries per network connection check
#define maxRetry 3;
static int currentRetry = 0;

@implementation MageSpellCaster

@synthesize cordovaController, networkMagic;

- (void)init:(CDVViewController *)viewController {

    cordovaController = viewController;

    // Initialize NetworkMagic
    networkMagic = [MageReachability reachabilityWithHostname:@"www.google.com"];

    // We DON'T want to be reachable on 3G/EDGE/CDMA
    networkMagic.reachableOnWWAN = YES;

    // Create weak references for access inside the block
    __block MageReachability *__networkMagic = networkMagic;
    __block MageSpellCaster *__spellcaster = self;

    networkMagic.reachableBlock = ^(MageReachability *network) {
        NSLog(@"Winds of magic are flowing all around us...");
        // Stop listening to network notification event now
        [__networkMagic stopNotifier];
        [__spellcaster parseConfig];

    };
    networkMagic.unreachableBlock = ^(MageReachability *network) {
        NSLog(@"This place has no magical powers...");
        // Apple may automatically display a localised network connectivity error message
        // if UIRequiresPersistentWiFi is set in info.plist.
        // Good news is MageReachability is eventy so reachableBlock will fire
        // when we are finally back online.
    };

    // Start Monitoring
    [networkMagic startNotifier];
}

- (void)parseConfig {
    // Download loader from M.A.G.E.

    // Get application server from config.xml
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];

    NSString *filePath = [NSString stringWithFormat:@"%@/config.xml", bundlePath];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
    [parser parse];
}

- (void)downloadAndBoot:(NSString *)path {
    // Path holds M.A.G.E. loader path
    NSURL *url = [NSURL URLWithString:path];
    NSData *urlData = [NSData dataWithContentsOfURL:url];

    if (urlData) {
        // Path to cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];

        // Download data to /library/cache/loader.html
        NSString *filePath = [NSString stringWithFormat:@"%@/loader.html", cacheDirectory];
        [urlData writeToFile:filePath atomically:YES];

        // For debugging - NSLog(@"downloaded: %@", filePath);

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

        // Write to file
        [loaderString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];

        cordovaController.startPage = [NSString stringWithFormat:@"file:///%@", filePath];
        url = [[NSURL alloc] initFileURLWithPath:filePath isDirectory:FALSE];

        if (url) {
            // URL OK
            // For debugging - NSLog(@"URL OK");
        } else {
            // CRITICAL - URL is null or nil, meaning string could not be turned into a valid URL
            [NSException raise:@"<MAGE Spellcaster Critical Error>"
                        format:@"Provided config String for URL is not a real URL, check <content src= > in config.xml"];
        }

        [cordovaController.webView loadRequest:[NSURLRequest requestWithURL:url]];

    } else {
        // Failed to download
        int retries = maxRetry - currentRetry;
        if (retries != 0) {
            // Retry
            currentRetry = currentRetry + 1;
            [self downloadAndBoot:path];
        } else {
            // Reset retries
            currentRetry = 0;

            // 3rd retry, network might be down just after our start download
            // start listening to network notifications
            [networkMagic startNotifier];
        }
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // Parse through the xml doc
    if ([elementName isEqualToString:@"content"]) {
        if ([attributeDict objectForKey:@"src"]) {
            // For debug - NSLog(@"src= %@", [attributeDict objectForKey:@"src"]);
            // Got source, download and load it
            [self downloadAndBoot:[attributeDict objectForKey:@"src"]];
        } else {
            // Critical error, throw an exception
            [NSException raise:@"<MAGE Spellcaster Critical Error>" format:@"Missing <Content src= > element or property in config.xml."];
        }
    } else {
        // Content cannot fail to be created because Cordova CLI injects this into the config.xml
        // We _could_ check for this error but it would require fixing Cordova...
    }
}

@end