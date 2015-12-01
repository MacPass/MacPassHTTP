//
//  MPHAssiciationRequestWindowController.m
//  MacPassHTTP
//
//  Created by Michael Starke on 27/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPHRequestAccessWindowController.h"

@interface MPHRequestAccessWindowController () <NSTextFieldDelegate>
@property (weak) IBOutlet NSTextField *messageTextField;
@property (weak) IBOutlet NSTextField *identifierTextField;
@property (weak) IBOutlet NSButton *allowButton;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) void(^completionHandler)(NSModalResponse response, NSString *identifier);

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

- (void)presentWindowForKey:(NSString *)key completionHandler:(void (^)(NSModalResponse, NSString *))handler {
  self.key = key;
  self.completionHandler = handler;
  [NSApp runModalForWindow:self.window];
}

- (void)windowDidLoad {
  [super windowDidLoad];
  
  NSBundle *bundle = [NSBundle bundleForClass:self.class];
  NSString *message = NSLocalizedStringFromTableInBundle(@"REQUEST_ACCESS_MESSAGE_%@", @"", bundle, @"Message shown when a new KeePassHTTP Client want's access to the database");

  self.identifierTextField.delegate = self;
  self.identifierTextField.stringValue = [NSUUID UUID].UUIDString;
  self.messageTextField.stringValue = [NSString stringWithFormat:message, self.key];
}

- (void)controlTextDidChange:(NSNotification *)obj {
  if(obj.object == self.identifierTextField) {
    self.allowButton.enabled = self.identifierTextField.stringValue.length > 0;
  }
}

- (IBAction)allow:(id)sender {
  if(self.completionHandler) {
    self.completionHandler(NSModalResponseContinue, self.identifierTextField.stringValue);
  }
  [self.window orderOut:self];
  [NSApp stopModalWithCode:NSModalResponseContinue];
}

- (IBAction)deny:(id)sender {
  if(self.completionHandler) {
    self.completionHandler(NSModalResponseAbort, self.identifierTextField.stringValue);
  }
  [self.window orderOut:self];
  [NSApp stopModalWithCode:NSModalResponseAbort];
}
@end
