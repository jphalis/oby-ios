//
//  ViewController.m
//  OBY
//

#import "ViewController.h"
#import "ForgotViewController.h"
#import "UIViewControllerAdditions.h"
#import "StringUtil.h"
#import "defs.h"
#import "Message.h"
#import "AppDelegate.h"
#import "CutomTabViewController.h"
#import "Reachability.h"
//#import "SVWebViewController.h"
#import "SVModalWebViewController.h"


#define kOFFSET_FOR_KEYBOARD 0.65


@interface ViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    __weak IBOutlet UILabel *pageTitle;
    __weak IBOutlet UIView *viewLogin;
    __weak IBOutlet UIView *viewSignUp;
    __weak IBOutlet UIButton *btnSignupInner;
    __weak IBOutlet UIButton *btnSignInner;
    __weak IBOutlet NSLayoutConstraint *consSignupX;
    __weak IBOutlet NSLayoutConstraint *consLoginX;
    
      //Signup Txtfields
    __weak IBOutlet UITextField *txtSignupVerifyPass;
    __weak IBOutlet UITextField *txtSignupPass;
    __weak IBOutlet UITextField *txtSignupUsrName;
    __weak IBOutlet UITextField *txtSignupEmail;
    
    //Login TxtFields
    __weak IBOutlet UITextField *txtLoginPass;
    __weak IBOutlet UITextField *txtLoginUsrName;
}

- (IBAction)onForgot:(id)sender;
- (IBAction)onTapSign:(id)sender;
- (IBAction)doSignIn:(id)sender;
- (IBAction)doSignUp:(id)sender;
- (IBAction)onTermsClick:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    //[self pushingView:NO];
    
    if(GetUserName != nil){
        [self pushingView:NO];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    pageTitle.text = @"Sign in";
    UIButton *btnSel = (UIButton*)[self.view viewWithTag:1];
    UIButton *btnUel = (UIButton*)[self.view viewWithTag:2];
    [btnSel setSelected:YES];
    [btnUel setSelected:NO];
    
    btnSignInner.layer.cornerRadius = 20;
    btnSignupInner.layer.cornerRadius = 20;
    
    viewLogin.hidden = NO;
    viewSignUp.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    
  //Custom Placeholder Color
    
    UIColor *color = [UIColor whiteColor];
    txtLoginUsrName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtLoginPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtSignupUsrName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtSignupEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtSignupPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Create Password" attributes:@{NSForegroundColorAttributeName: color}];
    
    txtSignupVerifyPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Verify Password" attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onForgot:(id)sender {
    [self.view endEditing:YES];
    
    ForgotViewController *forgotViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotViewController"];
    
    [self.navigationController pushViewController:forgotViewController animated:YES];
}

- (IBAction)onTapSign:(id)sender{
    if([sender tag] == 1){
        UIButton *btnSel = (UIButton*)[self.view viewWithTag:[sender tag]];
        UIButton *btnUel = (UIButton*)[self.view viewWithTag:2];
        [btnSel setSelected:YES];
        [btnUel setSelected:NO];
       
        viewLogin.hidden = NO;
        viewSignUp.hidden = YES;
        pageTitle.text = @"Sign in";
        [self clearFields];
    } else {
        //[self swipeAnimation];
        UIButton *btnSel = (UIButton*)[self.view viewWithTag:[sender tag]];
        UIButton *btnUel = (UIButton*)[self.view viewWithTag:1];
        [btnSel setSelected:YES];
        [btnUel setSelected:NO];
        
        [self clearFields];
        
        viewLogin.hidden = YES;
        viewSignUp.hidden = NO;
        pageTitle.text = @"Sign up";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger length = [textField.text length] + [string length] - range.length;
    
   
    if(textField == txtLoginUsrName || textField == txtSignupUsrName){
        if(textField == txtSignupUsrName){
            txtSignupUsrName.text=txtSignupUsrName.text.lowercaseString;
        }
        BOOL isValidChar = [AppDelegate isValidCharacter:string filterCharSet:USERNAME];
        return isValidChar && length < 16;
    }
    return YES;
}

-(void)swipeAnimation{
    consSignupX.constant = self.view.frame.size.width;
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         consSignupX.constant = 0;
                     }
                     completion:nil
     ];
}

//TextFiled Delegate Methods

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(viewLogin.hidden == YES){
        if (textField.tag == 1){
            [txtSignupEmail becomeFirstResponder];
        } else if(textField.tag == 2) {
            [txtSignupPass becomeFirstResponder];
        } else if(textField.tag == 3) {
            [txtSignupVerifyPass becomeFirstResponder];
        } else if(textField.tag ==4 ) {
            [txtSignupVerifyPass resignFirstResponder];
        }
    } else {
        if(textField.tag == 5){
            [txtLoginPass becomeFirstResponder];
        } else if (textField.tag == 6){
            [txtLoginPass resignFirstResponder];
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    UIToolbar * keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolBar.tag = textField.tag;
    
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
    if(self.view.frame.size.height==480){
        val = 0.75;
    }else{
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
    NSLog(@"%ld",(long)sender.tag);
    
    if(viewLogin.hidden == NO){
        if (txtLoginUsrName){
            [txtLoginUsrName resignFirstResponder];
            [txtLoginPass becomeFirstResponder];
        }
    }else{
        if(sender.tag == 1){
            [txtSignupUsrName resignFirstResponder];
            [txtSignupEmail becomeFirstResponder];
        } else if(sender.tag == 2) {
            [txtSignupEmail resignFirstResponder];
            [txtSignupPass becomeFirstResponder];
        } else if(sender.tag == 3) {
            [txtSignupPass resignFirstResponder];
            [txtSignupVerifyPass becomeFirstResponder];
        }
    }
}

-(void)previousTextField:(UIBarButtonItem *)sender{
    if(viewLogin.hidden == NO){
        if (txtLoginPass) {
            [txtLoginPass resignFirstResponder];
            [txtLoginUsrName becomeFirstResponder];
        }
    } else {
        if(sender.tag == 4){
            [txtSignupVerifyPass resignFirstResponder];
            [txtSignupPass becomeFirstResponder];
        } else if(sender.tag == 3) {
            [txtSignupPass resignFirstResponder];
            [txtSignupEmail becomeFirstResponder];
        } else if(sender.tag == 2) {
            [txtSignupEmail resignFirstResponder];
            [txtSignupUsrName becomeFirstResponder];
        }
    }
}

-(void)resignKeyboard {
    [txtLoginUsrName resignFirstResponder];
    [txtLoginPass resignFirstResponder];
    [txtSignupUsrName resignFirstResponder];
    [txtSignupVerifyPass resignFirstResponder];
    [txtSignupPass resignFirstResponder];
    [txtSignupEmail resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)doSignIn:(id)sender{
    /*
    CutomTabViewController *cutomTabViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"CutomTabViewController"];
    [self.navigationController pushViewController:cutomTabViewController animated:YES];
    return;
     */
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }
    
    if ([self validateFields] == YES){
        [self doLogin];
       // NSLog(@"Successfully");
    }
}

-(void)doLogin{
    
    [self.view endEditing:YES];
    [self setBusy:YES];
    txtLoginUsrName.text = [txtLoginUsrName.text lowercaseString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *params = [NSString stringWithFormat:@"username=%@&password=%@",[txtLoginUsrName.text Trim],[txtLoginPass.text Trim]];
        NSLog(@"Login Params : %@",params);
        
        NSMutableData *bodyData = [[NSMutableData alloc] initWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
        
        // Server Header Information
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",LOGINURL]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
        [urlRequest setHTTPBody:bodyData];
        //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        //Call the Login Web services
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                [self setBusy:NO];
                                
                                if ([data length] > 0 && error == nil){
                                    NSDictionary * JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                    NSLog(@"JSONValue %@",JSONValue);
                                    
                                    if([[JSONValue objectForKey:@"userid"]integerValue]>0){
                                        SetUserName([JSONValue objectForKey:@"user"]);
                                        SetUserID([[JSONValue objectForKey:@"userid"]integerValue]);
                                        SetUserToken([JSONValue objectForKey:@"token"]);
                                        SetUserActive([[JSONValue objectForKey:@"userid"]integerValue]);
                                        SetUserPassword([txtLoginPass.text Trim]);
                                        [self performSelectorInBackground:@selector(getProfileDetails) withObject:nil];

                                        [self pushingView:YES];
                                    } else {
                                        [self showMessage:LOGIN_ERROR];
                                    }
                                    
                                } else {
                                    [self showMessage:SERVER_ERROR];
                                    [self setBusy:NO];
                                }
                            });
         }];
    });
}

-(void)getProfileDetails{
    NSString *urlString = [NSString stringWithFormat:@"%@%@/",PROFILEURL,GetUserName];
    
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    //[_request setValue:[NSString stringWithFormat:@"Token %@",GetUserToken] forHTTPHeaderField:@"Authorization"];

    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
         if(error != nil){
             NSLog(@"%@",error);
             [self setBusy:NO];
         }
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
       
             if([JSONValue isKindOfClass:[NSDictionary class]]){
                 
                 if([JSONValue allKeys].count == 1 && [JSONValue objectForKey:@"detail"]){
                     [self setBusy:NO];
                     //[self showMessage:SERVER_ERROR];
                     return;
                 }
                 
                 SetUserName([JSONValue objectForKey:@"username"]);
                 SetUserFullName([JSONValue objectForKey:@"full_name"]);
                 NSString *profilePic;
                 if([JSONValue objectForKey:@"profile_picture"] == [NSNull null]){
                     profilePic = @"";
                 } else {
                     profilePic=[JSONValue objectForKey:@"profile_picture"];
                 }
                 SetProifilePic(profilePic);

                 [self setBusy:NO];
             } else {
                 //[self setBusy:NO];
                 //[self showMessage:SERVER_ERROR];
             }
         } else {
            // [refreshControl endRefreshing];
            // [self setBusy:NO];
             //[self showMessage:SERVER_ERROR];
         }
     }];
}

-(void)pushingView :(BOOL)animation{
    CutomTabViewController *cutomTabViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CutomTabViewController"];
    [self.navigationController pushViewController:cutomTabViewController animated:animation];
}

- (IBAction)doSignUp:(id)sender{
    //[self pushingView];
    
    if ([self validateFields] == YES){
        [self doRegister];
        //NSLog(@"Successfully");
    }
}

- (IBAction)onTermsClick:(id)sender{
    if([sender tag] == 22){
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        if(networkStatus == NotReachable){
            [self showMessage:NETWORK_UNAVAILABLE];
            return;
        }
        
        // Opens TERMSURL in a modal view
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@",TERMSURL]];
        [self presentViewController:webViewController animated:YES completion:NULL];
        
        // Opens TERMSURL in Safari
        // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:TERMSURL]];
    } else {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        if(networkStatus == NotReachable) {
            [self showMessage:NETWORK_UNAVAILABLE];
            return;
        }
        
        // Opens PRIVACYURL in a modal view
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@",PRIVACYURL]];
        [self presentViewController:webViewController animated:YES completion:NULL];
        
        // Opens PRIVACYURL in Safari
        // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:PRIVACYURL]];
    }
}

-(void)doRegister{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    NSString *usname = [[txtSignupUsrName.text Trim] lowercaseString];
    
    NSString *params = [NSString stringWithFormat:@"{\"username\":\"%@\",\"email\":\"%@\",\"password\":\"%@\"}",usname,[txtSignupEmail.text Trim],[txtSignupPass.text Trim]];
    
    NSLog(@"%@",params);
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[params length]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",SIGNUPURL]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60];
    
    [urlRequest setHTTPMethod:@"POST"];
    
     NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"cutesaro", @"malliga"];
    // NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue =[NSString stringWithFormat:@"Basic %@", base64String];
    
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Call the Login Web services
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error != nil){
             NSLog(@"%@",error);
         }
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             if(JSONValue != nil){
                 NSLog(@"Jsonvalue=%@",JSONValue);
                 
                 if([[JSONValue allKeys]count] > 1){
                     
                     if([[JSONValue objectForKey:@"username"] isKindOfClass:[NSString class]]){
                         SetUserName([JSONValue objectForKey:@"username"]);
                         SetUserMail([JSONValue objectForKey:@"email"]);
                         SetUserID([[JSONValue objectForKey:@"id"]integerValue]);
                         SetUserPassword([txtSignupPass.text Trim]);
                         
                         [self getUserId];
                         [self performSelectorInBackground:@selector(getProfileDetails) withObject:nil];
                         [self pushingView:YES];
                     } else {
                         [self showMessage:USER_EXISTS_ANOTHER_USER];
                     }
                 } else {
                     if([[[JSONValue allKeys]objectAtIndex:0]isEqualToString:@"username"]){
                          [self showMessage:USER_EXISTS_ANOTHER_USER];
                         
                     } else if([[[JSONValue allKeys]objectAtIndex:0]isEqualToString:@"email"]) {
                         [self showMessage:EMAIL_EXISTS_ANOTHER_USER];
                     } else {
                         [self showMessage:SERVER_ERROR];
                     }
                 }
             } else {
                 [self showMessage:SERVER_ERROR];
             }
            [self setBusy:NO];
         } else {
            [self setBusy:NO];
             [self showMessage:SERVER_ERROR];
         }
         [self setBusy:NO];
     }];
}

-(void)getUserId{
    
}

-(void)clearFields{
    txtLoginPass.text = @"";
    txtLoginUsrName.text = @"";
    txtSignupEmail.text = @"";
    txtSignupPass.text = @"";
    txtSignupUsrName.text = @"";
    txtSignupVerifyPass.text = @"";
    
}

-(BOOL)validateFields{
    if(viewSignUp.hidden == YES){
        if ([[txtLoginUsrName.text Trim] isEmpty]){
            [self showMessage:EMPTY_USERNAME];
            return NO;
        } else if ([[txtLoginUsrName.text Trim] length] < 3) {
            [self showMessage:USERNAME_MIN_LEGTH];
            return NO;
        } else if ([[txtLoginPass.text Trim] isEmpty]) {
            [self showMessage:EMPTY_PASSWORD];
            return NO;
        } else if ([[txtLoginPass.text Trim] length] < 5 ) {
            [self showMessage:PASS_MIN_LEGTH];
            return NO ;
        }
        return YES;
    } else {
        if ([[txtSignupUsrName.text Trim] isEmpty]){
            [self showMessage:EMPTY_USERNAME];
            return NO;
        } else if ([[txtSignupUsrName.text Trim] length] < 3){
            [self showMessage:USERNAME_MIN_LEGTH];
            return NO;
        } else if ([[txtSignupEmail.text Trim] isEmpty]) {
            [self showMessage:EMPTY_EMAIL];
            return NO;
        } else if ([AppDelegate validateEmail:[txtSignupEmail.text Trim]] == NO) {
            [self showMessage:INVALID_EMAIL];
            return NO;
        } else if ([[txtSignupPass.text Trim] isEmpty]) {
            [self showMessage:EMPTY_PASSWORD];
            return NO;
        } else if ([[txtSignupVerifyPass.text Trim] isEmpty]) {
            [self showMessage:EMPTY_CNF_PASSWORD];
            return NO;
        } else if ([[txtSignupPass.text Trim] length] < 5 || [[txtSignupVerifyPass.text Trim] length] < 5 ){
            [self showMessage:PASS_MIN_LEGTH];
            return NO ;
        } else if (![[txtSignupPass.text Trim] isEqualToString:[txtSignupVerifyPass.text Trim]]) {
            [self showMessage:PASS_MISMATCH];
            return NO;
        }
        return YES;
    }
}

@end
