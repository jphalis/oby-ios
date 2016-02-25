//
//  ProductSingleViewController.m
//

#import "AnimatedMethods.h"
#import "AppDelegate.h"
#import "CustomButton.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "ProductClass.h"
#import "ProductSingleViewController.h"
#import "Reachability.h"
#import "TWMessageBarManager.h"
#import "UIImageView+WebCache.h"


@interface ProductSingleViewController (){
    AppDelegate *appDelegate;
    
    NSMutableArray *arrSingleProduct;
    UIRefreshControl *refreshControl;
    __weak IBOutlet UIImageView *companyLogo;
    __weak IBOutlet UILabel *prodTitle;
    __weak IBOutlet UILabel *prodDescrip;
    __weak IBOutlet UIButton *redeemBtn;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onRedeem:(id)sender;
@end

@implementation ProductSingleViewController
@synthesize owner, company_logo, prod_title, prod_descrip, point_value, prod_slug;

- (void)viewDidLoad {
    [super viewDidLoad];
    arrSingleProduct = [[NSMutableArray alloc]init];

    appDelegate = [AppDelegate getDelegate];
    
    companyLogo.image = company_logo;
    prodTitle.text = prod_title;
    prodDescrip.text = prod_descrip;
    [redeemBtn setTitle:[NSString stringWithFormat:@"Redeem (%@ points)", point_value] forState:UIControlStateNormal];
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = YES;
    [super viewWillAppear:YES];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onRedeem:(id)sender {
    checkNetworkReachability();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@/3/",FLAGURL];
        NSURL *url = [NSURL URLWithString:strURL];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"POST"];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            [self setBusy:NO];
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success"
                                                           description:REPORT_PHOTO
                                                                  type:TWMessageBarMessageTypeSuccess
                                                              duration:3.0];
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collecinview delegates

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
