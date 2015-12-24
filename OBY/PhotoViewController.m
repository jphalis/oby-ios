//
//  PhotoViewController.m
//

#import "PhotoViewController.h"
#import "SDIAsyncImageView.h"
#import "AnimatedMethods.h"
#import "AppDelegate.h"
#import "AsyncImageView.h"
#import "defs.h"
#import "AnimatedMethods.h"


#define ZOOM_STEP 2.0


@interface PhotoViewController ()<UIScrollViewDelegate>{
    AppDelegate *appDelegate;
    
    __weak IBOutlet UIScrollView *imageScrollView;
    __weak IBOutlet SDIAsyncImageView *imageView;
}

@end

@implementation PhotoViewController
@synthesize photoURL;

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    self.view.backgroundColor = [UIColor colorWithHue:1 saturation:1 brightness:0 alpha:0.95];
    [super viewDidLoad];
    NSLog(@"%@",photoURL);
    
   // UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ClickImage:)];
   //[imageView addGestureRecognizer:tapGesture];
    
    // Do any additional setup after loading the view.
    
    //Setting up the scrollView
    imageScrollView.bouncesZoom = YES;
    imageScrollView.delegate = self;
    imageScrollView.clipsToBounds = YES;
    
    //Setting up the imageView
    // [imageView loadImageFromURL:photoURL withTempImage:@""];
   
    imageView.userInteractionEnabled = YES;
    imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    //Adding the imageView to the scrollView as subView
   // [imageScrollView addSubview:imageView];
    imageScrollView.contentSize = CGSizeMake(imageView.bounds.size.width, imageView.bounds.size.height);
    imageScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    //UITapGestureRecognizer set up
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    //Adding gesture recognizer
    [imageView addGestureRecognizer:doubleTap];
    [imageView addGestureRecognizer:twoFingerTap];
    
    UISwipeGestureRecognizer *viewDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown:)];
    viewDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:viewDown];
}

-(void)swipeDown:(UISwipeGestureRecognizer *)gestureRecognizer{
    CGRect toFrame = CGRectMake(0, +self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [self moveView:self.view fromFrame:self.view.frame toFrame:toFrame];
}

-(void)moveView:(UIView *)fromView fromFrame:(CGRect) fromFrame toFrame:(CGRect) toFrame{
    fromView.frame = fromFrame;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         fromView.frame = toFrame;
                         
                     }
                     completion:^(BOOL finished){
                         CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         
                         self.view.frame = newFrame;
                         [self.delegate removeImage];
                        // NSLog(@"completion block");
                     }
     ];
}

- (void)scrollViewDidZoom:(UIScrollView *)aScrollView {
    CGFloat offsetX = (imageScrollView.bounds.size.width > imageScrollView.contentSize.width)?
    (imageScrollView.bounds.size.width - imageScrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (imageScrollView.bounds.size.height > imageScrollView.contentSize.height)?
    (imageScrollView.bounds.size.height - imageScrollView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(imageScrollView.contentSize.width * 0.5 + offsetX,
                                   imageScrollView.contentSize.height * 0.5 + offsetY);
}

- (void)viewDidUnload {
    imageScrollView = nil;
    imageView = nil;
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // zoom in
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
    
    if (newScale > imageScrollView.maximumZoomScale){
        newScale = imageScrollView.minimumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [imageScrollView zoomToRect:zoomRect animated:YES];
    } else {
        newScale = imageScrollView.maximumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [imageScrollView zoomToRect:zoomRect animated:YES];
    }
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

-(void)viewWillAppear:(BOOL)animated{
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = 1.0;//This is the minimum scale, set it to whatever you want. 1.0 = default
    imageScrollView.maximumZoomScale = 3.0;
    imageScrollView.minimumZoomScale = minimumScale;
    imageScrollView.zoomScale = minimumScale;
    [imageScrollView setContentMode:UIViewContentModeScaleAspectFit];
    //[imageView sizeToFit];
    [imageScrollView setContentSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];

    NSLog(@"%@",photoURL);
    
    SetisFullView(YES);
    [AnimatedMethods zoomIn:self.view];
    
    //[imageView loadImageFromURL:photoURL withTempImage:@""];
    SetIsImageView(YES);
  [imageView loadImageFromURL:photoURL withTempImage:@""];
    imageView.shouldShowLoader = YES;
    
    [super viewWillAppear:YES];
   // appDelegate.tabbar.tabView.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    SetIsImageView(NO);
    imageView.image = nil;
    [self.delegate removeImage];
}

-(void)ClickImage:(UITapGestureRecognizer *)gestureRecognizer{
    [self.delegate removeImage];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onCancelClick:(id)sender {
    [self.delegate removeImage];
}

@end
