//
//  ProductsViewController.m
//  OBY
//

#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "SCLAlertView.h"
#import "ProductClass.h"
#import "ProductSingleViewController.h"
#import "ProductsViewController.h"
#import "StringUtil.h"
#import "TableViewCellProducts.h"
#import "ShopViewController.h"


@interface ProductsViewController () <ProductSingleViewControllerDelegate>{
    AppDelegate *appDelegate;
    
    __weak IBOutlet UITableView *tblVW;
    __weak IBOutlet UILabel *lblWaterMark;
    
    NSMutableArray *arrProducts;
    UIRefreshControl *refreshControl;
    
    ProductSingleViewController *productSingleViewController;
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
    [tblVW addSubview:refreshControl];
    
    [super viewDidLoad];
    
    productSingleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductSingleViewController"];
    productSingleViewController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = NO;
    
    if(arrProducts.count > 0){
        [self scrollToTop];
    }
    
    [super viewWillAppear:YES];
}

-(void)scrollToTop{
    [tblVW setContentOffset:CGPointZero animated:YES];
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
    if(arrProducts.count > 0){
        [arrProducts removeAllObjects];
    }
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
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){
                SetisAdvertiser([[JSONValue objectForKey:@"is_advertiser"] integerValue]);
                
                if ([[JSONValue objectForKey:@"detail"] isKindOfClass:[NSArray class]]){
                    NSArray *arrProductResult = [JSONValue objectForKey:@"detail"];
                
                    if([arrProductResult count] > 0){
                        for (int i = 0; i < arrProductResult.count; i++) {
                            NSMutableDictionary *dictResult;
                            dictResult = [[NSMutableDictionary alloc]init];
                            dictResult = [arrProductResult objectAtIndex:i];
                            ProductClass *productClass = [[ProductClass alloc]init];
                            
                            // Product id
                            int product_id = [[[arrProductResult objectAtIndex:i]valueForKey:@"id"]intValue];
                            productClass.product_id = [NSString stringWithFormat:@"%d",product_id];
                            
                            // Is listed
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"is_listed"]){
                                productClass.is_listed = @"Yes";
                            } else {
                                productClass.is_listed = @"No";
                            }
                            
                            // Is featured
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"is_featured"]){
                                productClass.is_featured = @"Yes";
                            } else {
                                productClass.is_featured = @"No";
                            }
                            
                            // Owner
                            productClass.owner = [[arrProductResult objectAtIndex:i]valueForKey:@"owner"];
                            
                            // Title
                            productClass.title = [[arrProductResult objectAtIndex:i]valueForKey:@"title"];
                            
                            // Slug
                            productClass.slug = [[arrProductResult objectAtIndex:i]valueForKey:@"slug"];
                            
                            // Description
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"description"] != [NSNull null]){
                                productClass.description = [[arrProductResult objectAtIndex:i]valueForKey:@"description"];
                            } else {
                                productClass.description = @"";
                            }
                            
                            // Cost
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"cost"] != [NSNull null]){
                                productClass.cost = [[arrProductResult objectAtIndex:i]valueForKey:@"cost"];
                            } else {
                                productClass.cost = @"0";
                            }
                            
                            // Promo code
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"promo_code"] != [NSNull null]){
                                productClass.promo_code = [[arrProductResult objectAtIndex:i]valueForKey:@"promo_code"];
                            } else {
                                productClass.promo_code = @"";
                            }
                            
                            // Buyers
                            productClass.buyers = [[NSMutableArray alloc]init];
                            
                            NSArray *arrBuyer = [dictResult objectForKey:@"get_buyers_info"];
                            
                            productClass.is_purchased = NO;
                            if([[dictResult objectForKey:@"get_buyers_info"] count] > 0){
                                for(int l = 0; l < [arrBuyer count]; l++){
                                    NSDictionary *dictUsers = [arrBuyer objectAtIndex:l];
                                    if([[dictUsers objectForKey:@"username"] isEqualToString:GetUserName]){
                                        productClass.is_purchased = YES;
                                        break;
                                    }
                                }
                            }
                            
                            for(int j = 0; j < arrBuyer.count; j++){
                                NSMutableDictionary *dictBuyerInfo = [[NSMutableDictionary alloc]init];
                                NSDictionary *dictUserDetail = [arrBuyer objectAtIndex:j];
                                
                                if([dictUserDetail objectForKey:@"profile_picture"] == [NSNull null]){
                                    [dictBuyerInfo setObject:@"" forKey:@"user__profile_picture"];
                                } else {
                                    NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_picture"]];
                                    
                                    [dictBuyerInfo setValue:proflURL forKey:@"user__profile_picture"];
                                }
                                if([dictUserDetail objectForKey:@"username"] == [NSNull null]){
                                    [dictBuyerInfo setObject:@"" forKey:@"user__username"];
                                } else {
                                    [dictBuyerInfo setObject:[dictUserDetail objectForKey:@"username"] forKey:@"user__username"];
                                }
                                if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]){
                                    [dictBuyerInfo setObject:@"" forKey:@"full_name"];
                                } else {
                                    [dictBuyerInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"full_name"];
                                }
                                
                                NSString *fullString;
                                NSString *userName = [dictBuyerInfo objectForKey:@"user__username"];
                                NSString *fullName = [dictBuyerInfo objectForKey:@"full_name"];
                                
                                fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
                                
                                NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                                
                                NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
                                
                                [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
                                
                                [dictBuyerInfo setValue:hogan forKey:@"usernameText"];
                                
                                [productClass.buyers addObject:dictBuyerInfo];
                            }
                            
                            // Is useable
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"is_useable"]){
                                productClass.is_useable = @"Yes";
                            } else {
                                productClass.is_useable = @"No";
                            }
                            
                            // Max downloads
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"max_downloads"] != [NSNull null]){
                                productClass.max_downloads = [[arrProductResult objectAtIndex:i]valueForKey:@"max_downloads"];
                            } else {
                                productClass.max_downloads = @"";
                            }
                            
                            // List date start
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"list_date_start"] != [NSNull null]){
                                productClass.list_date_start = [[arrProductResult objectAtIndex:i]valueForKey:@"list_date_start"];
                            } else {
                                productClass.list_date_start = @"";
                            }
                            
                            // List date end
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"list_date_end"] != [NSNull null]){
                                productClass.list_date_end = [[arrProductResult objectAtIndex:i]valueForKey:@"list_date_end"];
                            } else {
                                productClass.list_date_end = @"";
                            }
                            
                            // Use date start
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"use_date_start"] != [NSNull null]){
                                productClass.use_date_start = [[arrProductResult objectAtIndex:i]valueForKey:@"use_date_start"];
                            } else {
                                productClass.use_date_start = @"";
                            }
                            
                            // Use date end
                            if([[arrProductResult objectAtIndex:i]valueForKey:@"use_date_end"] != [NSNull null]){
                                productClass.use_date_end = [[arrProductResult objectAtIndex:i]valueForKey:@"use_date_end"];
                            } else {
                                productClass.use_date_end = @"";
                            }
                            
                            // Company logo
                            // NSString *str = [[arrProductResult objectAtIndex:i]valueForKey:@"company_logo"];
                            // NSString *newStr = [NSString stringWithFormat:@"https:%@",str];
                            // productClass.company_logo = newStr;
                            
                            [arrProducts addObject:productClass];
                        }
                        [appDelegate hideHUDForView2:self.view];
                        [self setBusy:NO];
                        [self showProducts];
                    }
                } else {
                    [refreshControl endRefreshing];
                    [self setBusy:NO];
                    lblWaterMark.hidden = NO;
                    lblWaterMark.text = [NSString stringWithFormat:@"%@", [JSONValue objectForKey:@"detail"]];
                }
            } else {
                [self setBusy:NO];
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
    [refreshControl endRefreshing];
    [tblVW reloadData];
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
    
    if(arrProducts.count <= 0){
        return cell;
    }
    
    ProductClass *productClass = [arrProducts objectAtIndex:indexPath.row];

    cell.description.text = productClass.description;
    cell.pointValue.text = [NSString stringWithFormat:@"%@ points", productClass.cost];
//    [cell.companyLogo loadImageFromURL:productClass.company_logo withTempImage:@"avatar"];
//    cell.companyLogo.layer.masksToBounds = YES;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductClass *productClass = [arrProducts objectAtIndex:indexPath.row];
    productSingleViewController.owner = productClass.owner;
//    productSingleViewController.company_logo = productClass.company_logo;
    productSingleViewController.prod_title = productClass.title;
    productSingleViewController.prod_descrip = productClass.description;
    productSingleViewController.point_value = productClass.cost;
    productSingleViewController.prod_slug = productClass.slug;
    [self.navigationController pushViewController:productSingleViewController animated:YES];
}

@end
