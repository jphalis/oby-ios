//
//  ShopViewController.m
//  OBY
//

#import "ProductCreateViewController.h"
#import "ShopViewController.h"

#import "CreateViewController.h"
#import "SettingViewController.h"


@interface ShopViewController ()

@property (nonatomic) CAPSPageMenu *pageMenu;

- (IBAction)onAddNew:(id)sender;

@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CreateViewController *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateViewController"];
    controller1.title = @"Available";
    SettingViewController *controller2 = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    controller2.title = @"Redeemed";

    NSArray *controllerArray = @[controller1, controller2];
    NSDictionary *parameters = @{
                                CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor orangeColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:13.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(160.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };

    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 64.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    [self.view addSubview:_pageMenu.view];
}

- (IBAction)onAddNew:(id)sender {
    ProductCreateViewController *productCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductCreateViewController"];
    [self.navigationController pushViewController:productCreateViewController animated:YES];
    
}
@end
