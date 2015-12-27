//
//  AppDelegate.h
//  OBY
//

#import <UIKit/UIKit.h>
#import "CutomTabViewController.h"
#import <KiipSDK/KiipSDK.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, KiipDelegate>

@property (strong, nonatomic) UIWindow *window;
+(AppDelegate*) getDelegate;
+(void)showMessage:(NSString *)message;

@property (strong, nonatomic) NSMutableArray *arrTimeLinePhotos;
@property (strong, nonatomic) NSMutableArray *arrHashtagPhotos;
@property (strong, nonatomic) NSMutableArray *arrSupports;
@property (strong, nonatomic) NSMutableArray *arrPhotos;
@property (strong, nonatomic) NSMutableDictionary *dicAllKeys;
@property (strong, nonatomic) NSMutableDictionary *dictProfileInfo;
@property (strong, nonatomic) NSMutableArray *arrViewControllers;
@property (strong, nonatomic) CutomTabViewController *tabbar;
@property (assign, nonatomic) NSInteger currentTab;
@property (assign, nonatomic) NSInteger notificationCount;
@property (strong, nonatomic) UINavigationController *navController;

//Activity Methods
-(void)showHUDAddedToView2:(UIView *)view message:(NSString *)message;
-(void)showHUDAddedToView:(UIView *)view message:(NSString *)message;
-(void)hideHUDForView2:(UIView *)view;
-(void)hideHUDForView:(UIView *)view;
-(void)showHUDAddedTo:(UIView *)view ;
-(void)showHUDAddedTo:(UIView *)view message:(NSString *)message ;
-(void)UpdateMessage:(NSString *)message;

//Validation Methods
+(BOOL)validateEmail:(NSString *)email ;
+(BOOL)validateUsername:(NSString *)un ;
+(BOOL)isValidCharacter:(NSString*)string filterCharSet:(NSString*)set;
-(NSString*)formatNumber:(NSString*)mobileNumber;
-(int)getLength:(NSString*)mobileNumber;

-(void)userLogout;

@end
