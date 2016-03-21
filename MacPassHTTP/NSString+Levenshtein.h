//
//  NSString+Levenshtein.h
//  MacPassHTTP
//
//  Created by Christopher Luu on 20/03/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (Levenshtein)

- (NSUInteger)levenshteinDistanceToString:(NSString *)string;

@end
