//
//  MPHServerDelegate.m
//  MacPassHTTP
//
//  Created by Michael Starke on 13/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import "MPHServerDelegate.h"
#import "MPHMacPassHTTP.h"
#import "MPHRequestAccessWindowController.h"

#import "MPDocument.h"
#import "NSString+MPPasswordCreation.h"

#import <KeePassKit/KeePassKit.h>

static NSUUID *_rootUUID = nil;

@interface MPHServerDelegate () <NSUserNotificationCenterDelegate>

@property (weak) MPDocument *queryDocument; // TODO: convert to list of documents to support more than one open document!
//@property (strong) NSHashTable *queryDocuments;
@property (nonatomic, weak) KPKEntry *configurationEntry;
@property (readonly) BOOL queryDocumentOpen;
@property (strong) MPHRequestAccessWindowController *requestController;


@end

@implementation MPHServerDelegate

- (instancetype)init {
  self = [super init];
  if(self)
  {
    static const uuid_t uuidBytes = {
      0x34, 0x69, 0x7a, 0x40, 0x8a, 0x5b, 0x41, 0xc0,
      0x9f, 0x36, 0x89, 0x7d, 0x62, 0x3e, 0xcb, 0x31
    };
    _rootUUID = [[NSUUID alloc] initWithUUIDBytes:uuidBytes];
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
    
  }
  return self;
}

- (void)clearKeys {
  if(!self.queryDocument) {
    return;
  }
  /* TODO History support */
  NSString *prefix = [NSString stringWithFormat:KPHAssociatKeyFormat, @"" ];
  for(KPKAttribute *attribute in self.configurationEntry.customAttributes) {
    if([attribute.key hasPrefix:prefix]) {
      /* push history to be a good citizen */
      [self.configurationEntry pushHistory];
      [self.configurationEntry removeCustomAttribute:attribute];
    }
  }
}

- (void)clearPermissions {
  if(!self.queryDocument) {
    return;
  }
  
  for(KPKEntry *entry in self.queryDocument.root.childEntries) {
    KPKAttribute *attribute = [entry customAttributeWithKey:KPHSettingsEntryName];
    if(attribute) {
      [entry pushHistory];
      [entry removeCustomAttribute:attribute];
    }
  }
}

- (BOOL)queryDocumentOpen {
  [self configurationEntry];
  return self.queryDocument && !self.queryDocument.encrypted;
}

- (KPKEntry *)configurationEntry {
  /* don't return the configurationEntry if it is isn't in the root group, we will move it there first */
  if(_configurationEntry != nil && [_configurationEntry.parent.uuid isEqual:_queryDocument.root.uuid]) {
    return  _configurationEntry;
  }
  
  
  NSArray *documents = [NSDocumentController sharedDocumentController].documents;
  
  MPDocument __weak *lastDocument;
  
  for(MPDocument *document in documents) {
    if(document.encrypted) {
      NSLog(@"Skipping locked Database: %@", document.displayName);
      /* TODO: Show input window and open db with window */
      continue;
    }
    
    lastDocument = document;
    
    KPKEntry *configEntry = [lastDocument findEntry:_rootUUID];
    if(nil != configEntry) {
      /* if the configEntry is not in the root group then move it there */
      if (![configEntry.parent.uuid isEqual:lastDocument.root.uuid]) {
        /* model updates only on main thread for UI safety */
        dispatch_semaphore_t sema = dispatch_semaphore_create(0L);
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [configEntry moveToGroup:lastDocument.root];
          dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
      }
      self.configurationEntry = configEntry;
      self.queryDocument = document;
      return _configurationEntry;
    }
  }
  
  if (lastDocument) {
    return [self _createConfigurationEntry:lastDocument];
  }
  
  return nil;
}

- (KPKEntry *)_createConfigurationEntry:(MPDocument *)document {
  KPKEntry *configEntry = [[KPKEntry alloc] initWithUUID:_rootUUID];
  configEntry.title = KPHSettingsEntryName;
  /* move the entry only on the main thread! */
  dispatch_semaphore_t sema = dispatch_semaphore_create(0L);
  dispatch_async(dispatch_get_main_queue(), ^{
    [configEntry addToGroup:document.root];
    dispatch_semaphore_signal(sema);
  });
  dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
  
  self.configurationEntry = [document findEntry:_rootUUID];
  self.queryDocument = document;
  
  return self.configurationEntry;
}

#pragma mark - KPHDelegate

+ (NSArray *)recursivelyFindEntriesInGroups:(NSArray *)groups forURL:(NSString *)url {
  NSMutableArray *entries = [[NSMutableArray alloc] init];
  
  BOOL includeCustomField = [NSUserDefaults.standardUserDefaults boolForKey:kMPHSettingsKeyIncludeKPHStringFields];
  NSMutableArray *stringFields;
  if(includeCustomField) {
    stringFields = [[NSMutableArray alloc] init];
  }
  
  for (KPKGroup *group in groups) {
    /* recurse through any subgroups */
    [entries addObjectsFromArray:[self recursivelyFindEntriesInGroups:group.groups forURL:url]];
    
    /* check each entry in the group */
    for (KPKEntry *entry in group.entries) {
      NSString *entryUrl = [entry.url kpk_finalValueForEntry:entry];
      NSString *entryTitle = [entry.title kpk_finalValueForEntry:entry];
      NSString *entryUsername = [entry.username kpk_finalValueForEntry:entry];
      NSString *entryPassword = [entry.password kpk_finalValueForEntry:entry];
      
      if(includeCustomField) {
        for(KPKAttribute *attribute in entry.customAttributes) {
          if([attribute.key hasPrefix:@"KPH: "]) {
            KPHResponseStringField *stringField = [KPHResponseStringField stringFieldWithKey:attribute.key value:attribute.value];
            if(stringField) {
              [stringFields addObject:stringField];
            }
          }
        }
      }
      
      if (url == nil || [entryTitle rangeOfString:url].length > 0 || [entryUrl rangeOfString:url].length > 0) {
        // FIXME: fix generics compiler warnings!
        [entries addObject:[KPHResponseEntry entryWithUrl:entryUrl name:entryTitle login:entryUsername password:entryPassword uuid:entry.uuid.UUIDString stringFields:(id)stringFields]];
      }
    }
  }
  return entries;
}

- (NSArray *)server:(KPHServer *)server entriesForURL:(NSString *)url {
  if (!self.queryDocumentOpen) {
    return @[];
  }
  
  NSArray *results = [MPHServerDelegate recursivelyFindEntriesInGroups:@[self.queryDocument.root] forURL:url];
  if(results.count > 0) {
    NSString *template = NSLocalizedStringFromTableInBundle(@"REQUEST_ENTRY_FOR_URL_%@", @"", [NSBundle bundleForClass:self.class], @"Notificaton on entry request for url");
    [self showNotificationWithTitle:[NSString stringWithFormat:template,url]];
  }
  return results;
}

- (NSString *)server:(KPHServer *)server keyForLabel:(NSString *)label {
  if (!self.queryDocumentOpen) {
    return nil;
  }
  
  return [self.configurationEntry valueForAttributeWithKey:[NSString stringWithFormat:KPHAssociatKeyFormat, label]];
}

- (NSString *)server:(KPHServer *)server labelForKey:(NSString *)key {
  if (!self.queryDocumentOpen) {
    return nil;
  }
  
  dispatch_semaphore_t sema = dispatch_semaphore_create(0L);
  
  NSString __block *label = nil;
  __weak MPHServerDelegate *welf = self;
  
  self.requestController = [[MPHRequestAccessWindowController alloc] initWithRequestKey:key completionHandler:^(MPHRequestResponse response, NSString *identifier) {
    if(response == MPHRequestResponseAllow) {
      [welf.configurationEntry addCustomAttribute:[[KPKAttribute alloc] initWithKey:[NSString stringWithFormat:KPHAssociatKeyFormat, identifier] value:key]];
    }
    label = identifier;
    dispatch_semaphore_signal(sema);
  }];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    // sheet dismissal get's done inside the window
    [welf.queryDocument.windowForSheet beginSheet:welf.requestController.window completionHandler:^(NSModalResponse returnCode) {
      NSLog(@"Sheet dismissed!");
    }];
  });
  
  dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
  return label;
}

- (void)server:(KPHServer *)server setUsername:(NSString *)username andPassword:(NSString *)password forURL:(NSString *)url withUUID:(NSString *)uuid {
  if (!self.queryDocumentOpen) {
    return;
  }
  /* creat entry on main thread */
  __weak MPHServerDelegate *welf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    
    KPKEntry *entry = uuid ? [welf.queryDocument findEntry:[[NSUUID alloc] initWithUUIDString:uuid]] : nil;
    
    NSString *title;
    if (!entry) {
      /* create entry and tell the user about it*/
      entry = [[KPKEntry alloc] init];
      [entry addToGroup:welf.queryDocument.root];
      title = NSLocalizedStringFromTableInBundle(@"CREATED_CREDENTIALS_USERNAME_%@_URL_%@", @"", [NSBundle bundleForClass:self.class], @"Notification on newly created credentials");
      
    }
    else {
      /* just update the entry */
      title = NSLocalizedStringFromTableInBundle(@"UPDATED_CREDENTIALS_USERNAME_%@_URL_%@", @"", [NSBundle bundleForClass:self.class], @"Notification on updated credentials");
    }
    
    entry.title = url;
    entry.username = username;
    entry.password = password;
    entry.url = url;
    
    [self showNotificationWithTitle:[NSString stringWithFormat:title, username, url]];
  });
}

- (NSArray *)allEntriesForServer:(KPHServer *)server {
  if (!self.queryDocumentOpen) {
    return @[];
  }
  
  return [MPHServerDelegate recursivelyFindEntriesInGroups:self.queryDocument.root.groups forURL:nil];
}

- (NSString *)generatePasswordForServer:(KPHServer *)server {
  return [NSString passwordWithDefaultSettings];
}

- (NSString *)clientHashForServer:(KPHServer *)server {
  if (!self.queryDocumentOpen) {
    return nil;
  }
  
  return [NSString stringWithFormat:@"%@%@", self.queryDocument.root.uuid.UUIDString, self.queryDocument.trash.uuid.UUIDString];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
  /* Do not show if disabled */
  return [[NSUserDefaults standardUserDefaults] boolForKey:kMPHSettingsKeyShowNotifications];
}

- (void)showNotificationWithTitle:(NSString *)title {
  BOOL showNotification = [[NSUserDefaults standardUserDefaults] boolForKey:kMPHSettingsKeyShowNotifications];
  if(!showNotification) {
    /* Just exit */
    return;
  }
  NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
  NSUserNotification *userNotification = [[NSUserNotification alloc] init];
  userNotification.title = title;
  userNotification.deliveryDate = [NSDate date];
  
  [notificationCenter scheduleNotification:userNotification];
}

@end
