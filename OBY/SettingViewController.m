//
//  SettingViewController.m
//

#import "AppDelegate.h"
#import "ChangePassViewController.h"
#import "defs.h"
#import "EditProfileViewController.h"
#import "GlobalFunctions.h"
#import "ProfileViewController.h"
#import "SettingViewController.h"
#import "SVModalWebViewController.h"
#import "TableViewCellSettings.h"
#import "TWMessageBarManager.h"


// SEND MAIL FOR SUPPORT TAB
//#define URLEMail @"mailto:team@obystudio.com?subject=Support inquiry&body=content"
//
//NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
//[[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];


@interface SettingViewController (){
    AppDelegate *appDelegate;
}

- (IBAction)onBack:(id)sender;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;    //count of sections
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;    //count of rows
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    tableView.tableFooterView = [[UIView alloc] init];
    
    TableViewCellSettings *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0: {
            cell.category.text = @"account";
            cell.fields.text = @"email, name, bio, website, gender";
            break;
        }
        case 1: {
            cell.category.text = @"password";
            cell.fields.text = @"change password";
            break;
        }
        case 2: {
            cell.category.text = @"terms of service";
            cell.fields.text = @"";
            break;
        }
        case 3: {
            cell.category.text = @"privacy policy";
            cell.fields.text = @"";
            break;
        }
        case 4: {
            cell.category.text = @"sign out";
            cell.fields.text = @"";
            break;
        }
        default: {
            break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:{
            EditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
            [self.navigationController pushViewController:editProfileViewController animated:YES];
            break;
        }
        case 1:{
            ChangePassViewController *changePassViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePassViewController"];
            [self.navigationController pushViewController:changePassViewController animated:YES];
            break;
        }
        case 2:{
            checkNetworkReachability();
            // Opens TERMSURL in a modal view
            SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@",TERMSURL]];
            [self presentViewController:webViewController animated:YES completion:NULL];
            
            // Opens TERMSURL in Safari
            // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:TERMSURL]];
            break;
        }
        case 3: {
            checkNetworkReachability();
            
            // Opens PRIVACYURL in a modal view
            SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@",PRIVACYURL]];
            [self presentViewController:webViewController animated:YES completion:NULL];
            
            // Opens PRIVACYURL in Safari
            // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:PRIVACYURL]];
            break;
        }
        case 4: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to sign out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            alert.delegate = self;
            alert.tag = 100;
            [alert show];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1 ) {
        [appDelegate userLogout];
    }
}

@end

