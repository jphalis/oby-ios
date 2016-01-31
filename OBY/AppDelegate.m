//
//  AppDelegate.m
//  OBY
//

#import "AppDelegate.h"
#import "AuthViewController.h"
#import "defs.h"
#import "MBProgressHUD.h"
#import "NotificationViewController.h"
#import "UIViewControllerAdditions.h"


MBProgressHUD *hud;

@interface AppDelegate ()<UIAlertViewDelegate>
@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize arrPhotos,dicAllKeys,arrTimeLinePhotos,arrHashtagPhotos,dictProfileInfo,arrSupports;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // Override point for customization after application launch.
    
    // Hide status bar on splash page
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    // Display white status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if(GetUserName == nil){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerOBY"];
        AuthViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
        navController.viewControllers = @[vc];
        [self.window setRootViewController:navController];
    }
    
    // Dark keyboard
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    [NSThread sleepForTimeInterval:1];
    
    arrSupports = [[NSMutableArray alloc]init];
    arrPhotos = [[NSMutableArray alloc]init];
    arrTimeLinePhotos = [[NSMutableArray alloc]init];
    arrHashtagPhotos = [[NSMutableArray alloc]init];
    dictProfileInfo = [[NSMutableDictionary alloc]init];
    
    Kiip *kiip = [[Kiip alloc] initWithAppKey:@"300fc8335c0e0080476bb09b9866d185" andSecret:@"a5a34e72cc8efc14a93a6b276cd968d1"];
    kiip.delegate = self;
    [Kiip setSharedInstance:kiip];
    
    // Push notification settings
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeNewsstandContentAvailability| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    // Which types of noticiations are enabled by the user
    // UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    HomeViewController *homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
//    homeViewController.managedObjectContext = self.managedObjectContext;

    return YES;
}

// Available in iOS8
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    
        [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *tokenAsString = [[[deviceToken description]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject: uniqueIdentifier forKey:@"deviceUDID"];
    [[NSUserDefaults standardUserDefaults] setObject: tokenAsString forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Handle your RemoteNotification
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    // NSLog(@"Error: %@", error);
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
    hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];  //view
    hud.labelText = @"";
}

-(void)showHUDAddedToView:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];  //view
    hud.labelText = message;
}

-(void)showHUDAddedToView2:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];  //view
    hud.labelText = message;
}

-(void)showHUDAddedTo:(UIView *)view message:(NSString *)message {
    [self hideHUDForView:view];
    ShowNetworkActivityIndicator();
    hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];  //view
    hud.labelText = message;
}

-(void)hideHUDForView2:(UIView *)view {
    HideNetworkActivityIndicator();
    [MBProgressHUD hideHUDForView:view animated:YES];    //view
}

-(void)UpdateMessage:(NSString *)message {
    if(hud != nil && hud.labelText != nil)
        hud.labelText = message;
}

#pragma mark - Validation Methods

+(BOOL)validateEmail:(NSString *)email{
    email = [email lowercaseString];
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
    un = [un lowercaseString];
    NSString *unRegEx =
    @"^[a-z0-9_-]{5,20}";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", unRegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:un];
    return myStringMatchesRegEx;
}

+(BOOL)isValidCharacter:(NSString*)string filterCharSet:(NSString*)set {
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
    NSInteger length = [mobileNumber length];
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
    NSInteger length = [mobileNumber length];
    return length;
}

-(void)userLogout{    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserName"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserID"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserToken"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserActive"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserPassword"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserMail"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserEduMail"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserWebsite"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserBio"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserFullName"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ProifilePic"];

    if(arrSupports.count > 0){
        [arrSupports removeAllObjects];
    }
    if(arrPhotos.count > 0){
        [arrPhotos removeAllObjects];
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerOBY"];
    AuthViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
    navController.viewControllers = @[vc];
    [self.window setRootViewController:navController];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OBY" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OBY.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
