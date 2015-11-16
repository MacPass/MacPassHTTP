//
//  MPHSettingsViewController.m
//  MacPassHTTP
//
//  Created by Michael Starke on 11/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPHSettingsViewController.h"
#import "MPHMacPassHTTP.h"

@interface MPHSettingsViewController ()

@property (weak) IBOutlet NSButton *enableCheckButton;
@property (weak) IBOutlet NSTextField *portTextField;
@property (weak) IBOutlet NSButton *showMenuItemCheckButton;

@end

@implementation MPHSettingsViewController

- (NSBundle *)nibBundle {
  return [NSBundle bundleForClass:[self class]];
}

- (NSString *)nibName {
  return @"MacPassHTTPSettings";
}

- (void)awakeFromNib {
  static BOOL didAwake = NO;
  if(!didAwake) {
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    [self.enableCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:[NSString stringWithFormat:@"values.%@", kMPHSettingsKeyEnableHttpServer] options:nil];
    [self.portTextField bind:NSValueBinding toObject:defaultsController withKeyPath:[NSString stringWithFormat:@"values.%@", kMPHSettingsKeyHttpPort] options:nil];
    [self.showMenuItemCheckButton bind:NSValueBinding toObject:defaultsController withKeyPath:[NSString stringWithFormat:@"values.%@", kMPHSettingsKeyShowMenuItem] options:nil];
    didAwake = YES;
  }
}
@end
