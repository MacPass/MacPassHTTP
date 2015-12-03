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

@property (copy) NSString *requestKey;
@property (copy) void(^completionHandler)(MPHRequestResponse response, NSString *identifier);

- (IBAction)allow:(id)sender;
- (IBAction)deny:(id)sender;

@end

@implementation MPHRequestAccessWindowController

- (NSString *)windowNibName {
  return @"RequestAccessWindow";
}

- (NSString *)identifier {
  return self.identifierTextField.stringValue;
}

- (instancetype)initWithRequestKey:(NSString *)key completionHandler:(void (^)(MPHRequestResponse, NSString *))handler {
  self = [super initWithWindow:nil];
  if(self) {
    self.completionHandler = handler;
    self.requestKey = key;
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  
  NSBundle *bundle = [NSBundle bundleForClass:self.class];
  NSString *message = NSLocalizedStringFromTableInBundle(@"REQUEST_ACCESS_MESSAGE_%@", @"", bundle, @"Message shown when a new KeePassHTTP Client want's access to the database");
  
  self.identifierTextField.delegate = self;
  self.identifierTextField.stringValue = [NSUUID UUID].UUIDString;
  self.messageTextField.stringValue = [NSString stringWithFormat:message, self.requestKey];
  
}

- (void)controlTextDidChange:(NSNotification *)obj {
  if(obj.object == self.identifierTextField) {
    self.allowButton.enabled = self.identifierTextField.stringValue.length > 0;
  }
}

- (IBAction)allow:(id)sender {
  if(self.completionHandler) {
    self.completionHandler(MPHRequestResponseAllow, self.identifierTextField.stringValue);
  }
  [self dismissSheet:MPHRequestResponseAllow];
}

- (IBAction)deny:(id)sender {
  if(self.completionHandler) {
    self.completionHandler(MPHRequestResponseDeny, self.identifierTextField.stringValue);
  }
  [self dismissSheet:MPHRequestResponseDeny];
}
@end
