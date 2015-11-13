//
//  MPHMacPassHTTP.m
//  MacPassHTTP
//
//  Created by Michael Starke on 11/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPHMacPassHTTP.h"
#import "MPHSettingsViewController.h"

@interface MPHMacPassHTTP ()
@property (strong) MPHSettingsViewController *vc;
@end

@implementation MPHMacPassHTTP

- (NSViewController *)settingsViewController {
  if(!self.vc) {
    self.vc = [[MPHSettingsViewController alloc] init];
  }
  return self.vc;
}

@end
