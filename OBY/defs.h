//
//  defs.h
//

#ifndef Casting_defs_h
#define Casting_defs_h

#include "AppDelegate.h"
#import "UIViewControllerAdditions.h"
#import "Message.h"

extern AppDelegate *appDelegate;

#define trim(x) [x stringByTrimmingCharactersInSet:WSset]
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
#define SetSInt(x) [NSString stringWithFormat:@"%d",x]
#define SetInt(x) [NSString stringWithFormat:@"%ld",x]
#else
#define SetSInt(x) [NSString stringWithFormat:@"%d",x]
#define SetInt(x) SetSInt(x)
#endif

#define DQ_  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#define _DQ });
#define MQ_ dispatch_async( dispatch_get_main_queue(), ^(void) {
#define _MQ });

#define MAIN_FRAME [[UIScreen mainScreen]bounds]
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height

#define fontLight(x)  [UIFont fontWithName:@"Raleway-Light" size:x];
#define fontRegular(x)  [UIFont fontWithName:@"Raleway-Regular" size:x];
#define fontMedium(x)  [UIFont fontWithName:@"Raleway-Medium" size:x];

#define EMAIL           @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@-"
#define PASSWORD_CHAR   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890._-*@!"
#define USERNAME    @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
#define GROUPNAME    @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-,!@#$%^&*(){}[]|\/?':;.<>"

#define  NUMBERS @"0123456789+"
#define  NUMBERS1 @"0123456789"
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#ifdef DEBUG
    // DEV URLS
    #define LIKEURL @"http://127.0.0.1:8000/hide/oby/api/like/"
    #define COMMENTURL @"http://127.0.0.1:8000/hide/oby/api/comments/create/"
    #define SUPPORTURL @"http://127.0.0.1:8000/hide/oby/api/support/"
    #define SEARCH_URL @"http://127.0.0.1:8000/hide/oby/api/search/?q="
    #define CHANGEPASSURL @"http://127.0.0.1:8000/hide/oby/api/password/change/"
    #define FORGOTPASSURL @"http://127.0.0.1:8000/hide/oby/api/password/reset/"
    #define LOGINURL @"http://127.0.0.1:8000/hide/oby/api/auth/token/"
    #define SIGNUPURL @"http://127.0.0.1:8000/hide/oby/api/accounts/create/"
    #define HOMEPAGEURL @"http://127.0.0.1:8000/hide/oby/api/homepage/"
    #define CATEGORYURL @"http://127.0.0.1:8000/hide/oby/api/categories/"
    #define NOTIFICATIONURL @"http://127.0.0.1:8000/hide/oby/api/notifications/"
    #define NOTIFICATIONUNREADURL @"http://127.0.0.1:8000/hide/oby/api/notifications/unread/"
    #define CREATEURL @"http://127.0.0.1:8000/hide/oby/api/photos/create/"
    #define TIMELINEURL @"http://127.0.0.1:8000/hide/oby/api/timeline/"
    #define PROFILEURL @"http://127.0.0.1:8000/hide/oby/api/accounts/"
    #define TERMSURL @"http://127.0.0.1:8000/terms"
    #define PRIVACYURL @"http://127.0.0.1:8000/privacy"
#else
    // PROD URLS
    #define LIKEURL @"https://www.obystudio.com/hide/oby/api/like/"
    #define COMMENTURL @"https://www.obystudio.com/hide/oby/api/comments/create/"
    #define SUPPORTURL @"https://www.obystudio.com/hide/oby/api/support/"
    #define SEARCH_URL @"https://www.obystudio.com/hide/oby/api/search/?q="
    #define CHANGEPASSURL @"https://www.obystudio.com/hide/oby/api/password/change/"
    #define FORGOTPASSURL @"https://www.obystudio.com/hide/oby/api/password/reset/"
    #define LOGINURL @"https://www.obystudio.com/hide/oby/api/auth/token/"
    #define SIGNUPURL @"https://www.obystudio.com/hide/oby/api/accounts/create/"
    #define HOMEPAGEURL @"https://www.obystudio.com/hide/oby/api/homepage/"
    #define CATEGORYURL @"https://www.obystudio.com/hide/oby/api/categories/"
    #define NOTIFICATIONURL @"https://www.obystudio.com/hide/oby/api/notifications/"
    #define CREATEURL @"https://www.obystudio.com/hide/oby/api/photos/create/"
    #define TIMELINEURL @"https://www.obystudio.com/hide/oby/api/timeline/"
    #define PROFILEURL @"https://www.obystudio.com/hide/oby/api/accounts/"
    #define TERMSURL @"https://www.obystudio.com/terms"
    #define PRIVACYURL @"https://www.obystudio.com/privacy"
#endif

#define    SetisComment(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"isComment"]
#define    GetisComment            [[NSUserDefaults standardUserDefaults] boolForKey:@"isComment"]

#define    SetisUpdate(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"isUpdate"]
#define    GetisUpdate            [[NSUserDefaults standardUserDefaults] boolForKey:@"isUpdate"]

#define    SetAppKill(x)          [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"AppKill"]
#define    GetAppKill              [[NSUserDefaults standardUserDefaults] objectForKey:@"AppKill"]

#define    SetUserToken(x)          [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserToken"]
#define    GetUserToken              [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]

#define    SetUserID(x)           [[NSUserDefaults standardUserDefaults] setInteger:(x) forKey:@"UserID"]
#define    GetUserID               [[NSUserDefaults standardUserDefaults] integerForKey:@"UserID"]

#define    SetUserActive(x)           [[NSUserDefaults standardUserDefaults] setInteger:(x) forKey:@"UserActive"]
#define    GetUserActive               [[NSUserDefaults standardUserDefaults] integerForKey:@"UserActive"]

#define    SetEmailID(x)          [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"EmailID"]
#define    GetEmailID              [[NSUserDefaults standardUserDefaults] objectForKey:@"EmailID"]

#define    SetUserPassword(x)          [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserPassword"]
#define    GetUserPassword              [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]

#define    SetisMobile_Registered(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"isMobileRegistered"]
#define    GetisMobile_Registered            [[NSUserDefaults standardUserDefaults] boolForKey:@"isMobileRegistered"]

#define    SetUserName(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserName"]
#define    GetUserName              [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]

#define    SetUserFullName(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserFullName"]
#define    GetUserFullName             [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFullName"]

#define    SetProifilePic(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"ProifilePic"]
#define    GetProifilePic              [[NSUserDefaults standardUserDefaults] objectForKey:@"ProifilePic"]

#define    SetUserMail(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserMail"]
#define    GetUserMail              [[NSUserDefaults standardUserDefaults] objectForKey:@"UserMail"]

#define    SetFBID(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"FBID"]
#define    GetFBID              [[NSUserDefaults standardUserDefaults] objectForKey:@"FBID"]

#define    SetMobileNum(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"MobileNum"]
#define    GetMobileNum              [[NSUserDefaults standardUserDefaults] objectForKey:@"MobileNum"]

#define    SetIsVersion1(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"Version1"]
#define    GetsVersion1            [[NSUserDefaults standardUserDefaults] boolForKey:@"Version1"]

#define    SetTutorialOFF(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"TutorialOFF"]
#define    GetTutorialOFF            [[NSUserDefaults standardUserDefaults] boolForKey:@"TutorialOFF"]

#define    SetisFullView(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"FullView"]
#define    GetsFullView            [[NSUserDefaults standardUserDefaults] boolForKey:@"FullView"]

#define UserDefaults            [NSUserDefaults standardUserDefaults]

#define SetLat(x)  [UserDefaults setObject:x forKey:@"C_Lat"]

#define GetLat()     [UserDefaults objectForKey:@"C_Lat"]

#define SetLong(x)  [UserDefaults setObject:x forKey:@"C_Long"]
#define GetLong()     [UserDefaults objectForKey:@"C_Long"]

#define SetFirst(x)  [UserDefaults setObject:x forKey:@"First"]
#define GetFirst     [UserDefaults objectForKey:@"First"]

#define    SetGender(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"Gender"]

#define    GetGender            [[NSUserDefaults standardUserDefaults] objectForKey:@"Gender"]

#define    SetUnionType(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UnionType"]

#define    GetUnionType            [[NSUserDefaults standardUserDefaults] objectForKey:@"UnionType"]

#define    SetPerfomance(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"Performance"]

#define    GetPerformance            [[NSUserDefaults standardUserDefaults] objectForKey:@"Performance"]

#define    SetBirthYear(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"BirthYear"]

#define    GetBirthYear            [[NSUserDefaults standardUserDefaults] objectForKey:@"BirthYear"]

#define    SetCurrentLoaction(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"CurrentLoaction"]

#define    GetCurrentLoaction            [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLoaction"]

#define    SetIsFilter(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"Filter"]

#define    GetIsFilter            [[NSUserDefaults standardUserDefaults] boolForKey:@"Filter"]

#define    SetHelpOverlay(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"HelpOverlay"]

#define    GetHelpOverlay            [[NSUserDefaults standardUserDefaults] objectForKey:@"HelpOverlay"]

#define    SetInitialScreen(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"InitialScreen"]

#define    GetInitialScreen            [[NSUserDefaults standardUserDefaults] objectForKey:@"InitialScreen"]

#define    SetEthnicity(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"Ethnicity"]

#define    GetEthnicity            [[NSUserDefaults standardUserDefaults] objectForKey:@"Ethnicity"]

#define    SetIsImageView(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"ImageView"]
#define    GetsImageView            [[NSUserDefaults standardUserDefaults] boolForKey:@"ImageView"]

#endif
