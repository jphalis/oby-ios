//
//  ShopViewController.m
//  OBY
//

#import "AppDelegate.h"
#import "ProductCreateViewController.h"
#import "ShopViewController.h"
#import "ProductsViewController.h"

#import "SettingViewController.h"


@interface ShopViewController (){
    AppDelegate *appDelegate;
}

@property (nonatomic) CAPSPageMenu *pageMenu;

- (IBAction)onAddNew:(id)sender;

@end

@implementation ShopViewController

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    [super viewDidLoad];
    
    ProductsViewController *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductsViewController"];
    controller1.title = @"Available";
    ProductsViewController *controller2 = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductsViewController"];
    controller2.title = @"Redeemed";

    NSArray *controllerArray = @[controller1, controller2];
    NSDictionary *parameters = @{
                                CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor lightGrayColor],
                                CAPSPageMenuOptionSelectionIndicatorColor: [UIColor orangeColor],
                                CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"Gibson-Semibold" size:14.0],
                                CAPSPageMenuOptionMenuHeight: @(40.0),
                                CAPSPageMenuOptionMenuItemWidth: @(160.0),
                                CAPSPageMenuOptionCenterMenuItems: @(YES)
                                };

    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 64.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    [self.view addSubview:_pageMenu.view];
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = NO;
    [super viewWillAppear:YES];
}

- (IBAction)onAddNew:(id)sender {
    ProductCreateViewController *productCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductCreateViewController"];
    [self.navigationController pushViewController:productCreateViewController animated:YES];
}
@end
