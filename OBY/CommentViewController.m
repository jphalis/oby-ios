//
//  CommentViewController.m
//

#import "AppDelegate.h"
#import "CommentViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "NSString+Additions.h"
#import "SCLAlertView.h"
#import "StringUtil.h"
#import "TWMessageBarManager.h"
#import "UIViewControllerAdditions.h"


@interface CommentViewController (){
    AppDelegate *appDelegate;
    
    __weak IBOutlet UITextField *txtComment;
    __weak IBOutlet UIButton *btnSubmit;
}

- (IBAction)onSubmit:(id)sender;
- (IBAction)onBack:(id)sender;

@end

@implementation CommentViewController
@synthesize photoClass,selectRow;

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self resetFields];
   
    [txtComment becomeFirstResponder];
    
    btnSubmit.layer.cornerRadius = 20;
    
    UIColor *color = [UIColor whiteColor];
    txtComment.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Add a comment" attributes:@{NSForegroundColorAttributeName: color}];
    appDelegate.tabbar.tabView.hidden = YES;
}

-(void)resetFields{
    txtComment.text = @"";
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

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([[txtComment.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:@"Please type a comment into the field." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [txtComment resignFirstResponder];
    return YES;
}

-(void)doSubmit{
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    NSString *user = [NSString stringWithFormat:@"%ld",(long)GetUserID];
    NSString *photo = photoClass.PhotoId;
    NSString *text = txtComment.text;
    NSString *parent = @"";
    
    NSString *params = [NSString stringWithFormat:@"{\"user\":\"%@\",\"parent\":\"%@\",\"photo\":\"%@\",\"text\":\"%@\"}",user,parent,photo,text];
    
//    NSLog(@"%@",params);
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[params length]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",COMMENTURL]];
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
                 [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"New comment"
                                                                description:@"Thank you for the comment!"
                                                                       type:TWMessageBarMessageTypeSuccess
                                                                   duration:3.0];
                 int commentCount = (int)[photoClass.comment_count integerValue];
                 commentCount++;
                 photoClass.comment_count = [NSString stringWithFormat:@"%d",commentCount];
                 [self setBusy:NO];
                 
                 NSMutableDictionary *dictUserInfo = [[NSMutableDictionary alloc]init];
                 
                 [dictUserInfo setValue:[JSONValue objectForKey:@"username"] forKey:@"user__username"];
                 
                 NSString *fullString;
                 NSString *fullName = [JSONValue objectForKey:@"username"];
                 NSString *userName = [JSONValue objectForKey:@"text"];
                 
                 fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
                 
                 NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                 
                 NSRange range = [fullString rangeOfString:userName options:NSBackwardsSearch];
                 
                 [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
                 
                 [dictUserInfo setValue:hogan forKey:@"usernameText"];
                 
                 [photoClass.comment_set addObject:dictUserInfo];
                 
                 [self.delegate setComment:selectRow commentCount:[NSString stringWithFormat:@"%d",commentCount]];
                 
                 doRewardCheck();
             } else {
                 showServerError();
                 [self.delegate setComment:-1 commentCount:@""];
             }
             [self setBusy:NO];
         } else {
             [self setBusy:NO];
             showServerError();
             [self.delegate setComment:-1 commentCount:@""];
             
         }
         [self setBusy:NO];
     }];
}

@end
