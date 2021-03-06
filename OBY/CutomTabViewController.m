//
//  CutomTabViewController.m
//

#import "AppDelegate.h"
#import "BadgeLabel.h"
#import "CutomTabViewController.h"
#import "defs.h"
#import "HomeViewController.h"
#import "MiscellaneousViewController.h"
#import "NotificationClass.h"
#import "NotificationViewController.h"
#import "ShopViewController.h"
#import "TimeLineViewController.h"


enum {
    TABHOME = 10,
    TABTIMELINE,
    TABSHOP,
    TABNOTIFICATION,
    TABMISCELLANEOUS,
};

@interface CutomTabViewController (){
    AppDelegate *appDelegate;
    
    id specialViewController;
    NSInteger previousIndex ;
    UINavigationController *prevController;
    NSInteger currentIndex;
    NSTimer *timer;
}

- (IBAction)onTabSelectionChange:(id)sender;

@property (weak, nonatomic) IBOutlet BadgeLabel *badgeLabel;

@end

@implementation CutomTabViewController
@synthesize tabView, currentView;

- (void)viewDidLoad {
    appDelegate = (AppDelegate *)[AppDelegate getDelegate];
    self.navigationController.navigationBarHidden = YES;

    [self Initialize];
    [self LoadTabBar];
    
    UIButton *btnSender = (UIButton*) [self.view viewWithTag:10];
    [self onTabSelectionChange:btnSender];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self DoGetNotificationCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)Initialize{
    prevController = nil;
    previousIndex = -1;
    currentIndex = -1;
    
    appDelegate.arrViewControllers = [[NSMutableArray alloc]init];
    appDelegate.tabbar = self;

// Thin grey border on top
//    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tabView.frame.size.width, 0.7)];
//    topBorder.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1.0];
//    [tabView addSubview:topBorder];
    
    UIButton *btn = (UIButton*)[self.view viewWithTag:TABHOME];
    btn.titleLabel.font = fontLight(13);
    btn = (UIButton*)[self.view viewWithTag:TABTIMELINE];
    btn.titleLabel.font = fontLight(13);
    btn = (UIButton*)[self.view viewWithTag:TABSHOP];
    btn.titleLabel.font = fontLight(13);
    btn = (UIButton*)[self.view viewWithTag:TABNOTIFICATION];
    btn.titleLabel.font = fontLight(13);
    btn = (UIButton*)[self.view viewWithTag:TABMISCELLANEOUS];
    btn.titleLabel.font = fontLight(13);
    
    [self.badgeLabel initBadge];
    [self.badgeLabel setStyle:BadgeLabelStyleAppIcon];
    
    self.badgeLabel.hidden = (appDelegate.notificationCount > 0)? NO:YES;
    
    if ([timer isValid]) {
        [timer invalidate], timer = nil;
    }
    
   timer = [NSTimer scheduledTimerWithTimeInterval:18 target:self selector:@selector(DoGetNotificationCount) userInfo:nil repeats:YES];
}


-(void)DoGetNotificationCount{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@",NOTIFICATIONUNREADURL];
    
        NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                 timeoutInterval:60];
    
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
        [_request setHTTPMethod:@"GET"];
    
        [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             
                if([JSONValue isKindOfClass:[NSDictionary class]] && [[JSONValue allKeys]count] > 2){
                    NSArray *arrNotifResult = [JSONValue objectForKey:@"results"];
                    int notifCount = 0;

                    for (int i = 0; i < arrNotifResult.count; i++){
                        NSMutableDictionary *dictNoti = [arrNotifResult objectAtIndex:i];
                        int rd = (int)[[dictNoti objectForKey:@"read"]integerValue];
                     
                        if(rd != 1){
                            notifCount++;
                        }
                    }
                    appDelegate.notificationCount = notifCount;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Display number of unread notifications
                        // self.badgeLabel.text = [NSString stringWithFormat:@"%ld",(long)appDelegate.notificationCount];
                        // Blank circle
                        self.badgeLabel.text = @" ";
                        self.badgeLabel.hidden = (appDelegate.notificationCount > 0)? NO:YES;
                        if (self.badgeLabel.hidden == NO){
                            [self viewWillLayoutSubviews];
                        }
                    });
                }
            }
        }];
    });
}

-(void)viewWillLayoutSubviews{
    CGFloat width =  [self.badgeLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12.0]}].width;
    CGRect frame = self.badgeLabel.frame;
    frame.size.width = width + 10;
    self.badgeLabel.frame = frame;
    [self.badgeLabel sizeToFit];
}

-(void)LoadTabBar{
    HomeViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    TimeLineViewController *timeLineViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TimeLineViewController"];
    ShopViewController *shopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShopViewController"];
    NotificationViewController *notificationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    MiscellaneousViewController *miscellaneousViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MiscellaneousViewController"];
    
    UINavigationController *navController1 = [[UINavigationController alloc]initWithRootViewController:homeViewController];
    UINavigationController *navController2 = [[UINavigationController alloc]initWithRootViewController:timeLineViewController];
    UINavigationController *navController3 = [[UINavigationController alloc]initWithRootViewController:shopViewController];
    UINavigationController *navController4 = [[UINavigationController alloc]initWithRootViewController:notificationViewController];
    UINavigationController *navController5 = [[UINavigationController alloc]initWithRootViewController:miscellaneousViewController];
    
    [self PushViewController:navController1];
    [self PushViewController:navController2];
    [self PushViewController:navController3];
    [self PushViewController:navController4];
    [self PushViewController:navController5];
}

-(void)PushViewController:(UINavigationController *)nvc{
    nvc.navigationBarHidden = YES;
    [appDelegate.arrViewControllers addObject:nvc];
}

-(void)PresentSpecialViewController:(UIViewController *)vc{
    if(prevController != nil){
        [prevController.view removeFromSuperview];
    }
    specialViewController = vc;
    CGRect frame = vc.view.frame;
    frame.origin = CGPointMake(0, 0);
    frame.size.height = frame.size.height;
    vc.view.frame = frame;
    [self.view addSubview:vc.view];
    //[self.view bringSubviewToFront:self.tabView];
    prevController = specialViewController;
}

-(void)presentThisView:(UINavigationController*)naVController{
    if(prevController != nil){
        [prevController.view removeFromSuperview];
    }
    prevController.view.backgroundColor = [UIColor whiteColor];
    prevController = naVController;
    CGRect frame = prevController.view.frame;
    frame.origin = CGPointMake(0, 0);
    frame.size.height = frame.size.height;
    prevController.view.frame = frame;
    
    [self.view addSubview:prevController.view];
    [self.view bringSubviewToFront:tabView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onTabSelectionChange:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    previousIndex = currentIndex;
    currentIndex = btn.tag;
    
    if (btn.tag == previousIndex){
       // return;
//        [UIView animateWithDuration:0.5 animations:^(void){
//            [collectionVW scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
//        }];
//        NSLog(@"Click");
        
        // send notification to HomeViewController to scrollToTop
    } else {
        if (previousIndex != 0){
            UIButton *btnpreviousIndex = (UIButton*)[tabView viewWithTag:previousIndex];
            
            if (btnpreviousIndex != nil && previousIndex != -1){
                [btnpreviousIndex setSelected:NO];
            }
           // UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frame.size.height - 4.0f, btn.frame.size.width, 4)];
          //  bottomBorder.backgroundColor = [UIColor lightGrayColor];
        
            [btn setSelected:YES];
           // [btn addSubview:bottomBorder];
        }
    }
    appDelegate.currentTab = currentIndex;
    
    switch (currentIndex) {
        case TABHOME: {
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:0];
            navController.navigationBarHidden = YES;
            [navController popToRootViewControllerAnimated:NO];
            [self presentThisView: navController];
            break;
        }
        case TABTIMELINE: {
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:1];
            [self presentThisView: navController];
            break;
        }
        case TABSHOP: {
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:2];
            [self presentThisView: navController];
            break;
        }
        case TABNOTIFICATION: {
            self.badgeLabel.hidden = YES;
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:3];
            [self presentThisView: navController];
            break;
        }
        case TABMISCELLANEOUS: {
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:4];
            [self presentThisView: navController];
            break;
        }
        default:
            break;
    }
}

@end
