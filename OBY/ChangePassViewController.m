//
//  ChangePassViewController.m
//

#import "AppDelegate.h"
#import "ChangePassViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "SCLAlertView.h"
#import "StringUtil.h"


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
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    btnSubmit.layer.cornerRadius = 20;
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
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([[txtOldPass.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_OLD_PASSWORD closeButtonTitle:@"OK" duration:0.0f];
        [txtOldPass becomeFirstResponder];
        return NO;
    } else if ([[txtNewPass.text Trim] length] < 3){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_NEW_PASSWORD closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtNewConfrmPass.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_CNF_NEW_PASSWORD closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtNewPass.text Trim] length] < 5 || [[txtNewConfrmPass.text Trim] length] < 5 ){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:PASS_MIN_LEGTH closeButtonTitle:@"OK" duration:0.0f];
        return NO ;
    } else if (![[txtNewPass.text Trim] isEqualToString:[txtNewConfrmPass.text Trim]]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:PASS_MISMATCH closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtNewPass.text Trim] isEqualToString:[txtOldPass.text Trim]]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:PASS_SAME closeButtonTitle:@"OK" duration:0.0f];
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
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    NSString *params =[NSString stringWithFormat:@"{\"old_password\":\"%@\",\"new_password1\":\"%@\",\"new_password2\":\"%@\"}",[txtOldPass.text Trim],[txtNewPass.text Trim],[txtNewConfrmPass.text Trim]];
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
        
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             
             if(JSONValue != nil){
                 
                 if([JSONValue objectForKey:@"success"]){
                     alert.showAnimationType = SlideInFromLeft;
                     alert.hideAnimationType = SlideOutToBottom;
                     [alert showSuccess:@"Success" subTitle:PASS_SUCCESS closeButtonTitle:@"Done" duration:0.0f];
                     SetUserPassword(txtNewPass.text);
                 } else if([JSONValue objectForKey:@"old_password"]){
                     alert.showAnimationType = SlideInFromLeft;
                     alert.hideAnimationType = SlideOutToBottom;
                     [alert showNotice:self title:@"Notice" subTitle:INCORRECTOLDPASS closeButtonTitle:@"OK" duration:0.0f];
                 }
                 [self resetFields];
             } else {
                 showServerError();
             }
             [self setBusy:NO];
         } else {
             [self setBusy:NO];
             showServerError();
         }
         [self setBusy:NO];
     }];
}

-(void)resetFields{
    txtNewPass.text = @"";
    txtNewConfrmPass.text = @"";
    txtOldPass.text = @"";
}

@end
