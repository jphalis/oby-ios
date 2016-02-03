//
//  ProductCreateViewController.m
//  OBY
//

#import "AppDelegate.h"
#import "ProductCreateViewController.h"


@interface ProductCreateViewController (){
    AppDelegate *appDelegate;
}
@end

@implementation ProductCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [AppDelegate getDelegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = YES;
    [super viewWillAppear:YES];
}

@end
