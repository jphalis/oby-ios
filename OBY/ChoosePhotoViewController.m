//
//  ChoosePhotoViewController.m
//  OBY
//

#import "ChoosePhotoViewController.h"
#import "CustomeImagePicker.h"
#import "UIView+RNActivityView.h"


@interface ChoosePhotoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CustomeImagePickerDelegate>{
    
    __weak IBOutlet UITableView *tblVW;
    NSMutableArray *arrOptions;
}
- (IBAction)onBack:(id)sender;

@end

@implementation ChoosePhotoViewController

- (void)viewDidLoad {
    arrOptions=[[NSMutableArray alloc]initWithObjects:@"Photo Gallery",@"All Photos", nil];
    
   // [self showCustomPicker];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrOptions count];    //count number of row from counting array hear cataGorry is An Array
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    
    cell.textLabel.text =[arrOptions objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==1){
        [self showCustomPicker];
    }else{
        [self ShowImagePickerForType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
}

-(void)ShowImagePickerForType:(int)type{
    UIImagePickerController *picker=[[UIImagePickerController alloc]init];
    [self ResetNavigationColor:picker];
    picker.sourceType=type;
    picker.delegate=self;
    //picker.allowsEditing=YES;
    [self presentViewController:picker animated:NO completion:nil];
}

-(void)ResetNavigationColor:(UINavigationController *)navgiation{
    //Set appareance.
    NSDictionary *dictionary;
    
        dictionary=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"Rockwell" size:20.0], NSFontAttributeName, nil];
   
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIColor *lightBlue = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header.png"]];
    [navgiation.navigationBar setTitleTextAttributes:dictionary];
    navgiation.navigationBar.barTintColor = lightBlue;
    navgiation.navigationBar.tintColor = [UIColor whiteColor];
    navgiation.navigationBar.translucent = NO;
    self.navigationItem.hidesBackButton=YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    NSLog(@"info=%@",info);
    UIImage *originalImage, *editedImage, *imageToSave;
    editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    
    if (editedImage) {
        imageToSave = editedImage;
    } else if (originalImage) {
        imageToSave = originalImage;
    }
    
    [self.delegate selectImage:imageToSave];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
    
}

-(void)showCustomPicker{
    CustomeImagePicker *cip = [[CustomeImagePicker alloc] init];
    
    cip.delegate = self;
    [cip setHideSkipButton:NO];
    [cip setHideNextButton:NO];
    [cip setMaxPhotos:MAX_ALLOWED_PICK];
    [cip setShowOnlyPhotosWithGPS:NO];
    
    [self presentViewController:cip animated:NO completion:^{
    }
     ];
}

-(void)doneClick{
    //[self.navigationController popViewControllerAnimated:NO];
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
            [assetsLibrary assetForURL:[NSURL URLWithString:imageURLString] resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                CGImageRef imageRef = [representation fullScreenImage];
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                if (imageRef){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(count==0){
                            [self.delegate selectImage:image];
                            [self.navigationController popViewControllerAnimated:NO];
                           
                           // [imgView setImage:image];
                        }
                        if(count==1){
                            // [imageView2 setImage:image];
                        }
                        if(count==2){
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

@end
