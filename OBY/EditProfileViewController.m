//
//  EditProfileViewController.m
//

#import "AnimatedMethods.h"
#import "ChoosePhotoViewController.h"
#import "CustomeImagePicker.h"
#import "defs.h"
#import "EditProfileViewController.h"
#import "GlobalFunctions.h"
#import "IBActionSheet.h"
#import "Message.h"
#import "MMPickerView.h"
#import "SCLAlertView.h"
#import "SDIAsyncImageView.h"
#import "StringUtil.h"
#import "TWMessageBarManager.h"
#import "UIView+RNActivityView.h"


#define kOFFSET_FOR_KEYBOARD 0.65

@interface EditProfileViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CustomeImagePickerDelegate,ChoosePhotoViewControllerDelegate> {
    AppDelegate *appDelegate;
    
    __weak IBOutlet UITextField *txtWebsite;
    __weak IBOutlet UITextField *txtFullName;
    __weak IBOutlet UITextField *txtEmail;
    __weak IBOutlet UITextField *txtUserName;
    __weak IBOutlet SDIAsyncImageView *imgProfile;
    __weak IBOutlet UITextView *txtBio;
    __weak IBOutlet UITextField *txtEduEmail;
    __weak IBOutlet UITextField *txtGender;
    __weak IBOutlet UIButton *updateBtn;
    __weak IBOutlet UIScrollView *scrolVW;
    
    NSMutableArray *arrGender;
    
    ChoosePhotoViewController *choosePhotoViewController;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onGender:(id)sender;
- (IBAction)onUpdate:(id)sender;

@property (nonatomic, strong) NSString *selectedGender;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    [imgProfile loadImageFromURL:GetProifilePic withTempImage:@"avatar"];
    txtUserName.text = GetUserName;
    txtFullName.text = GetUserFullName;
    txtEmail.text = GetUserMail;
    txtEduEmail.text = GetUserEduMail;
    txtWebsite.text = GetUserWebsite;
    txtBio.text = GetUserBio;
    
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseImage:)];
    tapGesture.numberOfTapsRequired = 1;
    [imgProfile addGestureRecognizer:tapGesture];
    [imgProfile setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapGestureScroll = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScroll:)];
    tapGestureScroll.numberOfTapsRequired = 1;
    [scrolVW addGestureRecognizer:tapGestureScroll];
    [scrolVW setUserInteractionEnabled:YES];
    
    arrGender = [NSMutableArray arrayWithObjects:@"---",@"Dude",@"Betty",nil];
    _selectedGender = [arrGender objectAtIndex:0];
    
    choosePhotoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChoosePhotoViewController"];
    
    choosePhotoViewController.delegate = self;
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [scrolVW addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated {
    if(self.view.frame.size.height == 480 && self.view.frame.size.width == 320){
        imgProfile.frame = CGRectMake(imgProfile.frame.origin.x+8, imgProfile.frame.origin.y, 60, 60);
    }
    imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2;
    imgProfile.layer.masksToBounds = YES;
    
    [self getProfileInfo];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, updateBtn.frame.size.width, 1.0)];
    topBorder.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1.0];
    [updateBtn addSubview:topBorder];
    
    [super viewWillAppear:YES];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)chooseImage:(UITapGestureRecognizer *)gestureRecognizer{
    [self choosingImage];
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

-(void)imageSelected:(NSArray *)arrayOfImages{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view showActivityView];
        });
        int count = 0;
        for(NSString *imageURLString in arrayOfImages){

            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary assetForURL:[NSURL URLWithString:imageURLString] resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                CGImageRef imageRef = [representation fullScreenImage];
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                if (imageRef) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(count == 0){
                            [imgProfile setImage:image];
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
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideActivityView];
        });
    }); // Queue for reloading all images
}

-(void)tapScroll:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

-(void)selectImage:(UIImage *)imgSelect{
    imgProfile.image=imgSelect;
}

-(void)getProfileInfo{
//    [self setBusy:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/",PROFILEURL,GetUserName];
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

             if([JSONValue isKindOfClass:[NSDictionary class]]){
                 if([JSONValue allKeys].count == 1 && [JSONValue objectForKey:@"detail"]){
                     [self setBusy:NO];
                     showServerError();
                     return;
                 }
                 if([JSONValue objectForKey:@"username"] == [NSNull null]){
                     txtUserName.text = @"";
                 } else {
                     txtUserName.text = [JSONValue objectForKey:@"username"];
                 }

                 if([JSONValue objectForKey:@"email"] == [NSNull null]){
                     txtEmail.text = @"";
                 } else {
                     txtEmail.text = [JSONValue objectForKey:@"email"];
                 }
                 
                 if([JSONValue objectForKey:@"edu_email"] == [NSNull null]){
                     txtEduEmail.text = @"";
                 } else {
                     txtEduEmail.text = [JSONValue objectForKey:@"edu_email"];
                 }
                 
                 if([JSONValue objectForKey:@"full_name"] == [NSNull null]){
                     txtFullName.text = @"";
                 } else {
                     txtFullName.text = [JSONValue objectForKey:@"full_name"];
                 }
                 
                 if([JSONValue objectForKey:@"bio"] == [NSNull null]){
                     txtBio.text = @"";
                 } else {
                     txtBio.text = [JSONValue objectForKey:@"bio"];
                 }
                 
                 if([JSONValue objectForKey:@"website"] == [NSNull null]){
                     txtWebsite.text = @"";
                 } else {
                     txtWebsite.text = [JSONValue objectForKey:@"website"];
                 }
                
                 if([JSONValue objectForKey:@"gender"] == [NSNull null]){
                     txtGender.text = @"---";
                 } else {
                     if([[JSONValue objectForKey:@"gender"] isEqualToString:@""]){
                          txtGender.text = @"---";
                     } else {
                         txtGender.text = [JSONValue objectForKey:@"gender"];
                     }
                 }
                 NSString *profilePicUrl;
                 
                 if([JSONValue objectForKey:@"profile_picture"] == [NSNull null]){
                     profilePicUrl = @"";
                 } else {
                     profilePicUrl = [JSONValue objectForKey:@"profile_picture"];
                 }
                 
                 [imgProfile loadImageFromURL:profilePicUrl withTempImage:@"avatar"];
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

-(void)showGender{
    NSArray *arr = [arrGender copy];
    [self resignKeyboard];
  
    [MMPickerView showPickerViewInView:appDelegate.window
                           withStrings:arr
                           withOptions:@{MMbackgroundColor:[UIColor whiteColor],
                                         MMtextColor:[UIColor blackColor],
                                         MMtoolbarColor:[AnimatedMethods colorFromHexString:@"#009CF3"],
                                         MMbuttonColor:[UIColor whiteColor] ,
                                         MMfont:[UIFont systemFontOfSize:20],
                                         MMvalueY:@3,
                                         MMselectedObject:_selectedGender,
                                         MMtextAlignment:@1}
                            completion:^(NSString *selectedString) {
                                txtGender.text = selectedString;
                                _selectedGender = selectedString;
                            }];
}

-(void)callMethod{
    [self animateTextField: txtGender up: YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger length = [textField.text length] - range.length + [string length];
    if(textField == txtUserName){
        BOOL isValidChar = [AppDelegate isValidCharacter:string filterCharSet:USERNAME];
        return isValidChar && length <= 30 ;
    }
    if(textField == txtFullName){
        return length <= 50 ;
    }
    if(textField == txtEmail || txtEduEmail){
        BOOL isValidChar = [AppDelegate isValidCharacter:string filterCharSet:EMAIL];
        return isValidChar && length <= 80 ;
    }
    if(textField == txtWebsite){
        // Add regex for urls
        return length <= 90 ;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
        if([text isEqualToString:@"\n"]){
            [textView resignFirstResponder];
        return NO;
        }
        NSUInteger length = [textView.text length] - range.length + [text length];
        if(textView == txtBio){
            return length <= 200 ;
        }
        return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self animateTextView:textView up: YES];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{
     [self animateTextView:textView up: NO];
}

- (void)animateTextField:(UITextField*)textField up: (BOOL) up{
    float val;
    
    if(self.view.frame.size.height == 480){
        val = 0.75;
    } else {
        val = kOFFSET_FOR_KEYBOARD;
    }
    
    const int movementDistance = val * textField.frame.origin.y;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

- (void)animateTextView:(UITextView*)textView up: (BOOL) up{
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

-(void)resignKeyboard{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [txtEmail resignFirstResponder];
    [txtEduEmail resignFirstResponder];
    [txtWebsite resignFirstResponder];
    [txtFullName resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(BOOL)ValidateFields{
    NSString *code;
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if([[txtEduEmail.text Trim] length] > 3){
        code = [[txtEduEmail.text Trim] substringFromIndex: [[txtEduEmail.text Trim] length] - 4];
    }
    if ([[txtUserName.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_USERNAME closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtUserName.text Trim] length] < 3){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:USERNAME_MIN_LEGTH closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([[txtEmail.text Trim] isEmpty]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_EMAIL closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if ([AppDelegate validateEmail:[txtEmail.text Trim]] == NO){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:INVALID_EMAIL closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    } else if (![[txtEduEmail.text Trim] isEmpty] && [AppDelegate validateEmail:[txtEduEmail.text Trim]] == NO){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:INVALID_EDU_EMAIL closeButtonTitle:@"OK" duration:0.0f];
    } else if (![[txtEduEmail.text Trim] isEmpty] && ![code isEqualToString:@".edu"]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:INVALID_EDU_EMAIL closeButtonTitle:@"OK" duration:0.0f];
         return NO;
    } else if([[txtBio.text Trim] length] > 200){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:MAX_BIO_LENGTH closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return  YES;
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

- (IBAction)onGender:(id)sender {
    [self showGender];
}

- (IBAction)onUpdate:(id)sender {
    if([self ValidateFields]){
        [self doUpdate];
    }
}

-(void)doUpdate{
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    NSString *myUniqueName = [NSString stringWithFormat:@"%@-%lu", @"image", (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];

    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[txtUserName.text Trim] forKey:@"username"];
    [_params setObject:[txtEmail.text Trim] forKey:@"email"];
    [_params setObject:[txtFullName.text Trim] forKey:@"full_name"];
    [_params setObject:[txtBio.text Trim] forKey:@"bio"];
    [_params setObject:[txtWebsite.text Trim] forKey:@"website"];
    [_params setObject:[txtEduEmail.text Trim] forKey:@"edu_email"];
    if([txtGender.text isEqualToString:@"---"]){
        [_params setObject:@"" forKey:@"gender"];
    } else {
        [_params setObject:[txtGender.text Trim] forKey:@"gender"];
    }
    [_params setObject:@"true" forKey:@"is_active"];
    [_params setObject:@"true" forKey:@"is_verified"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"profile_picture";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/",PROFILEURL,GetUserName];
    NSURL* requestURL = [NSURL URLWithString:urlStr];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"PUT"];
    
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
    NSData *imageData;
    UIImage *img = [UIImage imageNamed:@"avatar"];
    if([AnimatedMethods firstimage:img isEqualTo:imgProfile.image]){
        imageData = nil;
    } else {
        imageData = UIImageJPEGRepresentation(imgProfile.image, 1.0);
    }
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

             if([JSONValue isKindOfClass:[NSDictionary class]]){
                 if([JSONValue allKeys].count > 5){
                     SetisUpdate(YES);

                     SetUserName([JSONValue objectForKey:@"username"]);
                     SetUserFullName([JSONValue objectForKey:@"full_name"]);
                     NSString *profilePic;
                     if([JSONValue objectForKey:@"profile_picture"] == [NSNull null]){
                         profilePic = @"";
                     } else {
                         profilePic=[JSONValue objectForKey:@"profile_picture"];
                     }
                     SetProifilePic(profilePic);
                     SetUserMail([JSONValue objectForKey:@"email"]);
                     SetUserEduMail([JSONValue objectForKey:@"edu_email"]);
                     SetUserWebsite([JSONValue objectForKey:@"website"]);
                     SetUserBio([JSONValue objectForKey:@"bio"]);
                     
                     alert.showAnimationType = SlideInFromLeft;
                     alert.hideAnimationType = SlideOutToBottom;
                     [alert showSuccess:self title:@"Success" subTitle:UPDATEPROFILE_SUCCESS closeButtonTitle:@"Done" duration:0.0f];
                     [alert alertIsDismissed:^{
                         [self.navigationController popViewControllerAnimated:YES];
                     }];
                 } else if ([JSONValue objectForKey:@"username"]){
                     alert.showAnimationType = SlideInFromLeft;
                     alert.hideAnimationType = SlideOutToBottom;
                     [alert showNotice:self title:@"Notice" subTitle:USER_EXISTS_ANOTHER_USER closeButtonTitle:@"OK" duration:0.0f];
                 } else if ([JSONValue objectForKey:@"email"]){
                     alert.showAnimationType = SlideInFromLeft;
                     alert.hideAnimationType = SlideOutToBottom;
                     [alert showNotice:self title:@"Notice" subTitle:EMAIL_EXISTS_ANOTHER_USER closeButtonTitle:@"OK" duration:0.0f];
                 } else if ([JSONValue objectForKey:@"edu_email"]){
                     alert.showAnimationType = SlideInFromLeft;
                     alert.hideAnimationType = SlideOutToBottom;
                     [alert showNotice:self title:@"Notice" subTitle:@"Sorry, this university isn't registered with us yet. Email us to get it signed up! universities@obystudio.com" closeButtonTitle:@"OK" duration:0.0f];
                 } else if ([JSONValue objectForKey:@"gender"]){
                     alert.showAnimationType = SlideInFromLeft;
                     alert.hideAnimationType = SlideOutToBottom;
                     [alert showNotice:self title:@"Notice" subTitle:@"This is not a valid gender choice." closeButtonTitle:@"OK" duration:0.0f];
                 }
             } else {
                 showServerError();
             }
         } else {
             [self setBusy:NO];
             showServerError();
         }
         [self setBusy:NO];
     }];
}

-(void)uploadImage{
    self.funkyIBAS = [[IBActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose from library",nil];
    
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
- (void)actionSheet:(IBActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
//    NSLog(@"Will dismiss with button index %ld", (long)buttonIndex);
}

- (void)actionSheet:(IBActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    NSLog(@"Dismissed with button index %ld", (long)buttonIndex);
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
                [self ShowImagePickerForType:UIImagePickerControllerSourceTypePhotoLibrary];
                // [self launchImagePickerViewController];
            }];
        }
            break;
        default:
            // Do nothing...
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

    UIImage *originalImage, *editedImage, *imageToSave;
    editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    
    if (editedImage){
        imageToSave = editedImage;
    } else if (originalImage){
        imageToSave = originalImage;
    }

    imgProfile.image = imageToSave;

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
