//
//  MPHAssiciationRequestWindowController.m
//  MacPassHTTP
//
//  Created by Michael Starke on 27/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPHRequestAccessWindowController.h"

@interface MPHRequestAccessWindowController ()
@property (weak) IBOutlet NSTextField *messageTextField;
@property (weak) IBOutlet NSTextField *identifierTextField;

- (IBAction)allow:(id)sender;
- (IBAction)deny:(id)sender;

@end

@implementation MPHRequestAccessWindowController

- (NSString *)windowNibName {
  return @"RequestAccessWindow";
}

- (NSString *)title {
  return self.identifierTextField.stringValue;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  self.identifierTextField.stringValue = self.title ? self.title : [NSUUID UUID].UUIDString;
}

- (IBAction)allow:(id)sender {
  if(self.completionBlock) {
    self.completionBlock(NSModalResponseContinue);
  }
  [self.window orderOut:self];
}

- (IBAction)deny:(id)sender {
  if(self.completionBlock) {
    self.completionBlock(NSModalResponseAbort);
  }
  [self.window orderOut:self];
}
@end
