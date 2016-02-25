//
//  GlobalFunctions.h
//  OBY
//

void checkNetworkReachability();
void doRewardCheck();
void showServerError();

@interface NSString(MyNSStringCategoryName)
+ (NSString *)abbreviateNumber:(int)num;
+ (NSString *)floatToString:(float)val;
@end
