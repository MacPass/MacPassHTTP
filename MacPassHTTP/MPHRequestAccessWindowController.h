//
//  MPHAssiciationRequestWindowController.h
//  MacPassHTTP
//
//  Created by Michael Starke on 27/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPHRequestAccessWindowController : NSWindowController

@property (nonatomic, copy) void(^completionBlock)(NSModalResponse response);
@property (nonatomic, copy) NSString *title;

@end
