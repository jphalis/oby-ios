//
//  SupportViewController.m
//

#import "AppDelegate.h"
#import "defs.h"
#import "ProfileViewController.h"
#import "SupportViewController.h"
#import "TableViewCellNotification.h"
#import "UIImageView+WebCache.h"


@interface SupportViewController (){
    AppDelegate *appDelegate;
    __weak IBOutlet UILabel *lblPageTitle;
}

- (IBAction)onBack:(id)sender;

@end

@implementation SupportViewController
@synthesize arrDetails, pageTitle;

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
    
    lblPageTitle.text = pageTitle;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = YES;
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
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
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrDetails count];    //count number of row from counting array hear catagory is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TableViewCellNotification *cell = [tableView dequeueReusableCellWithIdentifier:@"SupportCell" forIndexPath:indexPath];
    
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];
    
    cell.txtNotification.attributedText = [dictUser objectForKey:@"usernameText"];
    cell.txtNotification.editable = NO;
    
    if([[dictUser objectForKey:@"user__username"]isEqualToString:GetUserName]){
        [dictUser setObject:GetProifilePic forKey:@"user__profile_picture"];
        [cell.imgProfile loadImageFromURL:GetProifilePic withTempImage:@"avatar"];
    } else {
        [cell.imgProfile loadImageFromURL:[dictUser objectForKey:@"user__profile_picture"] withTempImage:@"avatar"];
    }
    cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.width / 2;
    cell.imgProfile.layer.masksToBounds = YES;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    NSDictionary *dictUserDeatil = [arrDetails objectAtIndex:indexPath.row];
    
    NSString *usrURL = [NSString stringWithFormat:@"%@%@/",PROFILEURL,[dictUserDeatil objectForKey:@"user__username"]];
    
    profileViewController.userURL = usrURL;
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

@end
