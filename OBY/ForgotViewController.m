//
//  ForgotViewController.m
//

#import "ForgotViewController.h"
#import "defs.h"
#import "Message.h"
#import "StringUtil.h"
#import "Reachability.h"


@interface ForgotViewController (){
    __weak IBOutlet UIButton *btnSubmit;
    __weak IBOutlet UITextField *txtEmail;
}
- (IBAction)onBack:(id)sender;
- (IBAction)onSubmit:(id)sender;

@end

@implementation ForgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *viewRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    btnSubmit.layer.cornerRadius=20;
    
    UIColor *color = [UIColor whiteColor];
    txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    
    [super viewWillAppear:YES];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
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

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSubmit:(id)sender {
    if([self validateFields]){
        [self doSubmit];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [txtEmail resignFirstResponder];
    return YES;
}

-(BOOL)validateFields{
    if ([[txtEmail.text Trim] isEmpty]){
        [self showMessage:EMPTY_EMAIL];
        return NO;
    }else if ([AppDelegate validateEmail:[txtEmail.text Trim]] == NO) {
        [self showMessage:INVALID_EMAIL];
        return NO;
    }
    return YES;
}

-(void)clearFileds{
    txtEmail.text=@"";
}

-(void)doSubmit{
    Reachability *reachability=[Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus=[reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }
    
    [self.view endEditing:YES];
    [self setBusy:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *params = [NSString stringWithFormat:@"email=%@",[txtEmail.text Trim]];
        NSLog(@"Login Params : %@",params);
        
        NSMutableData *bodyData = [[NSMutableData alloc] initWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
        
        // Server Header Information
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",FORGOTPASSURL]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
        [urlRequest setHTTPBody:bodyData];
        //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        //Call the Login Web services
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                [self setBusy:NO];
                                
                                if ([data length] > 0 && error == nil){
                                    NSDictionary * JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                    
                                    NSLog(@"JSONValue %@",JSONValue);
                                    if([JSONValue isKindOfClass:[NSDictionary class]]){
                                        
                                        if([[JSONValue objectForKey:@"success"]isEqualToString:@"Password reset e-mail has been sent."]){
                                             [self showMessage:PASS_SENT];
                                        }else{
                                            [self showMessage:PASS_FAILURE];
                                        }
                                        [self clearFileds];
                                        
                                    }else{
                                        [self showMessage:SERVER_ERROR];
                                    }
                                }else{
                                    [self showMessage:SERVER_ERROR];
                                    [self setBusy:NO];
                                }
                            });
         }];
    });
}

@end
