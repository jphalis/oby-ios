//
//  ProductCreateViewController.m
//  OBY
//

#import "AppDelegate.h"
#import "ProductCreateViewController.h"


@interface ProductCreateViewController (){
    AppDelegate *appDelegate;
}

- (IBAction)onBack:(id)sender;

@end

@implementation ProductCreateViewController

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = YES;
    [super viewWillAppear:YES];
}

@end
