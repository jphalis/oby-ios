//
//  ProfileViewController.m
//

#import "AnimatedMethods.h"
#import "AnonViewController.h"
#import "AppDelegate.h"
#import "CollectionViewCellimage.h"
#import "CommentListViewController.h"
#import "CommentViewController.h"
#import "CreateViewController.h"
#import "CustomButton.h"
#import "defs.h"
#import "EditProfileViewController.h"
#import "GlobalFunctions.h"
#import "HashtagViewController.h"
#import "KILabel.h"
#import "PhotoClass.h"
#import "PhotoViewController.h"
#import "ProfileClass.h"
#import "ProfileViewController.h"
#import "SDIAsyncImageView.h"
#import "SettingViewController.h"
#import "StringUtil.h"
#import "SupportViewController.h"
#import "SVModalWebViewController.h"
#import "TWMessageBarManager.h"
#import "UIImageView+WebCache.h"


@interface ProfileViewController ()<PhotoViewControllerDelegate,CommentViewControllerDelegate> {
    AppDelegate *appDelegate;
    
    __weak IBOutlet UIImageView *imgSuportTypes;
    __weak IBOutlet UIView *viewSwipeFront;
    __weak IBOutlet UIButton *btnTopBar;
    __weak IBOutlet UIView *viewTOP;
    __weak IBOutlet UILabel *lblWebsite;
    __weak IBOutlet UILabel *lblDescription;
    __weak IBOutlet UIView *viewTwo;
    __weak IBOutlet UIView *viewOne;
    __weak IBOutlet UICollectionView *collectionVW;
    __weak IBOutlet UIButton *btnSupport;
    __weak IBOutlet SDIAsyncImageView *imgProfileView;
    __weak IBOutlet UIImageView *imgBackView;
    __weak IBOutlet UILabel *lblProfileName;
    __weak IBOutlet UILabel *lblSupporting;
    __weak IBOutlet UILabel *lblSupporters;
    __weak IBOutlet UIPageControl *pgControl;
    __weak IBOutlet UIButton *btnAdd;
    
    BOOL isViewUp;
    NSString *supportUserId;
    NSInteger tapCellIndex;
    NSIndexPath *previousIndexPath;
    NSMutableArray *arrPhotsList;
    NSMutableArray *arrImages;
    NSMutableDictionary *dictProfileInformation;
    UIRefreshControl *refreshControl;
    CGRect collVwOldFrame;
    
    PhotoViewController *photoViewController;
    CommentViewController *commentViewController;
}

- (IBAction)onAddClick:(id)sender;
- (IBAction)onSettingClick:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onViewList:(id)sender;
- (IBAction)onURLClick:(id)sender;
- (IBAction)onSupport:(id)sender;

@end

@implementation ProfileViewController
@synthesize userURL;

- (void)viewDidLoad {
    SetisUpdate(NO);
    dictProfileInformation = [[NSMutableDictionary alloc]init];
    
    photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    photoViewController.delegate = self;
    
    commentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentViewController.delegate = self;
    
    pgControl.numberOfPages = 2;
    pgControl.currentPage = 1;
    
    pgControl.pageIndicatorTintColor = [UIColor colorWithRed:(230/255.0) green:(33/255.0) blue:(23/255.0) alpha:1.0];
    
    appDelegate = [AppDelegate getDelegate];
    
    arrPhotsList = [[NSMutableArray alloc]init];
    tapCellIndex = -1;
    arrImages = [[NSMutableArray alloc]init];
    
    previousIndexPath = nil;
    
    viewOne.frame = CGRectMake(0, viewOne.frame.origin.y, self.view.frame.size.width, viewOne.frame.size.height);
    
    viewTwo.frame = CGRectMake(self.view.frame.size.width,
                             viewTwo.frame.origin.y, self.view.frame.size.width, viewTwo.frame.size.height);
    
    UISwipeGestureRecognizer *viewOneSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeViewOne:)];
    viewOneSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [viewOne addGestureRecognizer:viewOneSwipe];
    
    UISwipeGestureRecognizer *viewTwoSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeViewTwo:)];
    viewTwoSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [viewTwo addGestureRecognizer:viewTwoSwipe];
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
    
    UISwipeGestureRecognizer *viewTop = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeTop:)];
    viewTop.direction = UISwipeGestureRecognizerDirectionUp;
    [viewSwipeFront addGestureRecognizer:viewTop];
    
    UILongPressGestureRecognizer *longPressCollectionView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressCollectionView.minimumPressDuration = 1;

    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [collectionVW addSubview:refreshControl];
    
    collectionVW.alwaysBounceVertical = YES;
    
    if(self.view.frame.size.height == 480 && self.view.frame.size.width == 320){
        imgProfileView.frame = CGRectMake(imgProfileView.frame.origin.x+2, imgProfileView.frame.origin.y, 60, 60);
        
       imgSuportTypes.frame = CGRectMake(imgSuportTypes.frame.origin.x, imgSuportTypes.frame.origin.y, imgSuportTypes.frame.size.width+10, imgSuportTypes.frame.size.height);
    }
    
    imgProfileView.layer.cornerRadius = imgProfileView.frame.size.width / 2;
    imgProfileView.layer.masksToBounds = YES;
    
    [self getProfileDetails];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:collectionVW];
    
    NSIndexPath *indexPath = [collectionVW indexPathForItemAtPoint:p];
    if (indexPath == nil){

    } else {
        static int i = 0;
        i++;
        if(i == 1){
            return;
        }

        PhotoClass *photoClass = [arrPhotsList objectAtIndex:indexPath.row];
        photoViewController.photoURL = photoClass.photo;
        photoViewController.photoDeleteURL = photoClass.photo_url;
        photoViewController.photoCreator = photoClass.creator;
        photoViewController.view.frame = appDelegate.window.frame;
        
        [self.view addSubview:photoViewController.view];
    }
}

-(void)startRefresh{
    [self getProfileDetails];
}

-(void)swipeTop:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self viewUp];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [viewSwipeFront bringSubviewToFront:collectionVW];
    
    [btnTopBar setTitle:[NSString stringWithFormat:@"Scroll to top  ( %@ )", [userURL lastPathComponent]] forState:UIControlStateNormal];
    
    appDelegate.tabbar.tabView.hidden = YES;
    
    if([[userURL lastPathComponent]isEqualToString:GetUserName]){
        [btnAdd setImage:[UIImage imageNamed:@"add_icon_profile"] forState:UIControlStateNormal];
        btnAdd.tag = 1;
//        btnAdd.hidden = NO;
    } else {
        [btnAdd setImage:[UIImage imageNamed:@"dot-more"] forState:UIControlStateNormal];
        btnAdd.tag = 2;
//        btnAdd.hidden = YES;
    }

    [self checkUser];
    
    if(GetisUpdate == YES){
        SetisUpdate(NO);
        [self getProfileDetails];
    }
}

-(void)checkUser{
    if([[userURL lastPathComponent]isEqualToString:GetUserName]){
        if(self.view.frame.size.height == 480 && self.view.frame.size.width == 320){
            
        }
        imgSuportTypes.image = [UIImage imageNamed:@"setting_icon_profile"];
        btnSupport.tag = 1;
    } else {
        NSString *profileUserName = [userURL lastPathComponent];
        
        if([appDelegate.arrSupports containsObject:profileUserName]){
            imgSuportTypes.image = [UIImage imageNamed:@"supporting.png"];
            btnSupport.tag = 2;
        } else {
            imgSuportTypes.image = [UIImage imageNamed:@"support.png"];
            btnSupport.tag = 3;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)swipeViewOne:(UISwipeGestureRecognizer *)gestureRecognizer{
    if(viewOne.frame.origin.x == 0.0){
        if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft){
            
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionTransitionFlipFromTop
                             animations:^{
                                 pgControl.currentPage = 0;
                                 viewOne.frame = CGRectMake(-self.view.frame.size.width, viewOne.frame.origin.y, self.view.frame.size.width, viewOne.frame.size.height);
                                 viewTwo.frame = CGRectMake(0, viewTwo.frame.origin.y, self.view.frame.size.width, viewTwo.frame.size.height);
                             }
                             completion:^(BOOL finished) {
                                 
                             }
             ];
        } else {
            return;
        }
    } else {
        
    }
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)swipeViewTwo:(UISwipeGestureRecognizer *)gestureRecognizer{
    if(viewTwo.frame.origin.x == 0.0){
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionTransitionFlipFromTop
                         animations:^{
                             pgControl.currentPage = 1;
                             viewOne.frame = CGRectMake(0, viewOne.frame.origin.y, self.view.frame.size.width, viewOne.frame.size.height);
                             viewTwo.frame = CGRectMake(+self.view.frame.size.width, viewTwo.frame.origin.y, self.view.frame.size.width, viewTwo.frame.size.height);
                         }
                         completion:^(BOOL finished){
                                 
                         }
         ];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onAddClick:(id)sender {
    if([sender tag] == 1){
        CreateViewController *createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateViewController"];
        [self.navigationController pushViewController:createViewController animated:YES];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Block"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to block this user?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alert.delegate = self;
        alert.tag = 100;
        [alert show];
    } else if(buttonIndex == 1){
//        NSLog(@"Cancel button clicked");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1 ) {
        checkNetworkReachability();
        ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *strURL = [NSString stringWithFormat:@"%@%@/",BLOCKURL,profileClass.Id];
            NSURL *url = [NSURL URLWithString:strURL];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setTimeoutInterval:60];
            [urlRequest setHTTPMethod:@"POST"];
            NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
            NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *base64String = [plainData base64EncodedStringWithOptions:0];
            NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
            [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
            [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                [self setBusy:NO];
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success"
                                                               description:BLOCK_USER
                                                                      type:TWMessageBarMessageTypeSuccess
                                                                  duration:3.0];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        });
    }
}

- (IBAction)onSettingClick:(id)sender {
    SettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onViewList:(id)sender {
    SupportViewController *supportViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SupportViewController"];
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    
    if([sender tag] == 1){
        if([lblSupporters.text isEqualToString:@"0"]){
            return;
        }
        supportViewController.pageTitle = @"Supporters";
        supportViewController.arrDetails = profileClass.arrfollowers.copy;
    } else {
        if([lblSupporting.text isEqualToString:@"0"]){
            return;
        }
        supportViewController.pageTitle = @"Supporting";
        supportViewController.arrDetails = profileClass.arrfollowings.copy;
    }
    [self.navigationController pushViewController:supportViewController animated:YES];
}

- (IBAction)onURLClick:(id)sender {
    if(![lblWebsite.text isEqualToString:@""]){
        NSString *urlString = lblWebsite.text;
        NSString *modalWebpageUrl;
        
        // Use with Safari view
//        if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
//            webpageUrl = [NSURL URLWithString:urlString];
//        } else {
//            webpageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlString]];
//        }
        
        // Use with modal view
        if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]){
            modalWebpageUrl = [NSString stringWithFormat:@"%@",urlString];
        } else {
            modalWebpageUrl = [NSString stringWithFormat:@"http://%@", urlString];
        }
        
        // Opens webpageUrl in a modal view
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:modalWebpageUrl];
        [self presentViewController:webViewController animated:YES completion:NULL];
        
        // Opens webpageUrl in Safari
        // [[UIApplication sharedApplication]openURL:webpageUrl];
    }
}

- (IBAction)onSupport:(id)sender{
    if([sender tag] == 1){
        EditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
        [self.navigationController pushViewController:editProfileViewController animated:YES];
    } else {
        [self doSupport:(int)[sender tag]];
    }
}

-(void)doSupport:(int)option{
    checkNetworkReachability();
    
    [self.view endEditing:YES];
    [self setBusy:YES];
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    NSString *strURL = [NSString stringWithFormat:@"%@%@/",SUPPORTURL,profileClass.Id];
    NSURL *url = [NSURL URLWithString:strURL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60];
    [urlRequest setHTTPMethod:@"POST"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             if(JSONValue != nil){

                 if([[JSONValue allKeys]count] > 1){
                     NSMutableArray *arrFollower = [JSONValue objectForKey:@"get_followers_info"];

                     NSInteger followerCount = arrFollower.count;
                     
                     profileClass.followers_count = [NSString stringWithFormat:@"%ld",(long)followerCount];
                     
                     if(profileClass.arrfollowers.count == 0){
                         profileClass.arrfollowers = [[NSMutableArray alloc]init];
                     }
                     if(profileClass.arrfollowers.count > 0){
                         [profileClass.arrfollowers removeAllObjects];
                     }
                     
                     for(int j = 0; j < arrFollower.count; j++){
                         
                         NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail = [arrFollower objectAtIndex:j];
                         
                         if([dictUserDetail objectForKey:@"user__profile_picture"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__profile_picture"];
                         } else {
                             NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"user__profile_picture"]];
                             
                             [dictFollowerInfo setValue:proflURL forKey:@"user__profile_picture"];
                         }
                         if([dictUserDetail objectForKey:@"user__username"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__username"];
                             
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__username"] forKey:@"user__username"];
                         }
                         if([dictUserDetail objectForKey:@"user__full_name"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__full_name"] forKey:@"user__full_name"];
                         }
                         
//                         NSString *fullString;
//                         NSString *userName = [dictFollowerInfo objectForKey:@"user__username"];
//                         NSString *fullName = [dictFollowerInfo objectForKey:@"user__full_name"];
//                         fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
//                         NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
//                         NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
//                         [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
//                         [dictFollowerInfo setValue:hogan forKey:@"usernameText"];
                         
                         [profileClass.arrfollowers addObject:dictFollowerInfo];
                     }
                     
                     if(option == 2){
                         for(int i = 0; i < appDelegate.arrSupports.count; i++){
                             if([[appDelegate.arrSupports objectAtIndex:i]isEqualToString:profileClass.username]){
                                 [appDelegate.arrSupports removeObjectAtIndex:i];
                             }
                         }
                     } else {
                         [appDelegate.arrSupports addObject:profileClass.username];
                     }
  
                     [self checkUser];
                     [self showProfileInfo];
                 } else {
                     showServerError();
                 }
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

-(void)getProfileDetails{
    checkNetworkReachability();
    [self setBusy:YES];
  
    NSString *urlString = [NSString stringWithFormat:@"%@",userURL];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
         if(error != nil){
             [self setBusy:NO];
         }
        
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
             if(arrPhotsList.count > 0){
                 [arrPhotsList removeAllObjects];
             }
             
             if([JSONValue isKindOfClass:[NSDictionary class]]){
                 
                 if([JSONValue allKeys].count == 1 && [JSONValue objectForKey:@"detail"]){
                     [self setBusy:NO];
                     //             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                     //             NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                     [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Forbidden Error"
                                                                    description:[JSONValue objectForKey:@"detail"]
                                                                           type:TWMessageBarMessageTypeError
                                                                       duration:4.0];
                     [self.navigationController popViewControllerAnimated:YES];
                     return;
                 }
                 ProfileClass *profileClass = [[ProfileClass alloc]init];
                 
                 int profileId = [[JSONValue objectForKey:@"id"]intValue];
                 profileClass.Id = [NSString stringWithFormat:@"%d",profileId];
                 profileClass.username = [JSONValue objectForKey:@"username"];
                 profileClass.account_url = [JSONValue objectForKey:@"account_url"];
                 profileClass.email = [JSONValue objectForKey:@"email"];
                 profileClass.full_name = [JSONValue objectForKey:@"full_name"];
                 profileClass.bio = [JSONValue objectForKey:@"bio"];
                 profileClass.website = [JSONValue objectForKey:@"website"];
                 profileClass.gender = [JSONValue objectForKey:@"gender"];
                 BOOL isVerified = [[JSONValue objectForKey:@"is_verified"]boolValue];
                 profileClass.is_verified = isVerified;
                 BOOL isAdvertiser = [[JSONValue objectForKey:@"is_advertiser"]boolValue];
                 profileClass.is_advertiser = isAdvertiser;
                 profileClass.arrphoto_set = [[NSMutableArray alloc]init];
                     
                 NSArray *arrPhotoset = [JSONValue objectForKey:@"photo_set"];
                 for(int i = 0; i < arrPhotoset.count; i++){
                     NSMutableDictionary *dictResult;
                     dictResult = [[NSMutableDictionary alloc]init];
                     dictResult = [arrPhotoset objectAtIndex:i];
                       
                     PhotoClass *photoClass = [[PhotoClass alloc]init];
                     photoClass.category_url = [dictResult objectForKey:@"category_url"];
                     photoClass.photo_url = [dictResult objectForKey:@"photo_url"];
                     photoClass.photo = [dictResult objectForKey:@"photo"];
                     photoClass.comment_count = [NSString abbreviateNumber:[[dictResult objectForKey:@"comment_count"]intValue]];
                     photoClass.created = [dictResult objectForKey:@"created"];
                     photoClass.creator = [[dictResult objectForKey:@"creator"] uppercaseString];
                     photoClass.creator_url = [dictResult objectForKey:@"creator_url"];
                     photoClass.description = [dictResult objectForKey:@"description"];
                         
                     int userId = [[dictResult objectForKey:@"id"]intValue];
                     photoClass.PhotoId = [NSString stringWithFormat:@"%d",userId];
                     photoClass.like_count = [NSString abbreviateNumber:[[dictResult objectForKey:@"like_count"]intValue]];
                     photoClass.likers = [[NSMutableArray alloc]init];
                     photoClass.comment_set = [[NSMutableArray alloc]init];
                         
                     NSArray *arrLiker = [dictResult objectForKey:@"get_likers_info"];
                         
                     photoClass.isLike = NO;
                     if([[dictResult objectForKey:@"get_likers_info"] count] > 0){
                         for(int l = 0; l < [arrLiker count]; l++){
                             NSDictionary *dictUsers = [arrLiker objectAtIndex:l];
                             if([[dictUsers objectForKey:@"username"] isEqualToString:GetUserName]){
                                 photoClass.isLike = YES;
                                 break;
                             }
                         }
                     }

                     for(int j = 0; j < arrLiker.count; j++){
                         NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail = [arrLiker objectAtIndex:j];
                             
                         if([dictUserDetail objectForKey:@"profile_picture"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__profile_picture"];
                         } else {
                             NSString *proflURL=[NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_picture"]];
                             [dictFollowerInfo setValue:proflURL forKey:@"user__profile_picture"];
                         }

                         if([dictUserDetail objectForKey:@"username"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__username"];
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"username"] forKey:@"user__username"];
                         }
                             
                         if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                         }
                             
                         NSString *fullString;
                         NSString *userName = [dictFollowerInfo objectForKey:@"user__username"];
                         NSString *fullName = [dictFollowerInfo objectForKey:@"user__full_name"];
                             
                         fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
                             
                         NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                             
                         NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
                             
                         [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
                             
                         [dictFollowerInfo setValue:hogan forKey:@"usernameText"];
                             
                         [photoClass.likers addObject:dictFollowerInfo];
                     }
                         
                     NSArray *arrCommentSet=[dictResult objectForKey:@"comment_set"];
                         
                     for(int k = 0; k < arrCommentSet.count; k++){
                         NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail = [arrCommentSet objectAtIndex:k];
                             
                         if([dictUserDetail objectForKey:@"profile_picture"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__profile_picture"];
                         } else {
                             NSString *proflURL=[NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_picture"]];
                             [dictFollowerInfo setValue:proflURL forKey:@"user__profile_picture"];
                         }
                         if([dictUserDetail objectForKey:@"user"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__username"];
                         } else {
                             [dictFollowerInfo setObject:[[dictUserDetail objectForKey:@"user"]lastPathComponent] forKey:@"user__username"];
                         }
                         if([dictUserDetail objectForKey:@"text"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"text"];
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"text"] forKey:@"text"];
                         }
                             
                         NSString *fullString;
                         NSString *userName = [[dictFollowerInfo objectForKey:@"user__username"]lastPathComponent];
                         NSString *fullName = [dictFollowerInfo objectForKey:@"text"];
                         fullString = [NSString stringWithFormat:@"%@ %@",userName,fullName];
                         NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                         NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
                         [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
                         [dictFollowerInfo setValue:hogan forKey:@"usernameText"];
                             
                         [photoClass.comment_set addObject:dictFollowerInfo];
                     }

                     photoClass.modified = [dictResult objectForKey:@"modified"];
                     photoClass.photo = [dictResult objectForKey:@"photo"];
                     photoClass.slug = [dictResult objectForKey:@"slug"];

                     [arrPhotsList addObject:photoClass];
                 }
                     
                 if([JSONValue objectForKey:@"profile_picture"] == [NSNull null]){
                     profileClass.profile_picture = @"";
                 } else {
                     profileClass.profile_picture = [JSONValue objectForKey:@"profile_picture"];
                 }
            
                 if([JSONValue objectForKey:@"follower"] == [NSNull null]){
                     profileClass.followers_count = @"0";
                     profileClass.following_count = @"0";
                 } else {
                     NSDictionary *dictFollower = [JSONValue objectForKey:@"follower"];
                     NSMutableArray *arrFollower = [dictFollower objectForKey:@"get_followers_info"];
                     NSMutableArray *arrFollowing = [dictFollower objectForKey:@"get_following_info"];
                     
                     if ([[dictFollower objectForKey:@"get_followers_count"]intValue] > 0) {
                         profileClass.followers_count = [NSString abbreviateNumber:[[dictFollower objectForKey:@"get_followers_count"]intValue]];
                     } else {
                         profileClass.followers_count = @"0";
                     }
                     if ([[dictFollower objectForKey:@"get_following_count"]intValue] > 0) {
                         profileClass.following_count = [NSString abbreviateNumber:[[dictFollower objectForKey:@"get_following_count"]intValue]];
                     } else {
                         profileClass.following_count = @"0";
                     }
                     
                     profileClass.arrfollowers = [[NSMutableArray alloc]init];
                     profileClass.arrfollowings = [[NSMutableArray alloc]init];
                         
                     for(int j = 0; j < arrFollower.count; j++){
                         NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail = [arrFollower objectAtIndex:j];

                         if([dictUserDetail objectForKey:@"user__profile_picture"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__profile_picture"];
                         } else {
                             NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"user__profile_picture"]];
                             [dictFollowerInfo setValue:proflURL forKey:@"user__profile_picture"];
                         }
                             
                         if([dictUserDetail objectForKey:@"user__username"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__username"];
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__username"] forKey:@"user__username"];
                         }
                             
                         if([dictUserDetail objectForKey:@"user__full_name"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                         } else {
                         [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__full_name"] forKey:@"user__full_name"];
                         }

                         [profileClass.arrfollowers addObject:dictFollowerInfo];
                     }
                     for(int k = 0; k < arrFollowing.count; k++){
                         NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail = [arrFollowing objectAtIndex:k];

                         if([dictUserDetail objectForKey:@"user__profile_picture"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__profile_picture"];
                         } else {
                             NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"user__profile_picture"]];
                             [dictFollowerInfo setValue:proflURL forKey:@"user__profile_picture"];
                         }
                         if([dictUserDetail objectForKey:@"user__username"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__username"];
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__username"] forKey:@"user__username"];
                         }
                         if([dictUserDetail objectForKey:@"user__full_name"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__full_name"] forKey:@"user__full_name"];
                         }
                             
                         NSString *fullString;
                         NSString *userName = [dictFollowerInfo objectForKey:@"user__username"];
                         NSString *fullName = [dictFollowerInfo objectForKey:@"user__full_name"];
                         fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
                         NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                         NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
                         [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];

                         [dictFollowerInfo setValue:hogan forKey:@"usernameText"];
                             
                         [profileClass.arrfollowings addObject:dictFollowerInfo];
                     }
                 }
                     
                 [dictProfileInformation setObject:profileClass forKey:@"ProfileInfo"];
                 [self setBusy:NO];
                 [self showProfileInfo];
         } else {
             [refreshControl endRefreshing];
             [self setBusy:NO];
             showServerError();
         }
     } else {
         [refreshControl endRefreshing];
         [self setBusy:NO];
         showServerError();
     }
 }];
}

-(void)removeImage{
    [photoViewController.view removeFromSuperview];
}

-(void)showProfileInfo{
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    
    if (profileClass.is_verified){
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"verify"];
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", profileClass.username]];
        [myString appendAttributedString:attachmentString];
        lblProfileName.attributedText = myString;
    } else {
        lblProfileName.text = profileClass.username;
    }
    
    lblSupporters.text = profileClass.followers_count;
    lblSupporting.text = profileClass.following_count;
    [imgProfileView loadImageFromURL:profileClass.profile_picture withTempImage:@"avatar"];
    lblDescription.text = profileClass.bio;
    lblWebsite.text = profileClass.website;
    
    [refreshControl endRefreshing];
    [collectionVW reloadData];
}

#pragma mark - Collecinview delegates

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [arrPhotsList count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellimage *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCell" forIndexPath:indexPath];
   
    PhotoClass *photoClass = [arrPhotsList objectAtIndex:indexPath.row];
    
    // Change words that start with # to blue
//    NSString *aString = [NSString stringWithFormat:@"%@", photoClass.description];
//    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:aString];
//    NSArray *words = [aString componentsSeparatedByString:@" "];
//    for (NSString *word in words){
//        if ([word hasPrefix:@"#"]) {
//            NSRange range = [aString rangeOfString:word];
//            [attribString addAttribute:NSForegroundColorAttributeName value:[AnimatedMethods colorFromHexString:@"#185b8b"] range:range];
//        }
//    }
//    cell.lblDescription.attributedText = attribString;
    
    // Handles gesture taps for mentions, hashtags, and urls
    KILabel *gestureLabel = (KILabel *)[cell lblDescription];
    KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedUser:string cellForRowAtIndexPath:indexPath];
    };
    KILinkTapHandler tapTagHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedHashtag:string cellForRowAtIndexPath:indexPath];
    };
    
    gestureLabel.userHandleLinkTapHandler = tapHandler;
    //    gestureLabel.urlLinkTapHandler = tapHandler;
    gestureLabel.hashtagLinkTapHandler = tapTagHandler;
    
    cell.lblName.text = photoClass.creator;
    cell.lblDescription.text = photoClass.description;
    cell.lblLikes.text = [NSString stringWithFormat:@"%@",photoClass.like_count];
    cell.lblComments.text = [NSString stringWithFormat:@"%@",photoClass.comment_count];
    
    [cell.imgView loadImageFromURL:photoClass.photo withTempImage:@"blankImage"];

    //cell.imgView.shouldShowLoader = YES;
    
    //[cell.imgView sd_setImageWithURL:[NSURL URLWithString:photoClass.photo] placeholderImage:[UIImage imageNamed:@"testLoader.gif"]];
    
    cell.lblLikes.textColor = [AnimatedMethods colorFromHexString:@"#cacaca"];
    cell.lblComments.textColor = [AnimatedMethods colorFromHexString:@"#cacaca"];
    
    cell.lblLikeBack.backgroundColor = [UIColor whiteColor];
    cell.lblLikeBack.layer.borderColor = [AnimatedMethods colorFromHexString:@"#cacaca"].CGColor;
    cell.lblLikeBack.layer.borderWidth = 1;
    cell.lblLikeBack.layer.cornerRadius = 6;
    cell.layer.masksToBounds = YES;
    
    cell.lblComentBack.backgroundColor = [UIColor whiteColor];
    cell.lblComentBack.layer.borderColor = [AnimatedMethods colorFromHexString:@"#cacaca"].CGColor;
    cell.lblComentBack.layer.borderWidth = 1;
    cell.lblComentBack.layer.cornerRadius = 6;
    cell.layer.masksToBounds = YES;
    
    cell.imgLike.image = [UIImage imageNamed:@"like_icon"];
    if(photoClass.isLike){
        cell.imgLike.image = [UIImage imageNamed:@"likeselect"];
    }
    
    [cell.btnUserName setTag:indexPath.row];
    [cell.btnUserName addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btnLike setTag:indexPath.row];
    [cell.btnLike addTarget:self action:@selector(onLike:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btnComment setTag:indexPath.row];
    [cell.btnComment addTarget:self action:@selector(onComment:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btnLikeList setTag:indexPath.row];
    [cell.btnLikeList addTarget:self action:@selector(onLikeList:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btnCommentList setTag:indexPath.row];
    [cell.btnCommentList addTarget:self action:@selector(onCommentList:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tappedUser:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [NSString stringWithFormat:@"%@", link];
    NSString *newTitle = [title substringFromIndex:1];
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    NSString *usrURL = [NSString stringWithFormat:@"%@%@/",PROFILEURL,newTitle];
    profileViewController.userURL = usrURL;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)tappedHashtag:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [NSString stringWithFormat:@"%@", link];
    NSString *newTitle = [title substringFromIndex:1];
    newTitle = [newTitle lowercaseString];
    HashtagViewController *hashtagViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HashtagViewController"];
    NSString *tagURL = [NSString stringWithFormat:@"%@%@",HASHTAGURL,newTitle];
    hashtagViewController.tagURL = tagURL;
    hashtagViewController.titleLabel = [title uppercaseString];
    [self.navigationController pushViewController:hashtagViewController animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionView cellForItemAtIndexPath:indexPath];
    //CollectionViewCellimage *PreivousCell=(CollectionViewCellimage *)[collectionView cellForItemAtIndexPath:previousIndexPath];
    
    //tapCellIndex=indexPath.row;
    
    if(currentCell.imgView.image == nil){
        return;
    }
    
    UIImage *img = [UIImage imageNamed:@"blankImage"];
    if([AnimatedMethods firstimage:img isEqualTo:currentCell.imgView.image]){
        return;
    }
    tapCellIndex = indexPath.row;
    PhotoClass *photoClass = [arrPhotsList objectAtIndex:indexPath.row];
    photoViewController.photoURL = photoClass.photo;
    photoViewController.photoDeleteURL = photoClass.photo_url;
    photoViewController.photoCreator = photoClass.creator;
    photoViewController.view.frame = appDelegate.window.frame;
    
    [appDelegate.window addSubview:photoViewController.view];
}

-(void)onCommentList:(CustomButton*)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionVW cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    photoClass = [arrPhotsList objectAtIndex:sender.tag];
    
    CommentListViewController *commentListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentListViewController"];
    
    if([currentCell.lblComments.text isEqualToString:@"0"]){
        return;
    }
    commentListViewController.arrDetails = photoClass.comment_set.copy;
    [self.navigationController pushViewController:commentListViewController animated:YES];
}

-(void)onLikeList:(CustomButton*)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionVW cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    photoClass = [arrPhotsList objectAtIndex:sender.tag];
    
    SupportViewController *supportViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SupportViewController"];
    
    if([currentCell.lblLikes.text isEqualToString:@"0"]){
        return;
    }
    
    supportViewController.pageTitle = @"Likers";
    supportViewController.arrDetails = photoClass.likers.copy;
    [self.navigationController pushViewController:supportViewController animated:YES];
}

-(void)showUser:(CustomButton*)sender{
  PhotoClass *photoClass = [arrPhotsList objectAtIndex:sender.tag];
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    
    if([photoClass.creator_url isEqualToString:userURL]){
        return;
    }
    
    profileViewController.userURL = photoClass.creator_url;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

-(void)onComment:(CustomButton*)sender{
    PhotoClass *photoClass;
    photoClass = [arrPhotsList objectAtIndex:sender.tag];
    commentViewController.selectRow = (int)sender.tag;
    commentViewController.photoClass = photoClass;
    [self.navigationController pushViewController:commentViewController animated:YES];
}

-(void)setComment:(int)selectIndex commentCount:(NSString *)countStr{
    if(selectIndex >= 0){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectIndex inSection:0];
        CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionVW cellForItemAtIndexPath:indexPath];
        currentCell.lblComments.text = countStr;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onLike:(CustomButton*)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionVW cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    photoClass = [arrPhotsList objectAtIndex:sender.tag];
    
    checkNetworkReachability();

    int likecount = (int)[photoClass.like_count integerValue];
    if(photoClass.isLike){
        for(int i = 0; i < photoClass.likers.count; i++){
            NSMutableDictionary *dict = [photoClass.likers objectAtIndex:i];
            
            if ([[dict objectForKey:@"user__username"]isEqualToString:GetUserName]){
                [photoClass.likers removeObjectAtIndex:i];
            }
        }
        likecount--;
    } else {
        NSMutableDictionary *dictUser = [[NSMutableDictionary alloc]init];
        [dictUser setValue:GetProifilePic forKey:@"user__profile_picture"];
        [dictUser setValue:GetUserName forKey:@"user__username"];
        [dictUser setValue:GetUserFullName forKey:@"user__full_name"];
        
        NSString *fullString;
        NSString *userName = [dictUser objectForKey:@"user__username"];
        NSString *fullName = [dictUser objectForKey:@"user__full_name"];
        fullString = [NSString stringWithFormat:@"%@ %@",userName,fullName];
        NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
        NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
        [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
        [dictUser setValue:hogan forKey:@"usernameText"];
        
        [photoClass.likers addObject:dictUser];
        
        likecount++;
        doRewardCheck();
    }
    
    photoClass.like_count = [NSString stringWithFormat:@"%d",likecount];
    photoClass.isLike =! photoClass.isLike;
    
    currentCell.imgLike.image = [UIImage imageNamed:@"like_icon"];
    if(photoClass.isLike){
        currentCell.imgLike.image = [UIImage imageNamed:@"likeselect"];
    }
    currentCell.lblLikes.text = [NSString stringWithFormat:@"%@",photoClass.like_count];
    
    [self doLike:photoClass selectCell:currentCell];
}

-(void)doLike:(PhotoClass *)photoClass selectCell:(CollectionViewCellimage *)selectCell {
    [self.view endEditing:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // [self setBusy:YES];
        NSString *strURL = [NSString stringWithFormat:@"%@%@/",LIKEURL,photoClass.PhotoId];
        NSURL *url = [NSURL URLWithString:strURL];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60];
        [urlRequest setHTTPMethod:@"POST"];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            
             if ([data length] > 0 && error == nil){
                 NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                 if(JSONValue != nil){

                     if([[JSONValue allKeys]count] > 5){

                     } else {
                         //[self showMessage:SERVER_ERROR];
                     }
                 } else {
                     // [self showMessage:SERVER_ERROR];
                 }
                 [self setBusy:NO];
             } else {
                 [self setBusy:NO];
                 //[self showMessage:SERVER_ERROR];
             }
             [self setBusy:NO];
         }];
    });
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    /*
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if(translation.y > 0){
        // react to dragging down
    }else{
        if(isViewUp==NO){
            isViewUp=YES;
            
            CGFloat viewTopHeight = viewTOP.frame.size.height;
            CGRect newFrame =CGRectMake(0, -viewTopHeight+20, self.view.frame.size.width, viewTopHeight);
            
            collVwOldFrame=collectionVW.frame;
            
            btnTopBar.hidden=NO;
            
            [self moveView:viewTOP fromFrame:viewTOP.frame toFrame:newFrame];
            CGRect collFrame =CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40);
            [AnimatedMethods animatedMovingView:collectionVW fromFrame:collVwOldFrame toFrame:collFrame];
        }
        // react to dragging up
    }
 */
}

-(void)viewUp{
    if(isViewUp == NO){
        isViewUp = YES;
        
        CGFloat viewTopHeight = viewTOP.frame.size.height;
        CGRect newFrame = CGRectMake(0, -viewTopHeight+30, self.view.frame.size.width, viewTopHeight);
        
        collVwOldFrame = collectionVW.frame;
        
        [self moveView:viewTOP fromFrame:viewTOP.frame toFrame:newFrame];
        
        CGRect collFrame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50);
        [AnimatedMethods animatedMovingView:collectionVW fromFrame:collVwOldFrame toFrame:collFrame];
    }
}

-(void)moveView:(UIView *)fromView fromFrame:(CGRect) fromFrame toFrame:(CGRect) toFrame{
    fromView.frame = fromFrame;
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         fromView.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         viewSwipeFront.hidden = YES;
                         btnTopBar.hidden = NO;
                         pgControl.hidden = YES;
                     }
     ];
}

-(void)moveingView:(UIView *)fromView fromFrame:(CGRect) fromFrame toFrame:(CGRect) toFrame{
    fromView.frame = fromFrame;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         fromView.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         viewSwipeFront.hidden = NO;
                     }
     ];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}

- (IBAction)onTopBarClick:(id)sender {
    isViewUp = NO;
    btnTopBar.hidden = YES;
    pgControl.hidden = NO;
    CGFloat viewTopHeight = viewTOP.frame.size.height;
    CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, viewTopHeight);
    CGRect collFrame = CGRectMake(0, 50+btnTopBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-30-btnTopBar.frame.size.height);
    
    if(arrPhotsList.count > 0){
        [self scrollToTop];
    }
    [self moveingView:viewTOP fromFrame:viewTOP.frame toFrame:newFrame];
    [AnimatedMethods animatedMovingView:collectionVW fromFrame:collFrame toFrame:collVwOldFrame];
}

-(void)scrollToTop{
    [UIView animateWithDuration:0.5 animations:^(void){
        [collectionVW scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

@end
