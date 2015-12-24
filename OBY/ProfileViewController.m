//
//  ProfileViewController.m
//

#import "ProfileViewController.h"
#import "SettingViewController.h"
#import "CreateViewController.h"
#import "AppDelegate.h"
#import "defs.h"
#import "Message.h"
#import "PhotoClass.h"
#import "ProfileClass.h"
#import "SDIAsyncImageView.h"
#import "CollectionViewCellimage.h"
#import "AnimatedMethods.h"
#import "StringUtil.h"
#import "UIImageView+WebCache.h"
#import "CustomButton.h"
#import "PhotoViewController.h"
#import "SupportViewController.h"
#import "EditProfileViewController.h"
#import "CommentViewController.h"
#import "AnimatedMethods.h"
#import "Reachability.h"
//#import "SVWebViewController.h"
#import "SVModalWebViewController.h"
#import <KiipSDK/KiipSDK.h>


@interface ProfileViewController ()<PhotoViewControllerDelegate,CommentViewControllerDelegate>{
    NSString *supportUserId;
    
    __weak IBOutlet UIImageView *imgSuportTypes;
    __weak IBOutlet UIView *viewSwipeFront;
    __weak IBOutlet UIButton *btnTopBar;
    CGRect collVwOldFrame;
    BOOL isViewUp;
    __weak IBOutlet UIView *viewTOP;
    __weak IBOutlet UILabel *lblWebsite;
    __weak IBOutlet UILabel *lblDescription;
    __weak IBOutlet UIView *viewTwo;
    __weak IBOutlet UIView *viewOne;
    __weak IBOutlet UICollectionView *collectionVW;
    __weak IBOutlet UIButton *btnSupport;
    __weak IBOutlet SDIAsyncImageView *imgProfileView;
    __weak IBOutlet UIImageView *imgBackView;
    NSMutableArray *arrPhotsList;
    __weak IBOutlet UILabel *lblProfileName;
    AppDelegate *appDelegate;
    __weak IBOutlet UILabel *lblSupporting;
    __weak IBOutlet UILabel *lblSupporters;
    
    NSInteger tapCellIndex;
    NSIndexPath *previousIndexPath;
    NSMutableArray *arrImages;
    __weak IBOutlet UIPageControl *pgControl;
     UIRefreshControl *refreshControl;
    
    NSMutableDictionary *dictProfileInformation;
     PhotoViewController *photoViewController;
    
    CommentViewController *commentViewController;
    
    __weak IBOutlet UIButton *btnAdd;
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
    
NSLog(@"url=%@",userURL);
    
    photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    photoViewController.delegate = self;
    
    commentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentViewController.delegate = self;
    
    pgControl.numberOfPages = 2;
    pgControl.currentPage = 1;
    
    pgControl.pageIndicatorTintColor = [UIColor redColor];
    
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
   // [collectionVW addGestureRecognizer:longPressCollectionView];

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
        NSLog(@"couldn't find index path");
    } else {
        static int i = 0;
        i++;
        if(i == 1){
            return;
        }

        PhotoClass *photoClass = [arrPhotsList objectAtIndex:indexPath.row];
        photoViewController.photoURL = photoClass.photo;
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
    
    [btnTopBar setTitle:[userURL lastPathComponent] forState:UIControlStateNormal];
    
    appDelegate.tabbar.tabView.hidden = YES;
    
    if([[userURL lastPathComponent]isEqualToString:GetUserName]){
        btnAdd.hidden = NO;
    } else {
        btnAdd.hidden = YES;
    }

    [self checkUser];
    
    if(GetisUpdate == YES){
        SetisUpdate(NO);
        [self getProfileDetails];
    }
}

-(void)checkUser{
    if([[userURL lastPathComponent]isEqualToString:GetUserName]){
        if(self.view.frame.size.height == 480 &&self.view.frame.size.width == 320){
            
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
        if(gestureRecognizer.direction==UISwipeGestureRecognizerDirectionLeft){
            
            [UIView animateWithDuration:0.5
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
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionTransitionFlipFromTop
                             animations:^{
                                
                                 pgControl.currentPage = 1;
                                 
                                 viewOne.frame = CGRectMake(0, viewOne.frame.origin.y, self.view.frame.size.width, viewOne.frame.size.height);
                                 
                                 viewTwo.frame = CGRectMake(+self.view.frame.size.width, viewTwo.frame.origin.y, self.view.frame.size.width, viewTwo.frame.size.height);
                                 
                             }
                             completion:^(BOOL finished) {
                                 
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
    CreateViewController *createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateViewController"];
    [self.navigationController pushViewController:createViewController animated:YES];
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
    
    ProfileClass *profileClass=[dictProfileInformation objectForKey:@"ProfileInfo"];
    
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
//        NSURL *webpageUrl;
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
        NSLog(@"user");
        
        EditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
        [self.navigationController pushViewController:editProfileViewController animated:YES];
    } else {
        //return;
        [self doSupport:(int)[sender tag]];
    }
}

-(void)doSupport :(int) option{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }
    
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
    
    //Call the Login Web services
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error != nil){
             NSLog(@"%@",error);
         }
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             if(JSONValue != nil){
                  // NSLog(@"Jsonvalue=%@",JSONValue);
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
                         
                         NSMutableDictionary *dictFollowerInfo=[[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail=[arrFollower objectAtIndex:j];
                         
                         // NSLog(@"%@",[dictUserDetail objectForKey:@"user__username"]);
                         
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
                         NSString *userName=[dictFollowerInfo objectForKey:@"user__username"];
                         NSString *fullName=[dictFollowerInfo objectForKey:@"user__full_name"];
                         
                         fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
                         
                         NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                         
                         NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
                         
                         [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
                         
                         [dictFollowerInfo setValue:hogan forKey:@"usernameText"];
                         
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
                     [self showMessage:SERVER_ERROR];
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

-(void)getProfileDetails{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [refreshControl endRefreshing];
        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }

    [self setBusy:YES];
  
    NSString *urlString = [NSString stringWithFormat:@"%@",userURL];
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
             //NSLog(@"%@",JSONValue);
            
             if(arrPhotsList.count > 0){
                 [arrPhotsList removeAllObjects];
             }
             
             if([JSONValue isKindOfClass:[NSDictionary class]]){
                 
                 /*
                 SetUserName([JSONValue objectForKey:@"username"]);
                 SetUserFullName([JSONValue objectForKey:@"full_name"]);
                 NSString *profilePic;
                 if([JSONValue objectForKey:@"profile_picture"]==[NSNull null]){
                     profilePic=@"";
                 }else{
                     profilePic=[JSONValue objectForKey:@"profile_picture"];
                 }
                 SetProifilePic(profilePic);
                  */
                 
                 if([JSONValue allKeys].count == 1 && [JSONValue objectForKey:@"detail"]){
                     [self setBusy:NO];
                     [self showMessage:SERVER_ERROR];
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
                 profileClass.arrphoto_set = [[NSMutableArray alloc]init];
                     
                 NSArray *arrPhotoset=[JSONValue objectForKey:@"photo_set"];
                 for(int i = 0; i < arrPhotoset.count; i++){
                     NSMutableDictionary *dictResult;
                     dictResult = [[NSMutableDictionary alloc]init];
                     dictResult = [arrPhotoset objectAtIndex:i];
                       
                     PhotoClass *phClas = [[PhotoClass alloc]init];
                     phClas.category_url = [dictResult objectForKey:@"category_url"];
                     phClas.photo = [dictResult objectForKey:@"photo"];
                     phClas.comment_count = [dictResult objectForKey:@"comment_count"];
                  // phClas.comment_set = [dictResult objectForKey:@"comment_set"];
                     phClas.created = [dictResult objectForKey:@"created"];
                     phClas.creator = [[dictResult objectForKey:@"creator"] uppercaseString];
                     phClas.creator_url = [dictResult objectForKey:@"creator_url"];
                     phClas.description = [dictResult objectForKey:@"description"];
                         
                     int userId = [[dictResult objectForKey:@"id"]intValue];
                     int linke_Count = [[dictResult objectForKey:@"like_count"]intValue];
                         
                     phClas.PhotoId = [NSString stringWithFormat:@"%d",userId];
                     phClas.like_count = [NSString stringWithFormat:@"%d",linke_Count];
                 //  phClas.likers = [dictResult objectForKey:@"likers"];
                     phClas.likers = [[NSMutableArray alloc]init];
                     phClas.comment_set = [[NSMutableArray alloc]init];
                         
                     NSArray *arrLiker = [dictResult objectForKey:@"get_likers_info"];
                         
                     phClas.isLike = NO;
                     if([[dictResult objectForKey:@"get_likers_info"] count] > 0){
                         for(int l = 0; l < [arrLiker count]; l++){
                             NSDictionary *dictUsers = [arrLiker objectAtIndex:l];
                             if([[dictUsers objectForKey:@"username"] isEqualToString:GetUserName]){
                                 phClas.isLike = YES;
                                 break;
                             }
                         }
                     }

                     for(int j = 0; j < arrLiker.count; j++){
                         NSMutableDictionary *dictFollowerInfo=[[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail=[arrLiker objectAtIndex:j];
                             
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
                             [dictFollowerInfo setObject:@"" forKey:@"full_name"];
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"full_name"];
                         }
                             
                         NSString *fullString;
                         NSString *userName = [dictFollowerInfo objectForKey:@"user__username"];
                         NSString *fullName = [dictFollowerInfo objectForKey:@"full_name"];
                             
                         fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
                             
                         NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                             
                         NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
                             
                         [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
                             
                         [dictFollowerInfo setValue:hogan forKey:@"usernameText"];
                             
                         [phClas.likers addObject:dictFollowerInfo];
                     }
                         
                     NSArray *arrCommentSet=[dictResult objectForKey:@"comment_set"];
                         
                     for(int k = 0; k < arrCommentSet.count; k++){
                         NSMutableDictionary *dictFollowerInfo=[[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail=[arrCommentSet objectAtIndex:k];
                             
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
                         NSString *fullName=[[dictFollowerInfo objectForKey:@"user__username"]lastPathComponent];
                         NSString *userName=[dictFollowerInfo objectForKey:@"text"];
                             
                         fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
                             
                         NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                             
                         NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
                             
                         [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
                             
                         [dictFollowerInfo setValue:hogan forKey:@"usernameText"];
                             
                         [phClas.comment_set addObject:dictFollowerInfo];
                     }

                     phClas.modified = [dictResult objectForKey:@"modified"];
                     phClas.photo = [dictResult objectForKey:@"photo"];
                     phClas.slug = [dictResult objectForKey:@"slug"];

                     [arrPhotsList addObject:phClas];
                 }
                     
                 if([JSONValue objectForKey:@"profile_picture"]==[NSNull null]){
                     profileClass.profile_picture=@"";
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
                         
                     // Change this to a Django field that abbreviates extensions
                     NSInteger followerCount = arrFollower.count;
                     NSInteger followingCount = arrFollowing.count;
                         
                     profileClass.followers_count = [NSString stringWithFormat:@"%ld",(long)followerCount];
                     profileClass.following_count = [NSString stringWithFormat:@"%ld",(long)followingCount];
                     profileClass.arrfollowers = [[NSMutableArray alloc]init];
                     profileClass.arrfollowings = [[NSMutableArray alloc]init];
                         
                     for(int j = 0; j < arrFollower.count; j++){
                         NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail = [arrFollower objectAtIndex:j];
                             
                     // NSLog(@"%@",[dictUserDetail objectForKey:@"user__username"]);

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
             [self showMessage:SERVER_ERROR];
         }
     } else {
         [refreshControl endRefreshing];
         [self setBusy:NO];
         [self showMessage:SERVER_ERROR];
     }
 }];
}

-(void)removeImage{
    [photoViewController.view removeFromSuperview];
}

-(void)showProfileInfo{
    ProfileClass *profileClass = [dictProfileInformation objectForKey:@"ProfileInfo"];
    lblProfileName.text = profileClass.username;
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
    
    cell.lblName.text = photoClass.creator;
    //NSLog(@"%@",photoClass.creator);
    
    cell.lblDescription.text = photoClass.description;
    cell.lblLikes.text = [NSString stringWithFormat:@"%@",photoClass.like_count];
    cell.lblComments.text = [NSString stringWithFormat:@"%@",photoClass.comment_count];
    
    [cell.imgView loadImageFromURL:photoClass.photo withTempImage:@""];

    //cell.imgView.shouldShowLoader=YES;
    
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
    
    /*
    if(tapCellIndex==indexPath.row){
        cell.imgView.hidden=YES;
        cell.viewInfo.hidden=NO;
    }else{
        cell.imgView.hidden=NO;
        cell.viewInfo.hidden=YES;
    }
    */
    
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionView cellForItemAtIndexPath:indexPath];
    //CollectionViewCellimage *PreivousCell=(CollectionViewCellimage *)[collectionView cellForItemAtIndexPath:previousIndexPath];
    
    //tapCellIndex=indexPath.row;
    
    if(currentCell.imgView.image == nil){
        NSLog(@"cont tab");
        return;
    }
    
    UIImage *img = [UIImage imageNamed:@"spining"];
    if([AnimatedMethods firstimage:img isEqualTo:currentCell.imgView.image]){
        return;
    }
    tapCellIndex = indexPath.row;
    PhotoClass *photoClass = [arrPhotsList objectAtIndex:indexPath.row];
    photoViewController.photoURL = photoClass.photo;
    photoViewController.view.frame = appDelegate.window.frame;
    
    [appDelegate.window addSubview:photoViewController.view];

    /*
    if(previousIndexPath==nil){
        currentCell.imgView.hidden=YES;
        currentCell.viewInfo.hidden=NO;
        
        [AnimatedMethods animatedFlipFromRight:currentCell.imgView secondView:currentCell.viewInfo];
        
        previousIndexPath=indexPath;
        return;
    }
    
    if (previousIndexPath.row!=indexPath.row) {
        currentCell.imgView.hidden=YES;
        currentCell.viewInfo.hidden=NO;
        
        [AnimatedMethods animatedFlipFromRight:currentCell.imgView secondView:currentCell.viewInfo];
        
        if(previousIndexPath!=nil){
            PreivousCell.imgView.hidden=NO;
            PreivousCell.viewInfo.hidden=YES;
            // [AnimatedMethods animatedFlipFrombottom:PreivousCell.imgView secondView:PreivousCell.viewInfo];
        }
        previousIndexPath=indexPath;
    }else{
        currentCell.imgView.hidden=NO;
        currentCell.viewInfo.hidden=YES;
        [AnimatedMethods animatedFlipFromLeft:currentCell.imgView secondView:currentCell.viewInfo];
        
        previousIndexPath=nil;
    }
    */
}

-(void)onCommentList:(CustomButton*)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionVW cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    photoClass = [arrPhotsList objectAtIndex:sender.tag];
    
    SupportViewController *supportViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SupportViewController"];
    
    if([currentCell.lblComments.text isEqualToString:@"0"]){
        return;
    }
    
    supportViewController.pageTitle = @"Comments";
    supportViewController.arrDetails = photoClass.comment_set.copy;
    [self.navigationController pushViewController:supportViewController animated:YES];
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
    //SetisComment(YES);
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
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }

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
        [dictUser setValue:GetUserFullName forKey:@"full_name"];
        
        NSString *fullString;
        NSString *fullName = [dictUser objectForKey:@"user__username"];
        NSString *userName = [dictUser objectForKey:@"full_name"];
        
        fullString=[NSString stringWithFormat:@"%@ %@",fullName,userName];
        
        NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
        
        NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
        
        [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
        [dictUser setValue:hogan forKey:@"usernameText"];
        
        [photoClass.likers addObject:dictUser];
        
        likecount++;
        [self doRewardCheck];
    }
    
    photoClass.like_count = [NSString stringWithFormat:@"%d",likecount];
    photoClass.isLike =! photoClass.isLike;
    
    currentCell.imgLike.image = [UIImage imageNamed:@"like_icon"];
    if(photoClass.isLike){
        currentCell.imgLike.image = [UIImage imageNamed:@"likeselect"];
    }
    currentCell.lblLikes.text = [NSString stringWithFormat:@"%@",photoClass.like_count];
    
    [self doLike:photoClass selectCell:currentCell];
    NSLog(@"Like Click");
}

-(void)doLike : (PhotoClass *)photoClass selectCell:(CollectionViewCellimage *)selectCell {
    [self.view endEditing:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // [self setBusy:YES];
        NSString *strURL=[NSString stringWithFormat:@"%@%@/",LIKEURL,photoClass.PhotoId];
        
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
        
        //Call the Login Web services
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
             if(error != nil){
                 NSLog(@"%@",error);
             }
            
             if ([data length] > 0 && error == nil){
                 NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                 if(JSONValue != nil){
                     //  NSLog(@"Jsonvalue=%@",JSONValue);
                     if([[JSONValue allKeys]count] > 5){
                         /*
                          int likecount=(int)[photoClass.like_count integerValue];
                          if(photoClass.isLike){
                          likecount--;
                          }else{
                          likecount++;
                          }
                          
                          photoClass.like_count=[NSString stringWithFormat:@"%d",likecount];
                          photoClass.isLike=!photoClass.isLike;
                          
                          selectCell.imgLike.image=[UIImage imageNamed:@"like_icon"];
                          if(photoClass.isLike){
                          selectCell.imgLike.image=[UIImage imageNamed:@"likeselect"];
                          }
                          selectCell.lblLikes.text=[NSString stringWithFormat:@"%@",photoClass.like_count];
                          */
                         // [collectionVWHome reloadData];
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
        CGRect newFrame = CGRectMake(0, -viewTopHeight+20, self.view.frame.size.width, viewTopHeight);
        
        collVwOldFrame = collectionVW.frame;
        
        [self moveView:viewTOP fromFrame:viewTOP.frame toFrame:newFrame];
        
        CGRect collFrame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40);
        [AnimatedMethods animatedMovingView:collectionVW fromFrame:collVwOldFrame toFrame:collFrame];
    }
}

-(void)moveView:(UIView *)fromView fromFrame:(CGRect) fromFrame toFrame:(CGRect) toFrame{
    fromView.frame = fromFrame;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         fromView.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         viewSwipeFront.hidden = YES;
                         btnTopBar.hidden = NO;
                         NSLog(@"completion block");
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
                         NSLog(@"completion block");
                     }
     ];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}

- (IBAction)onTopBarClick:(id)sender {
    isViewUp = NO;
    btnTopBar.hidden = YES;
    CGFloat viewTopHeight = viewTOP.frame.size.height;
    CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, viewTopHeight);
    CGRect collFrame = CGRectMake(0, 40+btnTopBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-20-btnTopBar.frame.size.height);
    
    [self moveingView:viewTOP fromFrame:viewTOP.frame toFrame:newFrame];
    [AnimatedMethods animatedMovingView:collectionVW fromFrame:collFrame toFrame:collVwOldFrame];
    
   // btnTopBar.hidden=YES;
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
            if(error != nil){
                NSLog(@"%@",error);
            }
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSString *rewardResult = [JSONValue objectForKey:@"deserves_reward"];
                if([rewardResult boolValue] == YES){
                    [[Kiip sharedInstance] saveMoment:@"putting others before yourself!" withCompletionHandler:^(KPPoptart *poptart, NSError *error){
                        if (error){
                            NSLog(@"Something's wrong");
                            // handle with an Alert dialog.
                        }
                        if (poptart){
                            NSLog(@"Successful moment save. Showing reward.");
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
                            NSLog(@"Successful moment save, but no reward available.");
                        }
                    }];
                }
            }
        }];
    });
}

@end
