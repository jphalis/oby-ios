//
//  ProductsViewController.m
//  OBY
//

#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "SCLAlertView.h"
#import "ProductsViewController.h"
#import "StringUtil.h"
#import "TableViewCellProducts.h"
#import "ShopViewController.h"


@interface ProductsViewController (){
    AppDelegate *appDelegate;
    
    __weak IBOutlet UITableView *tblVW;
    __weak IBOutlet UILabel *lblWaterMark;
    
    NSMutableArray *arrProducts;
    UIRefreshControl *refreshControl;
}

@end

@implementation ProductsViewController

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    arrProducts = [[NSMutableArray alloc] init];
    
    if([self.title isEqual: @"Available"]){
        [self doGetProducts:AVAILABLESHOPURL];
    } else {
        [self doGetProducts:REDEEMEDSHOPURL];
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = NO;
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

-(void)startRefresh{
    if([self.title isEqual: @"Available"]){
        [self doGetProducts:AVAILABLESHOPURL];
    } else {
        [self doGetProducts:REDEEMEDSHOPURL];
    }
}

-(void)doGetProducts:(NSString *)requestURL{
    checkNetworkReachability();
    
    [self setBusy:YES];
    NSString *urlString = [NSString stringWithFormat:@"%@",requestURL];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if(error != nil){
            [appDelegate hideHUDForView2:self.view];
        }
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]] && [[JSONValue allKeys]count] > 2){
                NSArray *arrProductResult = [JSONValue objectForKey:@"results"];
                
                if([arrProductResult count] > 0){
                    for (int i = 0; i < arrProductResult.count; i++) {
                        
                        NSMutableDictionary *dictResult;
                        dictResult = [arrProductResult objectAtIndex:i];
                        NSMutableDictionary *dictProducts = [[NSMutableDictionary alloc]init];
                        
                        if([dictResult objectForKey:@"owner"] == [NSNull null]){
                            [dictProducts setValue:@"" forKey:@"owner"];
                        } else {
                            [dictProducts setValue:[dictResult objectForKey:@"owner"] forKey:@"owner"];
                        }
                        if([dictResult objectForKey:@"owner_url"] == [NSNull null]){
                            [dictProducts setValue:@"" forKey:@"owner_url"];
                        } else {
                            [dictProducts setValue:[dictResult objectForKey:@"owner_url"] forKey:@"owner_url"];
                        }
                        if([dictResult objectForKey:@"title"] == [NSNull null]){
                            [dictProducts setValue:@"" forKey:@"title"];
                        } else {
                            [dictProducts setValue:[dictResult objectForKey:@"title"] forKey:@"title"];
                        }
                        if([dictResult objectForKey:@"slug"] == [NSNull null]){
                            [dictProducts setValue:@"" forKey:@"slug"];
                        } else {
                            [dictProducts setValue:[dictResult objectForKey:@"slug"] forKey:@"slug"];
                        }
                        if([dictResult objectForKey:@"description"] == [NSNull null]){
                            [dictProducts setValue:@"" forKey:@"description"];
                        } else {
                            [dictProducts setValue:[dictResult objectForKey:@"description"] forKey:@"description"];
                        }
                        if([dictResult objectForKey:@"cost"] == [NSNull null]){
                            [dictProducts setValue:@"" forKey:@"cost"];
                        } else {
                            [dictProducts setValue:[dictResult objectForKey:@"cost"] forKey:@"cost"];
                        }
                        if([dictResult objectForKey:@"promo_code"] == [NSNull null]){
                            [dictProducts setValue:@"" forKey:@"promo_code"];
                        } else {
                            [dictProducts setValue:[dictResult objectForKey:@"promo_code"] forKey:@"promo_code"];
                        }
                        
                        [arrProducts addObject:dictResult];
                    }
                    [appDelegate hideHUDForView2:self.view];
                    [self setBusy:NO];
                    [self showProducts];
                }
            } else {
                [self setBusy:NO];
                lblWaterMark.hidden = NO;
                lblWaterMark.text = [NSString stringWithFormat:@"%@", [JSONValue objectForKey:@"detail"]];
            }
        } else {
            [refreshControl endRefreshing];
            [appDelegate hideHUDForView2:self.view];
            [self setBusy:NO];
            showServerError();
        }
    }];
}

-(void)showProducts{
    if(arrProducts.count > 0){
        [arrProducts removeAllObjects];
    }
    lblWaterMark.hidden = YES;
    lblWaterMark.text = @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;   //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrProducts count];   //count number of rows from array
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCellProducts *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];

    NSMutableDictionary *dictProducts;
    
    dictProducts = [arrProducts objectAtIndex:indexPath.row];

    cell.description.text = [dictProducts objectForKey:@"description"];
    cell.pointValue.text = [dictProducts objectForKey:@"cost"];
    [cell.companyLogo loadImageFromURL:[dictProducts objectForKey:@"company_logo"] withTempImage:@"avatar"];
    cell.companyLogo.layer.masksToBounds = YES;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];

    NSMutableDictionary *dictProducts;
    
    dictProducts = [arrProducts objectAtIndex:indexPath.row];
    
//    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
//    profileViewController.userURL = [dictUser objectForKey:@"account_url"];
//    [self.navigationController pushViewController:profileViewController animated:YES];
}

@end
