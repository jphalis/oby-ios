//
//  SettingViewController.m
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "defs.h"
#import "Message.h"
#import "Reachability.h"
#import "ChangePassViewController.h"
#import "EditProfileViewController.h"
//#import "SVWebViewController.h"
#import "SVModalWebViewController.h"

// SEND MAIL FOR SUPPORT TAB
//#define URLEMail @"mailto:team@obystudio.com?subject=Support inquiry&body=content"
//
//NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
//[[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];


@interface SettingViewController (){
    AppDelegate *appDelegate;
    
    __weak IBOutlet UIImageView *imgLogout;
    __weak IBOutlet UIImageView *imgPrivacy;
    __weak IBOutlet UIImageView *imgTerms;
    __weak IBOutlet UIImageView *imgHelp;
    __weak IBOutlet UIImageView *imgEdit;
    __weak IBOutlet UIImageView *imgchangePass;
}
enum{
    EDITPROFILE = 1,
    HELPCENTER,
    TERMS,
    LOGOUT,
    PRIVACY,
    CHANGEPASS
};
- (IBAction)onBack:(id)sender;
- (IBAction)onClick:(id)sender;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    if(self.view.frame.size.height == 480 && self.view.frame.size.width == 320){
        imgEdit.frame = CGRectMake(imgEdit.frame.origin.x+2, imgEdit.frame.origin.y, 30, 30);
        imgHelp.frame = CGRectMake(imgHelp.frame.origin.x+2, imgHelp.frame.origin.y, 30, 30);
        imgTerms.frame = CGRectMake(imgTerms.frame.origin.x+2, imgTerms.frame.origin.y, 30, 30);
        imgLogout.frame = CGRectMake(imgLogout.frame.origin.x+2, imgLogout.frame.origin.y, 30, 30);
        imgPrivacy.frame = CGRectMake(imgPrivacy.frame.origin.x+2, imgPrivacy.frame.origin.y, 30, 30);
        imgchangePass.frame = CGRectMake(imgchangePass.frame.origin.x+2, imgchangePass.frame.origin.y, 30, 30);
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:viewRight];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    appDelegate.tabbar.tabView.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClick:(id)sender {
    switch ([sender tag]) {
        case EDITPROFILE:{
            EditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
            [self.navigationController pushViewController:editProfileViewController animated:YES];
            NSLog(@"edit");
        }
            break;
        case HELPCENTER:{
            NSLog(@"help");
        }
            break;
        case TERMS:{
            NSLog(@"terms");
            Reachability *reachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [reachability currentReachabilityStatus];
            if(networkStatus == NotReachable) {
                [self showMessage:NETWORK_UNAVAILABLE];
                return;
            }
            // Opens TERMSURL in a modal view
            SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@",TERMSURL]];
            [self presentViewController:webViewController animated:YES completion:NULL];
            
            // Opens TERMSURL in Safari
            // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:TERMSURL]];
        }
            break;
        case LOGOUT: {
            NSLog(@"logout");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            alert.delegate = self;
            alert.tag = 100;
            [alert show];
        }
            break;
        case PRIVACY: {
            NSLog(@"privacy");
            
            Reachability *reachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [reachability currentReachabilityStatus];
            if(networkStatus == NotReachable) {
                [self showMessage:NETWORK_UNAVAILABLE];
                return;
            }
            
            // Opens PRIVACYURL in a modal view
            SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@",PRIVACYURL]];
            [self presentViewController:webViewController animated:YES completion:NULL];
            
            // Opens PRIVACYURL in Safari
            // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:PRIVACYURL]];
        }
            break;
        case CHANGEPASS: {
            ChangePassViewController *changePassViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePassViewController"];
            [self.navigationController pushViewController:changePassViewController animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1 ) {
        [appDelegate userLogout];
    }
}

@end
