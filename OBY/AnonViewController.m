//
//  AnonViewController.m
//

#import "AnonViewController.h"
#import "AppDelegate.h"


@interface AnonViewController ()<UIScrollViewDelegate>{
    AppDelegate *appDelegate;

}

- (IBAction)onBack:(id)sender;

@end

@implementation AnonViewController




//NSArray *images = [[NSArray alloc] initWithObjects:@"image1.png", @"image2.png" @"etc.png", nil];
//int count = [images count];
//int randNum = arc4random() % count;
//myImageView.image = [UIImage imageNamed:[images objectAtIndex:randNum]];




- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    self.view.backgroundColor = [UIColor colorWithHue:1 saturation:1 brightness:0 alpha:0.95];
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    appDelegate.tabbar.tabView.hidden = YES;
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
