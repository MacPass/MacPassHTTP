//
//  MPHMacPassHTTP.h
//  MacPassHTTP
//
//  Created by Michael Starke on 11/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPPlugin.h"


FOUNDATION_EXPORT NSUInteger const kKeePassHTTPDefaultPort;

FOUNDATION_EXPORT NSString *const kMPHSettingsKeyShowMenuItem;
FOUNDATION_EXPORT NSString *const kMPHSettingsKeyHttpPort;
FOUNDATION_EXPORT NSString *const kMPHSettingsKeyShowNotifications;

@class MPHServerDelegate;

@interface MPHMacPassHTTP : MPPlugin <MPPluginSettings>

@property (strong,readonly) MPHServerDelegate *serverDelegate;

@end
