//
//  SearchViewController.m
//

#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "ProfileViewController.h"
#import "SCLAlertView.h"
#import "SearchViewController.h"
#import "StringUtil.h"
#import "TableViewCellNotification.h"


@interface SearchViewController (){
    AppDelegate *appDelegate;
    
    __weak IBOutlet UITableView *tblVW;
    __weak IBOutlet UISearchBar *txtSearch;
    __weak IBOutlet UILabel *lblWaterMark;
    
    int lastCount;
    BOOL isEmpty;
    BOOL isFilter;
    NSMutableArray *arrUsers;
    NSArray *arrFilterUsers;
}

- (IBAction)onSearch:(id)sender;
- (IBAction)onBack:(id)sender;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    arrUsers = [[NSMutableArray alloc] init];
    arrFilterUsers = [[NSArray alloc] init];
    
    [super viewDidLoad];
    
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
    appDelegate.tabbar.tabView.hidden = YES;
    lblWaterMark.text = @"Search OBY";
    txtSearch.layer.borderWidth = 1;
    txtSearch.layer.borderColor = [[UIColor whiteColor] CGColor];
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

- (IBAction)onSearch:(id)sender {
    if([self validateFields]){
        isEmpty = NO;
        [self doSearch];
    }
}

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if([[txtSearch.text Trim]isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_SEARCH closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return YES;
}

-(void)doSearch{
    checkNetworkReachability();
   
    if(isEmpty == YES){
        return;
    }
    
    [self setBusy:YES];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",SEARCH_URL,txtSearch.text];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
        
        if (error == nil && [data length] > 0){
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                NSArray *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                if([JSONValue isKindOfClass:[NSNull class]]){
                    [self setBusy:NO];
                    showServerError();
                    return;
                }
                if([JSONValue isKindOfClass:[NSArray class]]){
                    [self setBusy:NO];
                    
                    if( arrUsers.count > 0){
                        [arrUsers removeAllObjects];
                    }
                    if([JSONValue count] > 0){
                        for (int i = 0; i < JSONValue.count; i++) {
                            
                            NSMutableDictionary *dictResult;
                            dictResult = [JSONValue objectAtIndex:i];
                            NSMutableDictionary *dictSearch = [[NSMutableDictionary alloc]init];
                            
                            if([dictResult objectForKey:@"account_url"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"account_url"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"account_url"] forKey:@"account_url"];
                            }
                            if([dictResult objectForKey:@"username"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"username"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"username"] forKey:@"username"];
                            }
                            if([dictResult objectForKey:@"full_name"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"full_name"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"full_name"] forKey:@"full_name"];
                            }
                            
//                            NSString *fullString;
//                            NSString *userName = [dictResult objectForKey:@"username"];
//                            NSString *fullName = [dictResult objectForKey:@"full_name"];
//                            fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
//                            NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
//                            NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
//                            [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
//                            [dictSearch setValue:hogan forKey:@"usernameText"];
                            
                            if([dictResult objectForKey:@"profile_picture"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"profile_picture"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"profile_picture"] forKey:@"profile_picture"];
                            }
                            
                            [arrUsers addObject:dictSearch];
                        }
                        
                        lastCount = (int)[txtSearch.text length];
                        lblWaterMark.text = @"";
                        [self setBusy:NO];
                        [self showUsers];
                    } else {
                        isEmpty = YES;
                        lblWaterMark.text = @"0 results found";
                        [self showUsers];
                        //[tblVW reloadData];
                        [self setBusy:NO];
                    }
                } else {
                    [self setBusy:NO];
                    showServerError();
                }
            });
        }
    });
}

-(void)showUsers{
    if([txtSearch.text length] == 0){
        if(arrUsers.count > 0){
            [arrUsers removeAllObjects];
        }
        lblWaterMark.text = @"";
    }
    
    [self doFilter];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;   //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(isFilter == YES){
        return [arrFilterUsers count];
    } else {
    return [arrUsers count];
    }           //count number of rows from array
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCellNotification *cell=[tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];

    NSMutableDictionary *dictUser;
    
    if(isFilter == YES){
        dictUser = [arrFilterUsers objectAtIndex:indexPath.row];
    } else {
        dictUser = [arrUsers objectAtIndex:indexPath.row];
    }

//    cell.txtNotification.attributedText = [dictUser objectForKey:@"usernameText"];
    cell.usrUsername.text = [dictUser objectForKey:@"username"];
    cell.usrFullname.text = [dictUser objectForKey:@"full_name"];
    [cell.imgProfile loadImageFromURL:[dictUser objectForKey:@"profile_picture"] withTempImage:@"avatar"];
    cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.width / 2;
    cell.imgProfile.layer.masksToBounds = YES;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];

    NSMutableDictionary *dictUser;
    
    if(isFilter == YES){
        dictUser = [arrFilterUsers objectAtIndex:indexPath.row];
    } else {
        dictUser = [arrUsers objectAtIndex:indexPath.row];
    }
    profileViewController.userURL = [dictUser objectForKey:@"account_url"];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText length] == 0){
        isFilter = NO;
        if(arrUsers.count > 0){
            [arrUsers removeAllObjects];
        }
        isEmpty = NO;
        lblWaterMark.text = @"Search OBY";
        [tblVW reloadData];
    } else {
        if(searchText.length == 1){
            [self doSearch];
        } else {
            [self doFilter];
        }
    }
}

-(void)doFilter{
    isFilter = YES;
    arrFilterUsers = nil;
    NSString *searchString = txtSearch.text;
    
    if([searchString length] == 0){
        if(arrUsers.count > 0){
            [arrUsers removeAllObjects];
        }
        isEmpty = NO;
        lblWaterMark.text = @"";
        [tblVW reloadData];
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username beginswith[c] %@", searchString];
    arrFilterUsers = [arrUsers filteredArrayUsingPredicate:predicate];
    
    if(arrFilterUsers.count > 0){
        lblWaterMark.text = @"";
    } else {
        lblWaterMark.text = @"0 results found";
    }
    [tblVW reloadData];
}

@end
