//
//  ChangePassViewController.m
//

#import "ChangePassViewController.h"
#import "defs.h"
#import "Message.h"
#import "StringUtil.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "TWMessageBarManager.h"


#define kOFFSET_FOR_KEYBOARD 0.65


@interface ChangePassViewController (){
    
    __weak IBOutlet UITextField *txtNewConfrmPass;
    __weak IBOutlet UITextField *txtNewPass;
    __weak IBOutlet UITextField *txtOldPass;
    __weak IBOutlet UIButton *btnSubmit;
    
}
- (IBAction)onSubmit:(id)sender;
- (IBAction)onBack:(id)sender;

@end

@implementation ChangePassViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *viewRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    btnSubmit.layer.cornerRadius = 20;
    UIColor *color = [UIColor whiteColor];
    txtOldPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Old Password" attributes:@{NSForegroundColorAttributeName: color}];
    txtNewPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"New Password" attributes:@{NSForegroundColorAttributeName: color}];
    txtNewConfrmPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{NSForegroundColorAttributeName: color}];
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

- (IBAction)onSubmit:(id)sender {
    if([self validateFields]){
        [self doSubmit];
    }
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)validateFields{
    [self.view endEditing:YES];
    if ([[txtOldPass.text Trim] isEmpty]){
        [self showMessage:EMPTY_OLD_PASSWORD];
        [txtOldPass becomeFirstResponder];
        return NO;
    } else if ([[txtNewPass.text Trim] length] < 3){
        [self showMessage:EMPTY_NEW_PASSWORD];
        return NO;
    } else if ([[txtNewConfrmPass.text Trim] isEmpty]){
        [self showMessage:EMPTY_CNF_NEW_PASSWORD];
        return NO;
    } else if ([[txtNewPass.text Trim] length] < 5 || [[txtNewConfrmPass.text Trim] length] < 5 ){
        [self showMessage:PASS_MIN_LEGTH];
        return NO ;
    } else if (![[txtNewPass.text Trim] isEqualToString:[txtNewConfrmPass.text Trim]]){
        [self showMessage:PASS_MISMATCH];
        return NO;
    } else if ([[txtNewPass.text Trim] isEqualToString:[txtOldPass.text Trim]]){
        [self showMessage:PASS_SAME];
        return NO;
    }
    return YES;
}

//TextFiled Delegate Methods

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
        if (textField.tag == 1){
            [txtNewPass becomeFirstResponder];
        } else if(textField.tag == 2){
            [txtNewConfrmPass becomeFirstResponder];
        } else if(textField.tag == 3){
            [txtNewConfrmPass resignFirstResponder];
        }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    UIToolbar * keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolBar.tag = textField.tag;
    
//    int tag = textField.tag;
    
    keyboardToolBar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *bar1 = [[UIBarButtonItem alloc]initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousTextField:)];
    bar1.tag = textField.tag;
    
    UIBarButtonItem *bar2 = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextTextField:)];
    bar2.tag = textField.tag;
    
    UIBarButtonItem *bar3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    bar3.tag = textField.tag;
    
    UIBarButtonItem *bar4 =
    [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignKeyboard)];
    bar4.tag = textField.tag;
    
    [keyboardToolBar setItems: [NSArray arrayWithObjects:
                                bar1,bar2,bar3,bar4,
                                nil]];
    textField.inputAccessoryView = keyboardToolBar;
    
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up{
    float val;
    if(self.view.frame.size.height == 480){
        val = 0.75;
    } else {
        val = kOFFSET_FOR_KEYBOARD;
    }
    
    const int movementDistance = val * textField.frame.origin.y;
    
    // tweak as needed
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

- (void)nextTextField:(UIBarButtonItem *)sender {
//    NSLog(@"%ld",(long)sender.tag);
    
        if(sender.tag == 1){
            [txtOldPass resignFirstResponder];
            [txtNewPass becomeFirstResponder];
        } else if(sender.tag == 2){
            [txtNewPass resignFirstResponder];
            [txtNewConfrmPass becomeFirstResponder];
        }
}

-(void)previousTextField:(UIBarButtonItem *)sender{
        if(sender.tag == 3){
            [txtNewConfrmPass resignFirstResponder];
            [txtNewPass becomeFirstResponder];
        } else if(sender.tag == 2){
            [txtNewPass resignFirstResponder];
            [txtOldPass becomeFirstResponder];
        }
}

-(void)resignKeyboard {
    [txtOldPass resignFirstResponder];
    [txtNewPass resignFirstResponder];
    [txtNewConfrmPass resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)doSubmit{
    [self checkNetworkReachability];
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    NSString *params =[NSString stringWithFormat:@"{\"old_password\":\"%@\",\"new_password1\":\"%@\",\"new_password2\":\"%@\"}",[txtOldPass.text Trim],[txtNewPass.text Trim],[txtNewConfrmPass.text Trim]];
    
//    NSLog(@"%@",params);
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[params length]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",CHANGEPASSURL]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
    // NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Call the Login Web services
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
//         if(error != nil){
//             NSLog(@"%@",error);
//         }
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             if(JSONValue != nil){
//                 NSLog(@"%@",JSONValue);
                 
                 if([JSONValue objectForKey:@"success"]){
                     [self showMessage:PASS_SUCCESS];
                     SetUserPassword(txtNewPass.text);
                 } else if([JSONValue objectForKey:@"old_password"]){
                     [self showMessage:INCORRECTOLDPASS];
                 }
                 [self resetFields];
             } else {
                 [self showServerError];
             }
             [self setBusy:NO];
         } else {
             [self setBusy:NO];
             [self showServerError];
         }
         [self setBusy:NO];
     }];
}

-(void)resetFields{
    txtNewPass.text = @"";
    txtNewConfrmPass.text = @"";
    txtOldPass.text = @"";
}

-(void)checkNetworkReachability{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Network Error"
                                                       description:NETWORK_UNAVAILABLE
                                                              type:TWMessageBarMessageTypeError
                                                          duration:6.0];
        //        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }
    
}

-(void)showServerError{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Server Error"
                                                   description:SERVER_ERROR
                                                          type:TWMessageBarMessageTypeError
                                                      duration:4.0];
}

@end
