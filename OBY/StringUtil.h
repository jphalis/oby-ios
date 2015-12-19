//
//  StringUtil.h
//  TwitterFon
//

#import <UIKit/UIKit.h>

@interface NSString (NSStringUtils)
- (NSString*)encodeAsURIComponent;
- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;
+ (NSString*)localizedString:(NSString*)key;
+ (NSString*)base64encode:(NSString*)str;
+ (NSString *)decodeBase64:(NSString *)input;
- (NSString*)Trim;
- (BOOL)isEmpty;
+ (NSString *)generateUUID;
-(BOOL)filterType:(NSString*)type inputValue:(NSString*)value length:(int)length maxLength:(int)maxLength;

@end


