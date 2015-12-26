//
//  HomeViewController.m
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "AFHTTPClient.h"
#import "AnimatedMethods.h"
#import "AppDelegate.h"
#import "CollectionViewCellimage.h"
#import "CommentViewController.h"
#import "CustomButton.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "HomeViewController.h"
#import "HTHorizontalSelectionList.h"
#import "PhotoClass.h"
#import "PhotoViewController.h"
#import "ProfileClass.h"
#import "ProfileViewController.h"
#import "SDIAsyncImageView.h"
#import "SupportViewController.h"
#import "UIImageView+WebCache.h"

#import "KILabel.h"


@interface HomeViewController ()<HTHorizontalSelectionListDataSource,HTHorizontalSelectionListDelegate,PhotoViewControllerDelegate,CommentViewControllerDelegate>{
    AppDelegate *appDelegate;
    
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UIScrollView *scrolVw;
    __weak IBOutlet UICollectionView *collectionVWHome;
    
    BOOL isMenuChoosed;
    NSInteger tapCellIndex;
    NSIndexPath *previousIndexPath;
    NSMutableArray *arrCategoryPhotos;
    UIRefreshControl *refreshControl;
    NSString *CategoryURL;
    PhotoViewController *photoViewController;
    CommentViewController *commentViewController;
}

@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (nonatomic, strong) NSArray *categoryList;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tapCellIndex = -1;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    previousIndexPath = nil;
    
    appDelegate = [AppDelegate getDelegate];
    
    photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    photoViewController.delegate = self;
    
    commentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentViewController.delegate = self;
    
    arrCategoryPhotos = [[NSMutableArray alloc]init];
    
    self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, scrolVw.frame.origin.y, self.view.frame.size.width, scrolVw.frame.size.height)];
    self.selectionList.backgroundColor = [UIColor clearColor];
    self.selectionList.selectionIndicatorColor = [UIColor lightGrayColor];
    self.selectionList.selectionIndicatorStyle = HTHorizontalSelectionIndicatorStyleButtonBorder;
    
    self.selectionList.delegate = self;
    self.selectionList.dataSource = self;
    self.selectionList.backgroundColor = [AnimatedMethods colorFromHexString:@"#353535"];
    
    //[UIColor colorWithPatternImage:[UIImage imageNamed:@"buttons_bg.png"]];
    
    self.categoryList = @[@"Popular",
                          @"Just Because",
                          @"Sports & Fitness",
                          @"Nightlife",
                          @"Style",
                          @"Lol",
                          @"Pay it Forward",
                          @"University",
                          @"Food",
                          @"Fall"];
    
    [self.view addSubview:self.selectionList];

    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [collectionVWHome addSubview:refreshControl];
    
    collectionVWHome.alwaysBounceVertical = YES;

    UILongPressGestureRecognizer *longPressCollectionView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressCollectionView.minimumPressDuration = 1;
    
    [self performSelectorInBackground:@selector(getSupportList) withObject:nil];
    [self getHomePageDetails];
}

-(void)setComment:(int)selectIndex commentCount:(NSString *)countStr{
    if(selectIndex >= 0){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectIndex inSection:0];
        CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionVWHome cellForItemAtIndexPath:indexPath];
        currentCell.lblComments.text = countStr;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)ClickCell:(UITapGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:collectionVWHome];
    
    NSIndexPath *indexPath = [collectionVWHome indexPathForItemAtPoint:p];
    if (indexPath == nil){

    } else {
        [self collectionView:collectionVWHome didSelectItemAtIndexPath:indexPath];
    }
}

-(void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:collectionVWHome];
        
    NSIndexPath *indexPath = [collectionVWHome indexPathForItemAtPoint:p];
    if (indexPath == nil){

    } else {
        static int i = 0;
        i++;
        if(i == 1){
            return;
        }
        PhotoClass *photoClass;
        
        if(isMenuChoosed){
            photoClass = [arrCategoryPhotos objectAtIndex:indexPath.row];
        } else {
            photoClass = [appDelegate.arrPhotos objectAtIndex:indexPath.row];
        }
        
        photoViewController.photoURL = photoClass.photo;
        photoViewController.view.frame = appDelegate.window.frame;
        
        [appDelegate.window addSubview:photoViewController.view];
    }
}

-(void)doubleClick:(UITapGestureRecognizer *)gestureDouble{
    CGPoint p = [gestureDouble locationInView:collectionVWHome];
    
    NSIndexPath *indexPath = [collectionVWHome indexPathForItemAtPoint:p];
    if (indexPath == nil){
//        NSLog(@"couldn't find index path");
    } else {
        PhotoClass *photoClass;
        
        if(isMenuChoosed){
            photoClass = [arrCategoryPhotos objectAtIndex:indexPath.row];
        } else {
            photoClass = [appDelegate.arrPhotos objectAtIndex:indexPath.row];
        }
        photoViewController.photoURL = photoClass.photo;
        photoViewController.view.frame = appDelegate.window.frame;
        [self.view addSubview:photoViewController.view];
    }
}

-(void)removeImage{
    //[AnimatedMethods zoomOut:photoViewController.view];
    [photoViewController.view removeFromSuperview];
}

-(void)startRefresh{
    if(isMenuChoosed){
        [self getCategoryDeatils:CategoryURL];
    } else {
        [self getHomePageDetails];
    }
}

-(void)viewDidLayoutSubviews{
   // [collectionVWHome.viewForBaselineLayout.layer setSpeed:0.1f];
  //  self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = NO;
    [super viewWillAppear:YES];

    if(GetisComment == YES){
        SetisComment(NO);
        return;
    }
    if(isMenuChoosed){
        if(arrCategoryPhotos.count > 0){
            [self scrollToTop];
        }
    } else {
        if(appDelegate.arrPhotos.count > 0){
            [self scrollToTop];
        }
    }
}

-(void)scrollToTop{
    [UIView animateWithDuration:0.3 animations:^(void){
        [collectionVWHome scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return self.categoryList.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    return self.categoryList[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index{
    // update the view for the corresponding index
    
    NSString *subCategoryURL = @"";
    tapCellIndex = -1;
    
    if(arrCategoryPhotos.count > 0){
        [arrCategoryPhotos removeAllObjects];
    }
    
    switch (index) {
        case 1: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"just-because"];
        }
            break;
        case 2: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"sports-fitness"];
        }
            break;
        case 3: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"nightlife"];
        }
            break;
        case 4: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"style"];
        }
            break;
        case 5: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"lol"];
        }
            break;
        case 6: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"pay-it-forward"];
        }
            break;
        case 7: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"university"];
        }
            break;
        case 8: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"food"];
        }
            break;
        case 9: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"fall"];
        }
            break;
        case 0: {
            isMenuChoosed = NO;
            [self getHomePageDetails];
            return;
        }
            break;
        default: {
            subCategoryURL = [NSString stringWithFormat:@"%@%@/",CATEGORYURL,@"just-because"];
        }
            break;
    }
    CategoryURL = subCategoryURL;
    [self getCategoryDeatils:subCategoryURL];
}

-(void)getCategoryDeatils:(NSString *)subCategoryURL{
    checkNetworkReachability();
    [appDelegate showHUDAddedToView:self.view message:@""];
   
    //[self setBusy:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"%@",subCategoryURL];
    
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];

    //[_request setValue:[NSString stringWithFormat:@"Token %@",GetUserToken] forHTTPHeaderField:@"Authorization"];
    
//    NSLog(@"%@",GetUserToken);
    
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
         if(error != nil){
//             NSLog(@"%@",error);
              [appDelegate hideHUDForView2:self.view];
             //[self setBusy:NO];
         }
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //NSLog(@"%@",JSONValue);
             
             if([JSONValue isKindOfClass:[NSDictionary class]]){
                 if([JSONValue allKeys].count > 4){
                     NSString *titlePage = [JSONValue objectForKey:@"title"];
                     NSArray *arrPhotoSet = [JSONValue objectForKey:@"photo_set"];
                     
                     if(arrCategoryPhotos.count > 0){
                         [arrCategoryPhotos removeAllObjects];
                     }
                     
                     for (int i = 0; i < arrPhotoSet.count; i++){
                         NSMutableDictionary *dictResult;
                         dictResult = [[NSMutableDictionary alloc]init];
                         dictResult = [arrPhotoSet objectAtIndex:i];
                         
                         PhotoClass *photoClass = [[PhotoClass alloc]init];
                         photoClass.category_url = [dictResult objectForKey:@"category_url"];
                         photoClass.comment_count = [dictResult objectForKey:@"comment_count"];
                        // photoClass.comment_set = [dictResult objectForKey:@"comment_set"];
                         photoClass.created = [dictResult objectForKey:@"created"];
                         photoClass.creator = [[dictResult objectForKey:@"creator"] uppercaseString];
                         photoClass.creator_url = [dictResult objectForKey:@"creator_url"];
                         photoClass.description = [dictResult objectForKey:@"description"];
                         
                         int photoID = [[dictResult objectForKey:@"id"]intValue];
                         int like_Count = [[dictResult objectForKey:@"like_count"]intValue];
                         
                         photoClass.PhotoId = [NSString stringWithFormat:@"%d",photoID];
                         photoClass.like_count = [NSString stringWithFormat:@"%d",like_Count];
                         photoClass.likers = [[NSMutableArray alloc]init];
                         photoClass.comment_set = [[NSMutableArray alloc]init];
                         
                         NSArray *arrLiker = [dictResult objectForKey:@"get_likers_info"];
                         
                         photoClass.isLike = NO;
                         if([[dictResult objectForKey:@"get_likers_info"] count] > 0){
                             for(int l = 0; l < [arrLiker count]; l++){
                                 NSDictionary *dictUsers = [arrLiker objectAtIndex:l];
                                 if([[dictUsers objectForKey:@"username"] isEqualToString:GetUserName]){
                                     photoClass.isLike=YES;
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
                                 NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_picture"]];
                                 
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
                             
                             [photoClass.likers addObject:dictFollowerInfo];
                         }

                         NSArray *arrCommentSet = [dictResult objectForKey:@"comment_set"];

                         for(int k = 0; k < arrCommentSet.count; k++){
                             NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                             NSDictionary *dictUserDetail = [arrCommentSet objectAtIndex:k];
                             
                             if([dictUserDetail objectForKey:@"profile_picture"] == [NSNull null]){
                                 [dictFollowerInfo setObject:@"" forKey:@"user__profile_picture"];
                             } else {
                                 NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_picture"]];
                                 
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
                             NSString *fullName = [[dictFollowerInfo objectForKey:@"user__username"]lastPathComponent];
                             NSString *userName = [dictFollowerInfo objectForKey:@"text"];
                             
                             fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
                             
                             NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                             
                             NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
                             
                             [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
                             
                             [dictFollowerInfo setValue:hogan forKey:@"usernameText"];
                             
                             [photoClass.comment_set addObject:dictFollowerInfo];
                         }
                         photoClass.modified = [dictResult objectForKey:@"modified"];
                         photoClass.photo = [dictResult objectForKey:@"photo"];
                         photoClass.slug = [dictResult objectForKey:@"slug"];

                         [arrCategoryPhotos addObject:photoClass];
                         
                     } //for loop end
                 
                     if([titlePage isEqualToString:@""]){
                         [lblTitle setFont:[UIFont fontWithName:@"ARDESTINE" size:30]];
                         lblTitle.text = @"OBY";
                     } else {
                         [lblTitle setFont:[UIFont fontWithName:@"Gibson-Semibold" size:21]];
                         lblTitle.text = [titlePage capitalizedString];
                         // lblTitle.text = [titlePage uppercaseString];
                     }
                     [appDelegate hideHUDForView2:self.view];
                     //[self setBusy:NO];
                     isMenuChoosed = YES;
                     [self showImages];
                 } else {
                     [refreshControl endRefreshing];
                     [appDelegate hideHUDForView2:self.view];
                     //[self setBusy:NO];
                     showServerError();
                 }
             } else {
                 [refreshControl endRefreshing];
                 [appDelegate hideHUDForView2:self.view];
                 //[self setBusy:NO];
                 showServerError();
             }
         } else {
             [refreshControl endRefreshing];
             [appDelegate hideHUDForView2:self.view];
             //[self setBusy:NO];
             showServerError();
         }
     }];
}

-(void)getSupportList{
    checkNetworkReachability();
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
             [self setBusy:NO];
         }
         if([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             
             [self setBusy:NO];
             
             if([JSONValue isKindOfClass:[NSDictionary class]]){
                 if([JSONValue objectForKey:@"follower"] == [NSNull null]){
                     
                 } else {
                     if(appDelegate.arrSupports.count > 0){
                         [appDelegate.arrSupports removeAllObjects];
                     }
                     NSDictionary *dictFollower = [JSONValue objectForKey:@"follower"];
                     NSMutableArray *arrFollower = [dictFollower objectForKey:@"get_following_info"];
                     for(int j = 0; j < arrFollower.count; j++){
                         NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                         NSDictionary *dictUserDetail = [arrFollower objectAtIndex:j];
                         
                         if([dictUserDetail objectForKey:@"user__username"] == [NSNull null]){
                             [dictFollowerInfo setObject:@"" forKey:@"user__username"];
                         } else {
                             [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__username"] forKey:@"user__username"];
                         }
                         
                         NSString *userName = [dictFollowerInfo objectForKey:@"user__username"];
                         
                         [appDelegate.arrSupports addObject:userName];
                     }
                 }
                 [self setBusy:NO];
             } else {
                 [self setBusy:NO];
                 showServerError();
             }
         } else {
             [self setBusy:NO];
             showServerError();
         }
     }];
}

// NSURLConnection Delegates
-(void)getHomePageDetails{
    checkNetworkReachability();
    
    [appDelegate showHUDAddedToView:self.view message:@""];
    //[appDelegate hideHUDForView2:self.view];
    
    NSString *urlString = [NSString stringWithFormat:@"%@",HOMEPAGEURL];
   
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
            // [self setBusy:NO];
             [appDelegate hideHUDForView2:self.view];
         }
         if ([data length] > 0 && error == nil){
             NSArray *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             
             if([JSONValue isKindOfClass:[NSArray class]]){
                 
                 if( appDelegate.arrPhotos.count > 0){
                     [appDelegate.arrPhotos removeAllObjects];
                 }
                 
                 if([JSONValue count] > 0 ){
                     for (int i = 0; i < JSONValue.count; i++) {
                         NSMutableDictionary *dictResult;
                         dictResult = [[NSMutableDictionary alloc]init];
                         dictResult = [JSONValue objectAtIndex:i];
                         PhotoClass *photoClass = [[PhotoClass alloc]init];
                         photoClass.category_url = [dictResult objectForKey:@"category_url"];
                         photoClass.comment_count = [dictResult objectForKey:@"comment_count"];
                         //photoClass.comment_set = [dictResult objectForKey:@"comment_set"];
                         photoClass.created = [dictResult objectForKey:@"created"];
                         photoClass.creator = [[dictResult objectForKey:@"creator"] uppercaseString];
                         photoClass.creator_url = [dictResult objectForKey:@"creator_url"];
                         photoClass.description = [dictResult objectForKey:@"description"];
                         
                         int photoID = [[dictResult objectForKey:@"id"]intValue];
                         int like_Count = [[dictResult objectForKey:@"like_count"]intValue];
                         
                         photoClass.PhotoId = [NSString stringWithFormat:@"%d",photoID];
                         photoClass.like_count = [NSString stringWithFormat:@"%d",like_Count];
                         
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
                                 NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_picture"]];
                                 
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
                             
                             [photoClass.likers addObject:dictFollowerInfo];
                         }
                         
                         NSArray *arrCommentSet = [dictResult objectForKey:@"comment_set"];

                         for(int k = 0; k < arrCommentSet.count; k++){
                             NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                             NSDictionary *dictUserDetail = [arrCommentSet objectAtIndex:k];
                             
                             if([dictUserDetail objectForKey:@"profile_picture"] == [NSNull null]){
                                 [dictFollowerInfo setObject:@"" forKey:@"user__profile_picture"];
                             } else {
                                 NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_picture"]];
                                 
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
                             NSString *fullName = [[dictFollowerInfo objectForKey:@"user__username"]lastPathComponent];
                             NSString *userName = [dictFollowerInfo objectForKey:@"text"];
                             
                             fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
                             
                             NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:fullString];
                             
                             NSRange range = [fullString rangeOfString:userName options:NSForcedOrderingSearch];
                             
                             [hogan addAttribute: NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:range];
                             
                             [dictFollowerInfo setValue:hogan forKey:@"usernameText"];
                             
                             [photoClass.comment_set addObject:dictFollowerInfo];
                         }
                         photoClass.modified = [dictResult objectForKey:@"modified"];
                         photoClass.photo = [dictResult objectForKey:@"photo"];
                         photoClass.slug = [dictResult objectForKey:@"slug"];
                         
                         [appDelegate.arrPhotos addObject:photoClass];
                     }
                     //[self setBusy:NO];
                     [appDelegate hideHUDForView2:self.view];
                     [self showImages];
                 }
             } else {
                 [refreshControl endRefreshing];
                 //[self setBusy:NO];
                 [appDelegate hideHUDForView2:self.view];
                  showServerError();
             }
         } else {
             [refreshControl endRefreshing];
             //[self setBusy:NO];
             [appDelegate hideHUDForView2:self.view];
             showServerError();
         }
     }];
}

-(void)showImages{
    [refreshControl endRefreshing];
    [collectionVWHome reloadData];
    
    if(isMenuChoosed){
        if(arrCategoryPhotos.count > 0){
            [self scrollToTop];
        }
    } else {
        if(appDelegate.arrPhotos.count > 0){
            [self scrollToTop];
            [lblTitle setFont:[UIFont fontWithName:@"ARDESTINE" size:30]];
            lblTitle.text = @"OBY";
        }
    }
}

#pragma mark - Collecinview delegates

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(isMenuChoosed){
        return  [arrCategoryPhotos count];
    } else {
        return [appDelegate.arrPhotos count];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellimage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellimage" forIndexPath:indexPath];
    
    PhotoClass *photoClass;
    
    if(isMenuChoosed){
        photoClass = [arrCategoryPhotos objectAtIndex:indexPath.row];
    } else {
        photoClass = [appDelegate.arrPhotos objectAtIndex:indexPath.row];
    }

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
        [self tappedLink:string cellForRowAtIndexPath:indexPath];
    };
    gestureLabel.userHandleLinkTapHandler = tapHandler;
//    gestureLabel.urlLinkTapHandler = tapHandler;
//    gestureLabel.hashtagLinkTapHandler = tapHandler;
    
    cell.lblName.text = photoClass.creator;
    cell.lblDescription.text = photoClass.description;
    cell.lblLikes.text = [NSString stringWithFormat:@"%@",photoClass.like_count];
    cell.lblComments.text = [NSString stringWithFormat:@"%@",photoClass.comment_count];
    
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
    
    //[cell.imgView sd_setImageWithURL:[NSURL URLWithString:photoClass.photo]];
    
   //[cell.imgView sd_setImageWithURL:[NSURL URLWithString:photoClass.photo] placeholderImage:[UIImage imageNamed:@"testLoader.gif"]];
    
    //spining
    
      [cell.imgView loadImageFromURL:photoClass.photo withTempImage:@""];
    
   // cell.imgView.shouldShowLoader=YES;
    
    if(tapCellIndex == indexPath.row){
        cell.imgView.hidden = YES;
        cell.viewInfo.hidden = NO;
    } else {
        cell.imgView.hidden = NO;
        cell.viewInfo.hidden = YES;
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

- (void)tappedLink:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [NSString stringWithFormat:@"%@", link];
    NSString *newTitle = [title substringFromIndex:1];
//    NSString *message = [NSString stringWithFormat:@"You tapped %@ in section %@, row %@.",
//                         link,
//                         @(indexPath.section),
//                         @(indexPath.row)];
//    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
//                                                                   message:message
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil]];
//    
//    [self presentViewController:alert animated:YES completion:nil];
    
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    NSString *usrURL = [NSString stringWithFormat:@"%@%@/",PROFILEURL,newTitle];
    profileViewController.userURL = usrURL;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionView cellForItemAtIndexPath:indexPath];
    if(currentCell.imgView.image == nil){
        return;
    }

    UIImage *img = [UIImage imageNamed:@"spining"];
    if([self firstimage:img isEqualTo:currentCell.imgView.image]){
        return;
    }
    
    PhotoClass *photoClass;
    
    if(isMenuChoosed){
        photoClass = [arrCategoryPhotos objectAtIndex:indexPath.row];
    } else {
        photoClass = [appDelegate.arrPhotos objectAtIndex:indexPath.row];
    }
    
    photoViewController.photoURL = photoClass.photo;
    photoViewController.view.frame = appDelegate.window.frame;

    [appDelegate.window addSubview:photoViewController.view];
}

-(void)onCommentList:(CustomButton*)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionVWHome cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    
    if(isMenuChoosed){
        photoClass = [arrCategoryPhotos objectAtIndex:sender.tag];
    } else {
        photoClass = [appDelegate.arrPhotos objectAtIndex:sender.tag];
    }
    
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
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionVWHome cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    
    if(isMenuChoosed){
        photoClass = [arrCategoryPhotos objectAtIndex:sender.tag];
    } else {
        photoClass = [appDelegate.arrPhotos objectAtIndex:sender.tag];
    }
    
    SupportViewController *supportViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SupportViewController"];

        if([currentCell.lblLikes.text isEqualToString:@"0"]){
            return;
        }
        supportViewController.pageTitle = @"Likers";
        supportViewController.arrDetails = photoClass.likers.copy;
        [self.navigationController pushViewController:supportViewController animated:YES];
}

-(BOOL)firstimage:(UIImage *)image1 isEqualTo:(UIImage *)image2 {
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    return [data1 isEqualToData:data2];
}

-(void)onComment:(CustomButton*)sender{
    SetisComment(YES);
    PhotoClass *photoClass;
    
    if(isMenuChoosed){
        photoClass = [arrCategoryPhotos objectAtIndex:sender.tag];
    } else {
        photoClass = [appDelegate.arrPhotos objectAtIndex:sender.tag];
    }
    commentViewController.selectRow = (int)sender.tag;
    commentViewController.photoClass = photoClass;
    [self.navigationController pushViewController:commentViewController animated:YES];
}

-(void)onLike:(CustomButton*)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
       CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionVWHome cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    
    if(isMenuChoosed){
        photoClass = [arrCategoryPhotos objectAtIndex:sender.tag];
    } else {
        photoClass = [appDelegate.arrPhotos objectAtIndex:sender.tag];
    }
    
    checkNetworkReachability();
    
    int likecount = (int)[photoClass.like_count integerValue];
    if(photoClass.isLike){
        for(int i = 0 ; i < photoClass.likers.count; i++){
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
        
        fullString = [NSString stringWithFormat:@"%@ %@",fullName,userName];
        
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

-(void)doLike:(PhotoClass *)photoClass selectCell:(CollectionViewCellimage *)selectCell{
    [self.view endEditing:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
    
        //Call the Login Web services
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if(JSONValue != nil){

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

-(void)showUser:(CustomButton*)sender{
    PhotoClass *photoClass;
    
    if(isMenuChoosed){
        photoClass = [arrCategoryPhotos objectAtIndex:sender.tag];
    } else {
        photoClass = [appDelegate.arrPhotos objectAtIndex:sender.tag];
    }
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileViewController.userURL = photoClass.creator_url;
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}

@end
