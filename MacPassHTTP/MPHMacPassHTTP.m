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

NSString *const kMPHSettingsKeyShowMenuItem           = @"MPHTTPSettingsKeyShowMenuItem";
NSString *const kMPHSettingsKeyHttpPort               = @"MPHTTPSettingsKeyHttpPort";
NSString *const kMPHSettingsKeyAllowRemoteConnections = @"MPHTTPSettingsKeyAllowRemoteConnections" ;
NSString *const kMPHSettingsKeyShowNotifications      = @"MPHTTPSettingsKeyShowNotifications";
NSString *const kMPHSettingsKeyIncludeRootDomain      = @"MPHTTPSettingsKeyIncludeRootDomain";
NSString *const kMPHSettingsKeyIncludeKPHStringFields = @"MPHSettingsKeyIncludeKPHStringFields";



@interface MPHMacPassHTTP ()

@property (strong) MPHSettingsViewController *settingsViewController;
@property (strong) KPHServer *server;
@property (strong) NSStatusItem *statusItem;
@property (strong) MPHServerDelegate *serverDelegate;

@property (nonatomic) BOOL showStatusItem;
@property (nonatomic) NSUInteger serverPort;
@property (nonatomic) BOOL allowRemoteConnection;

@end

@implementation MPHMacPassHTTP

@synthesize settingsViewController = _settingsViewController;

+ (void)initialize {
  [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kMPHSettingsKeyHttpPort : @(kKeePassHTTPDefaultPort),
                                                             kMPHSettingsKeyAllowRemoteConnections : @(NO),
                                                             kMPHSettingsKeyShowNotifications : @(YES),
                                                             kMPHSettingsKeyShowMenuItem : @YES,
                                                             kMPHSettingsKeyIncludeKPHStringFields: @NO,
                                                             kMPHSettingsKeyIncludeRootDomain: @NO }];
}

- (instancetype)initWithPluginHost:(MPPluginHost *)host {
  self = [super initWithPluginHost:host];
  if(self) {
    _showStatusItem = [[NSUserDefaults standardUserDefaults] boolForKey:kMPHSettingsKeyShowMenuItem];
    _serverPort = [[NSUserDefaults standardUserDefaults] integerForKey:kMPHSettingsKeyHttpPort];
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *showItemKeyPath = [NSString stringWithFormat:@"values.%@", kMPHSettingsKeyShowMenuItem];
    NSString *serverPortKeyPath = [NSString stringWithFormat:@"values.%@", kMPHSettingsKeyHttpPort];
    NSString *remoteConnectionKeyPath = [NSString stringWithFormat:@"values.%@", kMPHSettingsKeyAllowRemoteConnections];
    [self bind:NSStringFromSelector(@selector(showStatusItem)) toObject:defaultsController withKeyPath:showItemKeyPath options:nil];
    [self bind:NSStringFromSelector(@selector(serverPort)) toObject:defaultsController withKeyPath:serverPortKeyPath options:nil];
    [self bind:NSStringFromSelector(@selector(allowRemoteConnection)) toObject:defaultsController withKeyPath:remoteConnectionKeyPath options:nil];
    
    [self _startServer];
  }
  return self;
}

- (void)dealloc {
  [self unbind:NSStringFromSelector(@selector(showStatusItem))];
  [self unbind:NSStringFromSelector(@selector(serverPort))];
  [self willUnloadPlugin];
  NSLog(@"%@ dealloc", [self class]);
}

- (void)willUnloadPlugin {
  [self _stopServer];
  self.serverDelegate = nil;
}

- (NSViewController *)settingsViewController {
  if(!_settingsViewController) {
    self.settingsViewController = [[MPHSettingsViewController alloc] init];
    self.settingsViewController.plugin = self;
  }
  return _settingsViewController;
}

- (void)setSettingsViewController:(MPHSettingsViewController *)settingsViewController {
  _settingsViewController = settingsViewController;
}

- (void)setServerPort:(NSUInteger)serverPort {
  if(_serverPort != serverPort) {
    _serverPort = serverPort;
    [self _restartServer];
  }
}

- (void)setShowStatusItem:(BOOL)showStatusItem {
  if(_showStatusItem != showStatusItem) {
    _showStatusItem = showStatusItem;
    [self _updateStatusItem];
  }
}

- (void)setAllowRemoteConnection:(BOOL)allowRemoteConnection {
  if(_allowRemoteConnection != allowRemoteConnection) {
    _allowRemoteConnection = allowRemoteConnection;
    [self _restartServer];
  }
}

- (void)_updateStatusItem {
  if(self.showStatusItem) {
    if(!self.statusItem){
      self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
      self.statusItem.menu = [[NSMenu alloc] init];
      [self.statusItem.menu addItemWithTitle:@"STATUS" action:NULL keyEquivalent:@""];
      NSBundle *bdl = [NSBundle bundleForClass:self.class];
      NSImage *image = [bdl imageForResource:@"Lock"];
      //image.size = NSMakeSize(18, 18);
      self.statusItem.image = image;
    }
    NSBundle *myBundle = [NSBundle bundleForClass:self.class];
    NSString *okTitle = NSLocalizedStringFromTableInBundle(@"STATUS_SERVER_OK", @"", myBundle, "Item displayed when server is running!");
    NSString *errorTitle =  NSLocalizedStringFromTableInBundle(@"STATUS_SERVER_ERROR", @"", myBundle, "Item displayed when server failed to start!");
    self.statusItem.menu.itemArray.firstObject.title = self.server.isRunning ? okTitle : errorTitle;
  }
  else if(self.statusItem) {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    self.statusItem = nil;
  }
}
- (void)_startServer {
  if(!self.server) {
    self.server = [[KPHServer alloc] init];
    if(!self.serverDelegate) {
      self.serverDelegate = [[MPHServerDelegate alloc] init];
    }
    self.server.delegate = self.serverDelegate;
  }
  [self _restartServer];
}

- (void)_stopServer {
  [self.server stop];
  self.server = nil;
  [self _updateStatusItem];
}

- (void)_restartServer {
  NSError *error;
  if(![self.server startWithPort:self.serverPort bindToLocalhost:!self.allowRemoteConnection error:&error]) {
    NSLog(@"Unable to Start KeePassHTTP Server: %@", error.localizedDescription);
  }
  [self _updateStatusItem];
}


@end
