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

@property (weak) IBOutlet NSTextField *portTextField;
@property (weak) IBOutlet NSButton *showMenuItemCheckButton;
@property (weak) IBOutlet NSButton *showNotificationsCheckButton;

@end

@implementation MPHSettingsViewController

- (void)dealloc {
  NSLog(@"%@ dealloc", [self class]);
  [self.portTextField unbind:NSValueBinding];
  [self.showMenuItemCheckButton unbind:NSValueBinding];
}

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
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.allowsFloats = NO;
    formatter.alwaysShowsDecimalSeparator = NO;
    self.portTextField.formatter = formatter;
    [self.portTextField bind:NSValueBinding
                    toObject:defaultsController
                 withKeyPath:[NSString stringWithFormat:@"values.%@", kMPHSettingsKeyHttpPort]
                     options:nil];
    [self.showMenuItemCheckButton bind:NSValueBinding
                              toObject:defaultsController
                           withKeyPath:[NSString stringWithFormat:@"values.%@", kMPHSettingsKeyShowMenuItem]
                               options:nil];
    [self.showNotificationsCheckButton bind:NSValueBinding
                                   toObject:defaultsController
                                withKeyPath:[NSString stringWithFormat:@"values.%@", kMPHSettingsKeyShowNotifications]
                                    options:nil];
    didAwake = YES;
  }
}
@end
