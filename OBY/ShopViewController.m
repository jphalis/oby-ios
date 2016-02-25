//
//  ShopViewController.m
//  OBY
//

#import "AppDelegate.h"
#import "defs.h"
#import "ProductCreateViewController.h"
#import "ProductsViewController.h"
#import "ProfileClass.h"
#import "SettingViewController.h"
#import "ShopViewController.h"


@interface ShopViewController (){
    AppDelegate *appDelegate;
}

@property (nonatomic) CAPSPageMenu *pageMenu;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;

- (IBAction)onAddNew:(id)sender;

@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [AppDelegate getDelegate];
    
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
    [self addChildViewController:_pageMenu];
    [self.view addSubview:_pageMenu.view];
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = NO;

    if (GetisAdvertiser == 1){
        self.createBtn.hidden = NO;
    } else {
        self.createBtn.hidden = YES;
    }
    
    [super viewWillAppear:YES];
}

- (IBAction)onAddNew:(id)sender {
    ProductCreateViewController *productCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductCreateViewController"];
    [self.navigationController pushViewController:productCreateViewController animated:YES];
}
@end
