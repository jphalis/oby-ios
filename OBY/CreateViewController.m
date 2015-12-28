//
//  CreateViewController.m
//

#import "AnimatedMethods.h"
#import "AppDelegate.h"
#import "CategoryViewController.h"
#import "ChoosePhotoViewController.h"
#import "CreateViewController.h"
#import "CustomeImagePicker.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "IBActionSheet.h"
#import "SCLAlertView.h"
#import "StringUtil.h"
#import "TimeLineViewController.h"
#import "TWMessageBarManager.h"
#import "UIView+RNActivityView.h"


#define kOFFSET_FOR_KEYBOARD 0.65


@interface CreateViewController ()<CategoryViewControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,IBActionSheetDelegate,CustomeImagePickerDelegate,ChoosePhotoViewControllerDelegate>{
    AppDelegate *appDelegate;
    
    __weak IBOutlet UITextView *txtDescription;
    __weak IBOutlet UITextField *txtCategory;
    __weak IBOutlet UIImageView *imgView;
    __weak IBOutlet UIButton *createBtn;
    
    int selectedCode;
    BOOL isImageChoosed;
    
    ChoosePhotoViewController *choosePhotoViewController;
}

@property (nonatomic) UIImagePickerController *imagePickerController;
- (IBAction)onBack:(id)sender;
- (IBAction)onCategory:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblCat;
- (IBAction)onCreate:(id)sender;
- (IBAction)onChooseImage:(id)sender;

@end

@implementation CreateViewController

@synthesize lblCat;

- (void) changeTextColorForUIActionSheet:(UIActionSheet*)actionSheet {
    UIColor *tintColor = [UIColor redColor];
    NSArray *actionSheetButtons = actionSheet.subviews;
    for (int i = 0; [actionSheetButtons count] > i; i++) {
        UIView *view = (UIView*)[actionSheetButtons objectAtIndex:i];
        if([view isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton*)view;
            [btn setTitleColor:tintColor forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    [super viewDidLoad];
    
    choosePhotoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChoosePhotoViewController"];
  
    choosePhotoViewController.delegate = self;
    
    if(self.view.frame.size.height == 480 && self.view.frame.size.width == 320){
        imgView.frame = CGRectMake(imgView.frame.origin.x+5, imgView.frame.origin.y, 100, 100);
    }
    
//    imgView.layer.cornerRadius = imgView.frame.size.width / 2;
    imgView.layer.cornerRadius = 7;
    imgView.layer.masksToBounds = YES;
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.tabbar.tabView.hidden = YES;
    
//    createBtn.layer.cornerRadius = 6;
  
    [super viewWillAppear:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)selectImage:(UIImage *)imgSelect{
    imgView.image = imgSelect;
}

- (IBAction)onCategory:(id)sender {
    [self.view endEditing:YES];
    
    CategoryViewController *categoryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryViewController"];
    categoryViewController.delegate = self;
    
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

-(void)chooseCategory:(NSString *)choosedCategory selectedIndex:(int)selectIndex{
//    NSLog(@"%@",choosedCategory);
    selectedCode = selectIndex+2;
    txtCategory.text = choosedCategory;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) animateTextView: (UITextView*) textView up: (BOOL) up{
    float val;
    if(self.view.frame.size.height == 480){
        val = 0.75;
    } else {
        val = kOFFSET_FOR_KEYBOARD;
    }
    const int movementDistance = val * textView.frame.origin.y;
    
    // tweak as needed
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

-(void)resignKeyboard {
    [self.view endEditing:YES];
}

- (void)nextTextField:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    CategoryViewController *categoryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryViewController"];
    categoryViewController.delegate = self;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (IBAction)onCreate:(id)sender {
    if([self validateFields]){
       [self doCreate];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    UIToolbar * keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolBar.tag = textView.tag;
    keyboardToolBar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *bar2 = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextTextField:)];
    bar2.tag = textView.tag;
    
    UIBarButtonItem *bar3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    bar3.tag = textView.tag;
    
    UIBarButtonItem *bar4 =
    [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignKeyboard)];
    bar4.tag = textView.tag;
    
    [keyboardToolBar setItems: [NSArray arrayWithObjects:
                                bar2,bar3,bar4,
                                nil]];
    
    textView.inputAccessoryView = keyboardToolBar;
    
    [self animateTextView:textView up: YES];
    return YES;
}

- (IBAction)onChooseImage:(id)sender {
    [self.view endEditing:YES];
  //[self.navigationController pushViewController:choosePhotoViewController animated:NO];
    [self choosingImage];
    //[self uploadImage];
}

-(void)choosingImage{
    CustomeImagePicker *cip = [[CustomeImagePicker alloc] init];
    cip.delegate = self;
    [cip setHideSkipButton:NO];
    [cip setHideNextButton:NO];
    [cip setMaxPhotos:MAX_ALLOWED_PICK];
    [cip setShowOnlyPhotosWithGPS:NO];
    
    [self presentViewController:cip animated:YES completion:^{
    
    }];
}

-(void)imageSelectionCancelled{
    [self.navigationController pushViewController:choosePhotoViewController animated:NO];
}

-(void) imageSelected:(NSArray *)arrayOfImages{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view showActivityView];
        }); // Main Queue to Display the Activity View
        int count = 0;
        for(NSString *imageURLString in arrayOfImages){
            // Asset URLs
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary assetForURL:[NSURL URLWithString:imageURLString] resultBlock:^(ALAsset *asset){
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                CGImageRef imageRef = [representation fullScreenImage];
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                if (imageRef) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(count == 0){
                            [imgView setImage:image];
                            //[imageView1 setImage:image];
                        }
                        if(count == 1){
                           // [imageView2 setImage:image];
                        }
                        if(count == 2){
                           // [imageView3 setImage:image];
                        }
                    });
                } // Valid Image URL
            } failureBlock:^(NSError *error) {
            }];
            count++;
        } // All Images I got
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideActivityView];
        });
    }); // Queue for reloading all images
}

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    UIImage *img = [UIImage imageNamed:@"gallery_icon"];
    BOOL check = [AnimatedMethods firstimage:img isEqualTo:imgView.image];
    
    if ([[txtCategory.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_CATEGORY closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if (check){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PHOTO closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return YES;
}

-(void)uploadingImage{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Take Photo",
                                  @"Choose from library", nil];
    
    [[UIButton appearanceWhenContainedIn:[UIActionSheet class], nil] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [actionSheet showInView:self.view];
//    [self changeTextColorForUIActionSheet:actionSheet];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    int i = (int)buttonIndex;
    
    switch(i) {
        case 0: {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                [AppDelegate showMessage:@"No camera available"];
            } else {
                [self ShowImagePickerForType:UIImagePickerControllerSourceTypeCamera];
            }
        }
            break;
        case 1: {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //UIImagePickerControllerSourceTypePhotoLibrary
              
                [self ShowImagePickerForType:UIImagePickerControllerSourceTypePhotoLibrary];
                // [self launchImagePickerViewController];
            }];
        }
            break;
        default:
            // Do Nothing...
            break;
    }
}

-(void)ShowImagePickerForType:(int)type{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = type;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    NSLog(@"info=%@",info);
    UIImage *originalImage, *editedImage, *imageToSave;
    editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    
    if (editedImage){
        imageToSave = editedImage;
    } else if (originalImage){
        imageToSave = originalImage;
    }
    
    isImageChoosed = YES;
    imgView.image = imageToSave;
    
    /*
    NSData *strProfile;
    NSString *str=@"";
    strProfile=UIImageJPEGRepresentation(imageToSave, 1.0);
    //strProfile = UIImagePNGRepresentation(imageToSave);
    str = [strProfile base64EncodedStringWithOptions:0];
    if(isLibrary==YES){
        [self callingMethod:picker];
    }else{
        [self doUploadImage:str];
    }
     */
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActionSheet/UIActionSheet Delegate Method

-(void)uploadImage{
    self.funkyIBAS = [[IBActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take photo",@"Choose from library",nil];
    self.funkyIBAS.buttonResponse = IBActionSheetButtonResponseShrinksOnPress;
    [self.funkyIBAS setButtonBackgroundColor:[UIColor clearColor]];
    [self.funkyIBAS setButtonTextColor:[UIColor clearColor]];
    [self.funkyIBAS setTitleBackgroundColor:[UIColor clearColor]];
    [self.funkyIBAS setTitleTextColor:[UIColor clearColor]];
    [self.funkyIBAS setButtonTextColor:[UIColor lightGrayColor] forButtonAtIndex:0];
    [self.funkyIBAS setButtonBackgroundColor:[UIColor whiteColor] forButtonAtIndex:0];
    [self.funkyIBAS setFont:[UIFont fontWithName:@"Gibson-Regular" size:22] forButtonAtIndex:0];
    [self.funkyIBAS setButtonTextColor:[UIColor lightGrayColor] forButtonAtIndex:1];
    [self.funkyIBAS setButtonBackgroundColor:[UIColor whiteColor] forButtonAtIndex:1];
    [self.funkyIBAS setFont:[UIFont fontWithName:@"Gibson-Regular" size:22] forButtonAtIndex:1];
    [self.funkyIBAS setButtonTextColor:[UIColor darkGrayColor] forButtonAtIndex:2];
    [self.funkyIBAS setButtonBackgroundColor:[UIColor whiteColor] forButtonAtIndex:2];
    [self.funkyIBAS setCancelButtonFont:[UIFont fontWithName:@"Gibson-SemiBold" size:22]];
    [self.funkyIBAS showInView:self.view];
}

// optional delegate methods
- (void)actionSheet:(IBActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
//    NSLog(@"Will dismiss with button index %ld", (long)buttonIndex);
}

- (void)actionSheet:(IBActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    NSLog(@"Dismissed with button index %ld", (long)buttonIndex);
}

-(void)doCreate{
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    NSString *myUniqueName = [NSString stringWithFormat:@"%@-%lu", @"img", (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];
    
    NSString *description;
    
    if([txtDescription.text isEqualToString:@"Description"]){
        description = @"";
    } else {
        description = txtDescription.text;
    }
    
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:description forKey:@"description"];
    [_params setValue:[NSString stringWithFormat:@"%d",selectedCode] forKey:@"category"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"photo";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:CREATEURL];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(imgView.image, 1.0);
    if (imageData){
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", FileParamConstant,myUniqueName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
         if ([data length] > 0 && error == nil){
              [self setBusy:NO];
             
             NSDictionary * JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//             NSString *strResponse = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             
             if([JSONValue isKindOfClass:[NSDictionary class]]){
                 if([JSONValue allKeys].count == 3 && [JSONValue objectForKey:@"photo"]){
                     [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success"
                                                                    description:UPLOAD_PHOTO
                                                                           type:TWMessageBarMessageTypeSuccess
                                                                       duration:3.0];
                     [self.navigationController popViewControllerAnimated:YES];
                 } else {
                     showServerError();
                 }
             } else {
                 showServerError();
             }
         } else {
             showServerError();
         }
         [self setBusy:NO];
     }];
}

- (NSString *)percentEscapeString:(NSString *)string{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Description"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
        [textView becomeFirstResponder];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Description";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
    [self animateTextView:textView up: NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)showcamera{
    UIImagePickerController *imagePicker;
    imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setAllowsEditing:YES];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

@end
