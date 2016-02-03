//
//  MiscellaneousViewController.m
//

#import "AppDelegate.h"
#import "CreateViewController.h"
#import "defs.h"
#import "MiscellaneousViewController.h"
#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "SettingViewController.h"
#import "ShopViewController.h"


@interface MiscellaneousViewController (){
    AppDelegate *appDelegate;
    
    __weak IBOutlet UIButton *btnCreate;
    __weak IBOutlet UIButton *btnSearch;
    __weak IBOutlet UIButton *btnSetting;
    __weak IBOutlet UIButton *btnProfile;
    
}

- (IBAction)onClick:(id)sender;
enum{
    BTNCREATE = 1,
    BTNSERACH,
    BTNPROFILE,
    BTNSETTING,
};
@end

@implementation MiscellaneousViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [AppDelegate getDelegate];
    
    if(self.view.frame.size.height == 480 && self.view.frame.size.width == 320){
        btnCreate.frame = CGRectMake(btnCreate.frame.origin.x+5, btnCreate.frame.origin.y, 63, 63);
        btnProfile.frame = CGRectMake(btnProfile.frame.origin.x+5, btnProfile.frame.origin.y, 63, 63);
        btnSearch.frame = CGRectMake(btnSearch.frame.origin.x+5, btnSearch.frame.origin.y, 63, 63);
        btnSetting.frame = CGRectMake(btnSetting.frame.origin.x+5, btnSetting.frame.origin.y, 63, 63);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = NO;
    [super viewWillAppear:YES];
}

- (IBAction)onClick:(id)sender {
    switch ([sender tag]) {
        case BTNCREATE:{
            CreateViewController *createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateViewController"];
            [self.navigationController pushViewController:createViewController animated:YES];
            break;
        }
        case BTNSERACH:{
            SearchViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
            [self.navigationController pushViewController:searchViewController animated:YES];
            break;
        }
        case BTNPROFILE:{
            ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
           
            profileViewController.userURL = [NSString stringWithFormat:@"%@%@/",PROFILEURL,GetUserName];
            [self.navigationController pushViewController:profileViewController animated:YES];
            break;
        }
        case BTNSETTING:{
            SettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
            [self.navigationController pushViewController:settingViewController animated:YES];
            break;
        }
        default: {
            break;
        }
    }
}

@end
