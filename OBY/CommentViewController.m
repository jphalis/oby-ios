//
//  CommentViewController.m
//

#import "CommentViewController.h"
#import "AppDelegate.h"
#import "UIViewControllerAdditions.h"
#import "defs.h"
#import "Message.h"
#import "NSString+Additions.h"
#import "StringUtil.h"
#import "Reachability.h"
#import "TWMessageBarManager.h"
#import <KiipSDK/KiipSDK.h>


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
    txtComment.text=@"";
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
    if ([[txtComment.text Trim] isEmpty]){
        [self showMessage:@"Please type a comment"];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [txtComment resignFirstResponder];
    return YES;
}

-(void)doSubmit{
    [self checkNetworkReachability];
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
//         if(error != nil){
//             NSLog(@"%@",error);
//         }
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             if(JSONValue != nil){
//                 NSLog(@"%@",JSONValue);
                 [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"New comment"
                                                                description:@"Thank you for the comment!"
                                                                       type:TWMessageBarMessageTypeSuccess
                                                                   duration:3.0];
//                 [self showMessage:@"Thank you for the comment!"];
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
                 
                 [self doRewardCheck];
             } else {
                 [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Server Error"
                                                                description:SERVER_ERROR
                                                                       type:TWMessageBarMessageTypeError
                                                                   duration:4.0];
//                 [self showMessage:SERVER_ERROR];
                 [self.delegate setComment:-1 commentCount:@""];
             }
             [self setBusy:NO];
         } else {
             [self setBusy:NO];
             [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Server Error"
                                                            description:SERVER_ERROR
                                                                   type:TWMessageBarMessageTypeError
                                                               duration:4.0];
//             [self showMessage:SERVER_ERROR];
             [self.delegate setComment:-1 commentCount:@""];
             
         }
         [self setBusy:NO];
     }];
}

#pragma mark - KIIP

-(void)doRewardCheck{
    // Check REWARDCHECKURL
    // If `deserves_reward` == True, show Kiip reward
    // Subtract reward amount from user's available points
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@",REWARDCHECKURL];
        NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                 timeoutInterval:60];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
        [_request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
//            if(error != nil){
//                NSLog(@"%@",error);
//            }
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSString *rewardResult = [JSONValue objectForKey:@"deserves_reward"];
                if([rewardResult boolValue] == YES){
                    [[Kiip sharedInstance] saveMoment:@"putting others before yourself!" withCompletionHandler:^(KPPoptart *poptart, NSError *error){
                        if (error){
//                            NSLog(@"Something's wrong");
                            // handle with an Alert dialog.
                        }
                        if (poptart){
//                            NSLog(@"Successful moment save. Showing reward.");
                            [poptart show];
                            
                            NSString *urlString = [NSString stringWithFormat:@"%@",REWARDREDEEMEDURL];
                            NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                                     timeoutInterval:60];
                            NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
                            NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
                            NSString *base64String = [plainData base64EncodedStringWithOptions:0];
                            NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
                            [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
                            [_request setHTTPMethod:@"GET"];
                            
                            [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                            }];
                        }
                        if (!poptart){
//                            NSLog(@"Successful moment save, but no reward available.");
                        }
                    }];
                }
            }
        }];
    });
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

@end
