//
//  NotificationViewController.m
//

#import <QuartzCore/QuartzCore.h>

#import "AnimatedMethods.h"
#import "AnonViewController.h"
#import "AppDelegate.h"
#import "CustomButton.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "NotificationClass.h"
#import "NotificationViewController.h"
#import "PhotoViewController.h"
#import "ProfileViewController.h"
#import "SDIAsyncImageView.h"
#import "TableViewCellNotification.h"
#import "SinglePhotoViewController.h"


@interface NotificationViewController ()<PhotoViewControllerDelegate>{
    AppDelegate *appDelegate;
    
    __weak IBOutlet UILabel *lblWaterMark;
    __weak IBOutlet UITableView *tblVW;
    
    NSInteger notificationCount;
    NSString *nextURL;
    NSString *previousURL;
    NSMutableArray *arrNotification;
    UIRefreshControl *refreshControl;
    
    PhotoViewController *photoViewController;
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
    [tblVW setContentOffset:CGPointZero animated:YES];
}

-(void)getNotificDetails:(NSString *)requestURL{
    checkNetworkReachability();
    
    [appDelegate showHUDAddedToView:self.view message:@""];
    NSString *urlString = [NSString stringWithFormat:@"%@",requestURL];
    
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
         if([data length] > 0 && error == nil){
               [appDelegate hideHUDForView2:self.view];
             
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
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
                     lblWaterMark.text = @"Notifications will appear here";
                 }
                 for (int i = 0; i < arrNotifResult.count; i++) {
                     NotificationClass *notificationClass = [[NotificationClass alloc]init];
                     int userId = [[[arrNotifResult objectAtIndex:i]valueForKey:@"id"]intValue];
                     notificationClass.Id = [NSString stringWithFormat:@"%d",userId];
                     notificationClass.sender = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender"];
                     notificationClass.sender_url = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender_url"];
                         
                     NSString *str = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender_profile_picture"];
                     NSString *newStr = [NSString stringWithFormat:@"https:%@",str];
                     notificationClass.sender_profile_picture = newStr;
                         
                     notificationClass.display_thread = [[arrNotifResult objectAtIndex:i]valueForKey:@"display_thread"];
                         
                     if([[arrNotifResult objectAtIndex:i]valueForKey:@"read"]){
                         notificationClass.read = @"Yes";
                     } else {
                         notificationClass.read = @"No";
                     }
                     notificationClass.recipient = [[arrNotifResult objectAtIndex:i]valueForKey:@"recipient"];
                     notificationClass.created = [[arrNotifResult objectAtIndex:i]valueForKey:@"created"];
                     notificationClass.modified = [[arrNotifResult objectAtIndex:i]valueForKey:@"modified"];
                         
                     //target_photo
                     if([[arrNotifResult objectAtIndex:i]valueForKey:@"view_target_photo_url"] != [NSNull null]){
                         notificationClass.view_target_photo_url = [[arrNotifResult objectAtIndex:i]valueForKey:@"view_target_photo_url"];
                     } else {
                         notificationClass.view_target_photo_url = @"";
                     }
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
                 showServerError();
             }
         } else {
             [appDelegate hideHUDForView2:self.view];
             //[self setBusy:NO];
             showServerError();
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
        return cell;
    }
    
    NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
    
    cell.txtNotification.text = notificationClass.display_thread;
    
    if([notificationClass.target_url isEqualToString:@""]){
        cell.txtNotification.textColor = [UIColor lightGrayColor];
    } else {
        cell.txtNotification.textColor = [UIColor blackColor];
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponse:)];
    singleTap.numberOfTapsRequired = 1;
    [cell.txtNotification addGestureRecognizer:singleTap];
    
    [cell.imgProfile loadImageFromURL:notificationClass.sender_profile_picture withTempImage:@"avatar"];
    cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.width / 2;
    cell.imgProfile.layer.masksToBounds = YES;
 
    [cell.btnUsrProfile setTag:indexPath.row];
    [cell.btnUsrProfile addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
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

    } else {
        NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
        
        checkNetworkReachability();
        
        if([notificationClass.target_photo isEqualToString:@""]){
            return;
        } else {
            SinglePhotoViewController *singlePhotoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePhotoViewController"];
            singlePhotoViewController.singlePhotoURL = notificationClass.view_target_photo_url;
            [self.navigationController pushViewController:singlePhotoViewController animated:YES];
//            photoViewController.photoURL = notificationClass.target_photo;
//            photoViewController.view.frame = appDelegate.window.frame;
//            [self.view addSubview:photoViewController.view];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
    
    checkNetworkReachability();
   
    if([notificationClass.target_photo isEqualToString:@""]){
        return;
    } else {
        SinglePhotoViewController *singlePhotoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePhotoViewController"];
        singlePhotoViewController.singlePhotoURL = notificationClass.view_target_photo_url;
        [self.navigationController pushViewController:singlePhotoViewController animated:YES];
//        photoViewController.photoURL = notificationClass.target_photo;
//        photoViewController.view.frame = appDelegate.window.frame;
//        [self.view addSubview:photoViewController.view];
    }
}

-(void)showUser:(CustomButton*)sender{
    NotificationClass *notificationClass = [arrNotification objectAtIndex:sender.tag];
    
    if([notificationClass.sender isEqualToString:@"anonymous"]){
        AnonViewController *anonViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AnonViewController"];
        [self.navigationController pushViewController:anonViewController animated:YES];
    } else {
        ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profileViewController.userURL = notificationClass.sender_url;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
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
