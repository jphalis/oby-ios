//
//  AppDelegate.m
//  OBY
//

#import "AppDelegate.h"
#import "UIViewControllerAdditions.h"
#import "defs.h"
#import "MBProgressHUD.h"
#import "ViewController.h"


MBProgressHUD *hud;

@interface AppDelegate ()<UIAlertViewDelegate>
@end

@implementation AppDelegate
@synthesize arrPhotos,dicAllKeys,arrTimeLinePhotos,dictProfileInfo,arrSupports;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Hide status bar on splash page
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    // Display white status bar on screen
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [NSThread sleepForTimeInterval:1];
    
    arrSupports=[[NSMutableArray alloc]init];
    arrPhotos=[[NSMutableArray alloc]init];
    arrTimeLinePhotos=[[NSMutableArray alloc]init];
    dictProfileInfo=[[NSMutableDictionary alloc]init];
    return YES;
}

#pragma mark - Static Methods

+(AppDelegate*) getDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication]delegate];
}

+(void)showMessage:(NSString *)message{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Message"
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    [myAlertView show];
}

#pragma mark - ActivityIndicator methods

-(void)hideHUDForView:(UIView *)view {
    HideNetworkActivityIndicator();
    [MBProgressHUD hideHUDForView:self.window animated:YES];    //view
}

-(void)showHUDAddedTo:(UIView *)view {
    ShowNetworkActivityIndicator();
    hud =[MBProgressHUD showHUDAddedTo:self.window animated:YES];  //view
    hud.labelText= @"";
}

-(void)showHUDAddedToView:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud =[MBProgressHUD showHUDAddedTo:view animated:YES];  //view
    hud.labelText= message;
}

-(void)showHUDAddedToView2:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud =[MBProgressHUD showHUDAddedTo:view animated:YES];  //view
    hud.labelText= message;
}

-(void)showHUDAddedTo:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud =[MBProgressHUD showHUDAddedTo:self.window animated:YES];  //view
    hud.labelText= message;
}

-(void)hideHUDForView2:(UIView *)view {
    HideNetworkActivityIndicator();
    [MBProgressHUD hideHUDForView:view animated:YES];    //view
}

-(void)UpdateMessage:(NSString *)message {
    if(hud!=nil && hud.labelText!=nil)
        hud.labelText= message;
}

#pragma mark - Validation Methods

+(BOOL)validateEmail:(NSString *)email{
    email= [email lowercaseString];
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:email];
    return myStringMatchesRegEx;
}

+(BOOL)validateUsername:(NSString *)un {
    un= [un lowercaseString];
    NSString *unRegEx =
    @"^[a-z0-9_-]{5,20}";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", unRegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:un];
    return myStringMatchesRegEx;
}

+(BOOL) isValidCharacter:(NSString*)string filterCharSet:(NSString*)set {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:set] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

-(NSString*)formatNumber:(NSString*)mobileNumber{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    int length = [mobileNumber length];
    if(length > 10) {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}

-(int)getLength:(NSString*)mobileNumber{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    int length = [mobileNumber length];
    return length;
}

-(void)userLogout{
    //LoginID,EmailID,Password,isMobileRegistered,UserName,FBID,MobileNum
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserName"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserID"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserToken"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserActive"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserPassword"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserMail"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserFullName"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ProifilePic"];

    if(arrSupports.count>0){
        [arrSupports removeAllObjects];
    }
    
    if(arrPhotos.count>0){
        [arrPhotos removeAllObjects];
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerOBY"];
    ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    navController.viewControllers = @[vc];
    [self.window setRootViewController:navController];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
