//
//  MPHMacPassHTTP.m
//  MacPassHTTP
//
//  Created by Michael Starke on 11/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPHMacPassHTTP.h"
#import "MPHSettingsViewController.h"
#import "MPHServerDelegate.h"
#import <KeePassHTTPKit/KeePassHTTPKit.h>


NSUInteger const kKeePassHTTPDefaultPort = 19455;

NSString *const kMPHSettingsKeyEnableHttpServer = @"MPHSettingsKeyEnableHttpServer";
NSString *const kMPHSettingsKeyShowMenuItem     = @"MPHSettingsKeyShowMenuItem";
NSString *const kMPHSettingsKeyHttpPort         = @"MPHSettingsKeyHttpPort";

@interface MPHMacPassHTTP ()

@property (strong) MPHSettingsViewController *settingsViewController;
@property (strong) KPHServer *server;
@property (strong) NSStatusItem *statusItem;
@property (strong) id<KPHDelegate> serverDelegate;

@property (nonatomic) BOOL enabled;
@property (nonatomic)  BOOL showStatusItem;
@property (nonatomic)  NSUInteger serverPort;

@end

@implementation MPHMacPassHTTP

@synthesize settingsViewController = _settingsViewController;

+ (void)initialize {
  [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kMPHSettingsKeyHttpPort : @(kKeePassHTTPDefaultPort),
                                                             kMPHSettingsKeyShowMenuItem : @YES,
                                                             kMPHSettingsKeyEnableHttpServer : @YES }];
}

- (instancetype)initWithPluginManager:(MPPluginManager *)manager {
  self = [super initWithPluginManager:manager];
  if(self) {
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *enableServerKeyPath = [NSString stringWithFormat:@"values.%@", kMPHSettingsKeyEnableHttpServer];
    NSString *showItemKeyPath = [NSString stringWithFormat:@"values.%@", kMPHSettingsKeyShowMenuItem];
    NSString *serverPortKeyPaht = [NSString stringWithFormat:@"values.%@", kMPHSettingsKeyHttpPort];
    [self bind:NSStringFromSelector(@selector(enabled)) toObject:defaultsController withKeyPath:enableServerKeyPath options:nil];
    [self bind:NSStringFromSelector(@selector(showStatusItem)) toObject:defaultsController withKeyPath:showItemKeyPath options:nil];
    [self bind:NSStringFromSelector(@selector(serverPort)) toObject:defaultsController withKeyPath:serverPortKeyPaht options:nil];
  }
  return self;
}

- (NSViewController *)settingsViewController {
  if(!_settingsViewController) {
    self.settingsViewController = [[MPHSettingsViewController alloc] init];
  }
  return _settingsViewController;
}

- (void)setSettingsViewController:(MPHSettingsViewController *)settingsViewController {
  _settingsViewController = settingsViewController;
}

- (void)setEnabled:(BOOL)enabled {
  if(_enabled == enabled)
    return; // NO changes
  _enabled = enabled;
  [self _updateServer];
}

- (void)setServerPort:(NSUInteger)serverPort {
  if(_serverPort != serverPort) {
    _serverPort = serverPort;
    [self _updateServer];
  }
}

- (void)setShowStatusItem:(BOOL)showStatusItem {
  if(_showStatusItem != showStatusItem) {
    _showStatusItem = showStatusItem;
    [self _updateStatusItem];
  }
}

- (void)_updateStatusItem {
  if(self.enabled && self.showStatusItem) {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[NSImage imageNamed:NSImageNameApplicationIcon]];
  }
  else if(self.statusItem) {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    self.statusItem = nil;
  }
}

- (void)_updateServer {
  if(self.enabled) {
    if(!self.server) {
      self.server = [[KPHServer alloc] init];
      if(!self.serverDelegate) {
        self.serverDelegate = [[MPHServerDelegate alloc] init];
      }
      self.server.delegate = self.serverDelegate;
    }
    
    if(![self.server startWithPort:self.serverPort])
      NSLog(@"Failed to start KeePassHttp server");
  }
  else {
    [self.server stop];
    self.server = nil;
  }
  [self _updateStatusItem];
}


@end
