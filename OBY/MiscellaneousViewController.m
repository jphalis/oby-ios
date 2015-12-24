//
//  MiscellaneousViewController.m
//

#import "MiscellaneousViewController.h"
#import "CreateViewController.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "ProfileViewController.h"
#import "defs.h"
#import "SearchViewController.h"


@interface MiscellaneousViewController (){
    AppDelegate *appDelegate;
    
    __weak IBOutlet UIButton *btnCreate;
    __weak IBOutlet UIButton *btnSearch;
    __weak IBOutlet UIButton *btnSetting;
    __weak IBOutlet UIButton *btnProfile;
    
}

- (IBAction)onClick:(id)sender;
enum{
    BTNCREATE =1,
    BTNSERACH,
    BTNPROFILE,
    BTNSETTING,
};
@end

@implementation MiscellaneousViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate=[AppDelegate getDelegate];
    
    if(self.view.frame.size.height==480 &&self.view.frame.size.width==320){
        btnCreate.frame=CGRectMake(btnCreate.frame.origin.x+5, btnCreate.frame.origin.y, 63, 63);
        btnProfile.frame=CGRectMake(btnProfile.frame.origin.x+5, btnProfile.frame.origin.y, 63, 63);
        btnSearch.frame=CGRectMake(btnSearch.frame.origin.x+5, btnSearch.frame.origin.y, 63, 63);
        btnSetting.frame=CGRectMake(btnSetting.frame.origin.x+5, btnSetting.frame.origin.y, 63, 63);
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden=NO;
    [super viewWillAppear:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClick:(id)sender {
    switch ([sender tag]) {
        case BTNCREATE:{
//            NSLog(@"create");
            
            CreateViewController *createViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"CreateViewController"];
            [self.navigationController pushViewController:createViewController animated:YES];
        }
            break;
        case BTNSERACH:{
            SearchViewController *SearchViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
            [self.navigationController pushViewController:SearchViewController animated:YES];
            
//            NSLog(@"search");
        }
            break;
        case BTNPROFILE:{
            
            ProfileViewController *profileViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
           
            profileViewController.userURL=[NSString stringWithFormat:@"%@%@/",PROFILEURL,GetUserName];
            [self.navigationController pushViewController:profileViewController animated:YES];
//            NSLog(@"Profile");
        }
            break;
        case BTNSETTING:{
            SettingViewController *settingViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
            [self.navigationController pushViewController:settingViewController animated:YES];
            
//            NSLog(@"setting");
        }
            break;
            
        default:
            break;
    }
}

@end
