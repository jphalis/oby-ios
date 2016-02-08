//
//  HashtagViewController.m
//

#import "AnimatedMethods.h"
#import "AnonViewController.h"
#import "AppDelegate.h"
#import "CollectionViewCellimage.h"
#import "CommentViewController.h"
#import "CustomButton.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "HashtagViewController.h"
#import "KILabel.h"
#import "PhotoClass.h"
#import "PhotoViewController.h"
#import "ProfileViewController.h"
#import "Reachability.h"
#import "SupportViewController.h"
#import "TWMessageBarManager.h"
#import "UIImageView+WebCache.h"


@interface HashtagViewController ()<PhotoViewControllerDelegate,CommentViewControllerDelegate> {
    AppDelegate *appDelegate;
    
    __weak IBOutlet UICollectionView *colltionVw;
    __weak IBOutlet UILabel *headerLabel;
    
    NSInteger hashtagCount;
    NSString *nextURL;
    NSString *previousURL;
    NSMutableArray *arrHashtagPhotos;
    NSInteger tapCellIndex;
    NSIndexPath *previousIndexPath;
    UIRefreshControl *refreshControl;
    
    CommentViewController *commentViewController;
    PhotoViewController *photoViewController;
}

- (IBAction)onBack:(id)sender;
@end

@implementation HashtagViewController
@synthesize titleLabel;
@synthesize tagURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    arrHashtagPhotos = [[NSMutableArray alloc]init];
    tapCellIndex = -1;
    
    previousIndexPath = nil;
    
    appDelegate = [AppDelegate getDelegate];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [colltionVw addSubview:refreshControl];
    
    colltionVw.alwaysBounceVertical = YES;
    
    photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    photoViewController.delegate = self;
    
    commentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentViewController.delegate = self;
    
    UILongPressGestureRecognizer *longPressCollectionView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressCollectionView.minimumPressDuration = 1;
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:viewRight];
    
    [self getHashtagDetails];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = NO;
    [super viewWillAppear:YES];
    
    headerLabel.text = titleLabel;
    
    if(GetisComment == YES){
        SetisComment(NO);
        return;
    }
    if(arrHashtagPhotos.count > 0){
        [self scrollToTop];
    }
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:colltionVw];
    
    NSIndexPath *indexPath = [colltionVw indexPathForItemAtPoint:p];
    if (indexPath == nil){
        return;
    } else {
        static int i = 0;
        i++;
        if(i == 1){
            return;
        }
        PhotoClass *photoClass = [arrHashtagPhotos objectAtIndex:indexPath.row];
        photoViewController.photoURL = photoClass.photo;
        photoViewController.photoDeleteURL = photoClass.photo_url;
        photoViewController.photoCreator = photoClass.creator;
        photoViewController.view.frame = appDelegate.window.frame;
        
        [self.view addSubview:photoViewController.view];
    }
}

-(void)startRefresh{
    [self getHashtagDetails];
}

-(void)removeImage{
    [photoViewController.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setComment:(int)selectIndex commentCount:(NSString *)countStr{
    if(selectIndex >= 0){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectIndex inSection:0];
        CollectionViewCellimage *currentCell=(CollectionViewCellimage *)[colltionVw cellForItemAtIndexPath:indexPath];
        currentCell.lblComments.text = countStr;
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)scrollToTop{
    [UIView animateWithDuration:0.3 animations:^(void){
        [colltionVw scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
    
    // [colltionVw setContentOffset:CGPointZero animated:YES];
    //colltionVw.contentOffset = CGPointMake(colltionVw.contentOffset.x, 0.0);
    
    //    [colltionVw scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]
    //                             atScrollPosition:UICollectionViewScrollPositionCenteredVertically
    //                                     animated:NO];
}

#pragma mark - Collecinview delegates

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [arrHashtagPhotos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellimage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"hashtagCollView" forIndexPath:indexPath];
    PhotoClass *photoClass = [arrHashtagPhotos objectAtIndex:indexPath.row];
    
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
    //cell.imgView.shouldShowLoader=YES;
    
    // [cell.imgView sd_setImageWithURL:[NSURL URLWithString:photoClass.photo] placeholderImage:[UIImage imageNamed:@"testLoader.gif"]];
    
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

- (void)tappedUser:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [NSString stringWithFormat:@"%@", link];
    NSString *newTitle = [title substringFromIndex:1];
    NSString *userURL = [NSString stringWithFormat:@"%@%@/",PROFILEURL,newTitle];
    if([[newTitle lastPathComponent]isEqualToString:@"anonymous"]){
        AnonViewController *anonViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AnonViewController"];
        [self.navigationController pushViewController:anonViewController animated:YES];
    } else {
        ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profileViewController.userURL = userURL;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (void)tappedHashtag:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [NSString stringWithFormat:@"%@", link];
    NSString *newTitle = [title substringFromIndex:1];
    newTitle = [newTitle lowercaseString];
    HashtagViewController *hashtagViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HashtagViewController"];
    tagURL = [NSString stringWithFormat:@"%@%@",HASHTAGURL,newTitle];
    hashtagViewController.tagURL = tagURL;
    hashtagViewController.titleLabel = [title uppercaseString];
    [self.navigationController pushViewController:hashtagViewController animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[collectionView cellForItemAtIndexPath:indexPath];
    //CollectionViewCellimage *PreivousCell=(CollectionViewCellimage *)[collectionView cellForItemAtIndexPath:previousIndexPath];
    
    if(currentCell.imgView.image == nil){
        return;
    }
    
    UIImage *img = [UIImage imageNamed:@"blankImage"];
    if([AnimatedMethods firstimage:img isEqualTo:currentCell.imgView.image]){
        return;
    }
    
    tapCellIndex = indexPath.row;
    
    PhotoClass *photoClass = [arrHashtagPhotos objectAtIndex:indexPath.row];
    photoViewController.photoURL = photoClass.photo;
    photoViewController.photoDeleteURL = photoClass.photo_url;
    photoViewController.photoCreator = photoClass.creator;
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
    CollectionViewCellimage *currentCell=(CollectionViewCellimage *)[colltionVw cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    photoClass = [arrHashtagPhotos objectAtIndex:sender.tag];
    
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
    CollectionViewCellimage *currentCell=(CollectionViewCellimage *)[colltionVw cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    photoClass = [arrHashtagPhotos objectAtIndex:sender.tag];
    
    SupportViewController *supportViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"SupportViewController"];
    
    if([currentCell.lblLikes.text isEqualToString:@"0"]){
        return;
    }
    
    supportViewController.pageTitle = @"Likers";
    supportViewController.arrDetails = photoClass.likers.copy;
    [self.navigationController pushViewController:supportViewController animated:YES];
}

-(void)showUser:(CustomButton*)sender{
    PhotoClass *photoClass = [arrHashtagPhotos objectAtIndex:sender.tag];
    if([[photoClass.creator lowercaseString] isEqualToString:@"anonymous"]){
        AnonViewController *anonViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AnonViewController"];
        [self.navigationController pushViewController:anonViewController animated:YES];
    } else {
        ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profileViewController.userURL = photoClass.creator_url;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

-(void)onComment:(CustomButton*)sender{
    SetisComment(YES);
    PhotoClass *photoClass;
    photoClass = [arrHashtagPhotos objectAtIndex:sender.tag];
    commentViewController.selectRow = (int)sender.tag;
    commentViewController.photoClass = photoClass;
    [self.navigationController pushViewController:commentViewController animated:YES];
}

-(void)onLike:(CustomButton*)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    CollectionViewCellimage *currentCell = (CollectionViewCellimage *)[colltionVw cellForItemAtIndexPath:indexPath];
    
    PhotoClass *photoClass;
    photoClass = [arrHashtagPhotos objectAtIndex:sender.tag];
    
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
    photoClass.isLike = !photoClass.isLike;
    
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

-(void)getHashtagDetails{
    checkNetworkReachability();
    
    [appDelegate showHUDAddedToView:self.view message:@""];

    NSString *urlString = tagURL;
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
             [appDelegate hideHUDForView2:self.view];
         }
         if ([data length] > 0 && error == nil){
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             
             if([JSONValue isKindOfClass:[NSDictionary class]] && [[JSONValue allKeys]count] > 2){
                 hashtagCount = [[JSONValue objectForKey:@"count"]integerValue];
                 nextURL = [JSONValue objectForKey:@"next"];
                 previousURL = [JSONValue objectForKey:@"previous"];
             
                 NSArray *arrHashtagResult = [JSONValue objectForKey:@"results"];
                 
                 if([JSONValue count] > 0){
                     for (int i = 0; i < arrHashtagResult.count; i++) {
                         NSMutableDictionary *dictResult;
                         dictResult = [[NSMutableDictionary alloc]init];
                         dictResult = [arrHashtagResult objectAtIndex:i];
                         PhotoClass *photoClass = [[PhotoClass alloc]init];
                         photoClass.category_url = [dictResult objectForKey:@"category_url"];
                         photoClass.photo_url = [dictResult objectForKey:@"photo_url"];
                         photoClass.comment_count = [dictResult objectForKey:@"comment_count"];
                         //photoClass.comment_set = [dictResult objectForKey:@"comment_set"];
                         photoClass.created = [dictResult objectForKey:@"created"];
                         photoClass.creator = [[dictResult objectForKey:@"creator"] uppercaseString];
                         photoClass.creator_url = [dictResult objectForKey:@"creator_url"];
                         photoClass.description = [dictResult objectForKey:@"description"];
                         
                         int userId = [[dictResult objectForKey:@"id"]intValue];
                         int like_Count = [[dictResult objectForKey:@"like_count"]intValue];
                         
                         photoClass.PhotoId = [NSString stringWithFormat:@"%d",userId];
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
                         
                         [arrHashtagPhotos addObject:photoClass];
                     }
                     [appDelegate hideHUDForView2:self.view];
                     //[self setBusy:NO];
                     [self showImages];
                 }
             }
         } else {
             [refreshControl endRefreshing];
             [appDelegate hideHUDForView2:self.view];
             //[self setBusy:NO];
             showServerError();
         }
     }];
}

-(void)showImages{
    [colltionVw reloadData];
    [refreshControl endRefreshing];
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
