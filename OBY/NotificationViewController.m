//
//  NotificationViewController.m
//

#import "NotificationViewController.h"
#import "AppDelegate.h"
#import "defs.h"
#import "Message.h"
#import "NotificationClass.h"
#import "TableViewCellNotification.h"
#import "SDIAsyncImageView.h"
#import "Reachability.h"
#import "PhotoViewController.h"
#import "AnimatedMethods.h"
#import "CustomButton.h"
#import "ProfileViewController.h"


@interface NotificationViewController ()<PhotoViewControllerDelegate>{
    AppDelegate *appDelegate;
    NSInteger notificationCount;
    NSString *nextURL;
    NSString *previousURL;
    NSMutableArray *arrNotification;
    
    __weak IBOutlet UILabel *lblWaterMark;
    __weak IBOutlet UITableView *tblVW;
    
    PhotoViewController *photoViewController;
    UIRefreshControl *refreshControl;
}
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    arrNotification = [[NSMutableArray alloc]init];
    [super viewDidLoad];
    appDelegate = [AppDelegate getDelegate];
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];

    [tblVW addSubview:refreshControl];
    
    [self getNotificDetails:NOTIFICATIONURL];
    
    photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    photoViewController.delegate = self;
}

-(void)startRefresh{
    if(arrNotification.count > 0){
        [arrNotification removeAllObjects];
    }
 
    [self getNotificDetails:NOTIFICATIONURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = NO;
    
    if(arrNotification.count > 0){
        [self scrollToTop];
    }
    
    [super viewWillAppear:YES];
}

-(void)scrollToTop{
    //[collectionVWHome setContentOffset:CGPointZero animated:YES];
    
    [tblVW setContentOffset:CGPointZero animated:YES];
    
   // [tblVW scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)getNotificDetails:(NSString *)requestURL{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }
    
     [appDelegate showHUDAddedToView:self.view message:@""];
    //[self setBusy:YES];
    NSString *urlString = [NSString stringWithFormat:@"%@",requestURL];
    
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
    NSLog(@"auth string =%@",authStr);
    
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
         if(error != nil){
             NSLog(@"%@",error);
             [appDelegate hideHUDForView2:self.view];
             //[self setBusy:NO];
         }
         if([data length] > 0 && error == nil){
               [appDelegate hideHUDForView2:self.view];
             //[self setBusy:NO];
             
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             //  NSLog(@"%@",JSONValue);
            
             if([JSONValue isKindOfClass:[NSDictionary class]] && [[JSONValue allKeys]count] > 2){
                 notificationCount = [[JSONValue objectForKey:@"count"]integerValue];
                 nextURL = [JSONValue objectForKey:@"next"];
                 previousURL = [JSONValue objectForKey:@"previous"];
                 
                 NSArray *arrNotifResult = [JSONValue objectForKey:@"results"];
                 
                 if(arrNotifResult.count > 0){
                     lblWaterMark.hidden = YES;
                     lblWaterMark.text = @"";
                 } else {
                     lblWaterMark.hidden = NO;
                     lblWaterMark.text = @"No notifications";
                 }
                     for (int i = 0; i < arrNotifResult.count; i++) {
                         NotificationClass *notificationClass = [[NotificationClass alloc]init];
                         int userId = [[[arrNotifResult objectAtIndex:i]valueForKey:@"id"]intValue];
                         notificationClass.Id = [NSString stringWithFormat:@"%d",userId];
                         
                         notificationClass.sender = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender"];
                         notificationClass.sender_url = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender_url"];
                         
                         NSString *str = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender_profile_picture"];
                         NSString *newStr = [NSString stringWithFormat:@"https:%@",str];
                         notificationClass.sender_profile_picture=newStr;
                         
                         notificationClass.display_thread = [[arrNotifResult objectAtIndex:i]valueForKey:@"display_thread"];
                         
                         if([[arrNotifResult objectAtIndex:i]valueForKey:@"read"]){
                             notificationClass.read=@"Yes";
                         } else {
                             notificationClass.read=@"No";
                         }
                         notificationClass.recipient = [[arrNotifResult objectAtIndex:i]valueForKey:@"recipient"];
                         notificationClass.created = [[arrNotifResult objectAtIndex:i]valueForKey:@"created"];
                         notificationClass.modified = [[arrNotifResult objectAtIndex:i]valueForKey:@"modified"];
                         
                         //target_photo
                         if([[arrNotifResult objectAtIndex:i]valueForKey:@"target_url"] != [NSNull null]){
                               notificationClass.target_url = [[arrNotifResult objectAtIndex:i]valueForKey:@"target_url"];
                         } else {
                             notificationClass.target_url = @"";
                         }
                         if([[arrNotifResult objectAtIndex:i]valueForKey:@"target_photo"]){
                    
                         }
                         if([[arrNotifResult objectAtIndex:i]valueForKey:@"target_photo"] != [NSNull null]){
                             NSString *urlString = [NSString stringWithFormat:@"https:%@",[[arrNotifResult objectAtIndex:i]valueForKey:@"target_photo"]];
                             
                             if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
                                 notificationClass.target_photo = urlString;
                             } else {
                                 notificationClass.target_photo = [NSString stringWithFormat:@"http://%@", urlString];
                             }
                         } else {
                             notificationClass.target_photo = @"";
                         }
                         if(![[arrNotifResult objectAtIndex:i]valueForKey:@"target_photo"]){
                             notificationClass.target_photo = @"";
                         }
                         
                         [arrNotification addObject:notificationClass];
                     }
                     [appDelegate hideHUDForView2:self.view];
                 //[self setBusy:NO];
                    [self showNotifications];
             } else {
                 [appDelegate hideHUDForView2:self.view];
                 //[self setBusy:NO];
                 [self showMessage:SERVER_ERROR];
             }
         } else {
             [appDelegate hideHUDForView2:self.view];
             //[self setBusy:NO];
             [self showMessage:SERVER_ERROR];
         }
     }];
}

-(void)showNotifications{
    [refreshControl endRefreshing];
    [tblVW reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;    //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrNotification count];    //count number of row from counting array hear cataGorry is An Array
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    TableViewCellNotification *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCellNotification" forIndexPath:indexPath];
 
    if(arrNotification.count <= 0){
        return  cell;
    }
    
    NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];

    cell.txtNotification.text = notificationClass.display_thread;
    
    if([notificationClass.target_url isEqualToString:@""]){
        cell.txtNotification.textColor = [UIColor lightGrayColor];
    } else {
        cell.txtNotification.textColor = [UIColor blackColor];
    }
    NSLog(@"SenderURL: %@",notificationClass.sender_profile_picture);
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponse:)];
    singleTap.numberOfTapsRequired = 1;
    [cell.txtNotification addGestureRecognizer:singleTap];
    
   [cell.imgProfile loadImageFromURL:notificationClass.sender_profile_picture withTempImage:@"avatar"];
    cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.width / 2;
    cell.imgProfile.layer.masksToBounds = YES;
 
    [cell.btnUsrProfile setTag:indexPath.row];
    [cell.btnUsrProfile addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    
    int c = (int)[arrNotification count];
    
    if([nextURL isKindOfClass:[NSString class]] && ![nextURL isEqualToString:@""] && ![nextURL isEqual:NULL] && (c%10 == 0) && (indexPath.row == (c-1))){
      [self getNotificDetails:nextURL];
    }
    return cell;
}

- (void)tapResponse:(UITapGestureRecognizer *)recognizer{
    CGPoint p = [recognizer locationInView:tblVW];
    
    NSIndexPath *indexPath = [tblVW indexPathForRowAtPoint:p];
    
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
        NSLog(@"%@",notificationClass.target_url);
        
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        if(networkStatus == NotReachable) {
            [self showMessage:NETWORK_UNAVAILABLE];
            return;
        }
        
        if([notificationClass.target_photo isEqualToString:@""]){
            return;
        } else {
            NSLog(@"target photo;; %@",notificationClass.target_photo);
            photoViewController.photoURL = notificationClass.target_photo;
            photoViewController.view.frame = appDelegate.window.frame;
            [self.view addSubview:photoViewController.view];
            
            //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:notificationClass.target_url]];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
    NSLog(@"%@",notificationClass.target_url);
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }
   
    if([notificationClass.target_photo isEqualToString:@""]){
        return;
    } else {
        NSLog(@"target photo;; %@",notificationClass.target_photo);
        photoViewController.photoURL = notificationClass.target_photo;
        photoViewController.view.frame = appDelegate.window.frame;
        [self.view addSubview:photoViewController.view];

        //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:notificationClass.target_url]];
    }
}

-(void)showUser:(CustomButton*)sender{
   NotificationClass *notificationClass = [arrNotification objectAtIndex:sender.tag];
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileViewController.userURL = notificationClass.sender_url;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

-(void)removeImage{
    [photoViewController.view removeFromSuperview];
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
