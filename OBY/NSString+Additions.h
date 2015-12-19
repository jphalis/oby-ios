//
//  StringHelper.h
//  

#import <Foundation/Foundation.h>


@interface NSString (helper)

- (NSString*) substringFrom: (NSInteger) a to: (NSInteger) b;

- (NSInteger) indexOf: (NSString*) substring from: (NSInteger) starts;

- (NSString*) trim;

- (BOOL)containsNullString;

@end
