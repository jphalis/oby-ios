//
//  AsyncImageView.m
//  ITDealer
//

#import "SDIAsyncImageView.h"
#import "defs.h"
#import "UIImageExtras.h"
#import "UIImage+GIF.h"

#ifdef WITHOUT_ARC
#define Destroy(x)  if(x!=nil){if([x respondsToSelector:@selector(retainCount)] && [x retainCount]>0){[x release];}x=nil;}
#else
#define Destroy(x) x=nil;
#endif

///#define WITHOUT_ARC
@implementation SDIAsyncImageDownloader
@synthesize delegate;
 
-(id)init
{
    self=[super init];
    if(self)
    {
#ifdef WITHOUT_ARC
        Destroy(strLocalFilePath);
#endif
        connection=nil;
        data=nil;
    }
    return self;
}
-(void)DownloadImageForURL:(NSString *)imageURL {
    
    NSString *lpath = [imageURL lastPathComponent];
    strLocalFilePath = [[NSString alloc] initWithFormat:@"%@/%@",[SDIAsyncImageView GetCatchPath],lpath];
#ifdef WITHOUT_ARC
    if (connection!=nil && [connection respondsToSelector:@selector(retainCount)])
#else
    if (connection!=nil)
#endif
    {
            
        [connection cancel];
        //[connection release];
    }
    //in case we are downloading a 2nd image
    if (data!=nil) {
#ifdef WITHOUT_ARC
        [data release];
#else
        data=nil;
#endif
    }
    MQ_
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //notice how delegate set to self object
    
    if(connection!=nil) {
        /*
        if(shouldShowLoader==YES)
        {
            [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
            HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
            HUD.mode=MBProgressHUDModeAnnularDeterminate;
            
        }
        */
        data = [[NSMutableData alloc] init];
    }
    _MQ
}
-(void)connection:(NSURLConnection *)Mconnection didFailWithError:(NSError *)error {
    if(delegate && [delegate respondsToSelector:@selector(asyncconnection:didFailWithError:)]) {
        [delegate asyncconnection:Mconnection didFailWithError:error];
    }
     connection=nil;
}

-(void) connection :(NSURLConnection *) Mconnection
 didReceiveResponse:(NSURLResponse *) response {
    if(delegate && [delegate respondsToSelector:@selector(asyncConnection:didReceiveResponse:)]) {
        [delegate asyncConnection:Mconnection didReceiveResponse:response];
    }
}
//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	
    if (data==nil) { data = [[NSMutableData alloc] init]; }
	[data appendData:incrementalData];
    
    if(delegate && [delegate isKindOfClass:[SDIAsyncImageView class]] && [delegate respondsToSelector:@selector(asyncConnection:didReceiveData:)])
    {
        [delegate asyncConnection:theConnection didReceiveData:incrementalData];
    }
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//so self data now has the complete image
	
    if(data != nil && data.length>1260){
        UIImage *mg = [UIImage imageWithData:data];
        if(mg == nil){
            [delegate asyncconnection:connection didFailWithError:nil];
        } else {
            if(mg.size.width >300 || mg.size.height>300){
                mg=[mg ScaleImageToRect:mg displaySize:CGSizeMake(800, 600)];
            }
            NSData *newData=UIImagePNGRepresentation(mg);
            if(newData != nil){
                [newData writeToFile:strLocalFilePath atomically:YES];
            } else {
                [data writeToFile:strLocalFilePath atomically:YES];
            }
            
            [delegate asyncImageDownloader:self didcompletedWithLocalURL:strLocalFilePath];
        }

        Destroy(data);

        data=nil;
    }
    connection=nil;
	
}
-(void)CancelDownload{
    if(connection){
        [connection cancel]; //in case the URL is still downloading
        Destroy(connection)
    } else {

    }
}

- (void)dealloc {
    if(connection){
        [connection cancel]; //in case the URL is still downloading
        Destroy(connection)
    }
    Destroy(data);
    Destroy(strLocalFilePath)
#ifdef WITHOUT_ARC
    [super dealloc];
#endif
}

@end

static SDIAsyncImageDownloadManager *_defaultManger=nil;

@implementation SDIAsyncImageDownloadManager

+(id)defaultManager {
    if(_defaultManger==nil) {
        _defaultManger=[[SDIAsyncImageDownloadManager alloc]init];
    }
    return _defaultManger;
}

-(void)LoadCatche{
    dicCatache = [[NSMutableDictionary alloc] init];
    dicCatacheDelegate = [[NSMutableDictionary alloc] init];
    dicCatacheUDID = [[NSMutableDictionary alloc] init];
}

-(void)DownloadImageForURL:(NSString *)strURL withDelegate:(id<SDIAsyncImageDownloaderDelegate>)delegate andUDID:(NSString *)stUDIDKey{
    
    if(strURL != nil && strURL.length > 0 && stUDIDKey!=nil){
        NSString *lpath =[strURL lastPathComponent];
        [dicCatacheDelegate setValue:lpath forKey:stUDIDKey];
        [dicCatache setValue:delegate forKey:stUDIDKey];
        [dicCatacheUDID setValue:stUDIDKey forKey:lpath];
        
        SDIAsyncImageDownloader *downloader = [[SDIAsyncImageDownloader alloc]init];
        [downloader setDelegate:self];
        [downloader DownloadImageForURL:strURL];
        //[arrDownloader addObject:downloader];
#ifdef WITHOUT_ARC
        [downloader release];
#endif
        downloader = nil;
    }
}

-(void)RemoveDelegate:(id<SDIAsyncImageDownloaderDelegate>)delegate{
    
}
/*
-(void)asyncImageDownloader:(AsyncImageDownloader *)asimage didcompletedWithLocalURL:(NSString *)strURL
{
 
    NSString *cpath =[strURL lastPathComponent];
    
    NSString *stUDID =[dicCatacheUDID objectForKey:cpath];
    BOOL isValidUpdate=NO;
    if(stUDID!=nil && [stUDID isKindOfClass:[NSString class]])
    {
        NSString *strOldPath =[dicCatache objectForKey:stUDID];
        
        if(strOldPath!=nil && [strOldPath isEqualToString:cpath])
        {
            [dicCatache removeObjectForKey:stUDID];
            [dicCatacheUDID removeObjectForKey:cpath];
            [dicCatacheDelegate removeObjectForKey:stUDID];
            
            
            isValidUpdate=YES;
            id<AsyncImageDownloaderDelegate> mdelegate =[dicCatacheDelegate objectForKey:stUDID];
            if(mdelegate && [mdelegate respondsToSelector:@selector(asynchImageView:didCachedImage:)])
            {
                
                [mdelegate asynchImageView:self didCachedImage:strURL];
            }
        }
    }
    
    if(isValidUpdate==NO)
        NSLog(@"Older download");
}
 */
@end

@implementation SDIAsyncImageView (cache)

static NSString *strCachePath = nil;

+(NSString *)GetCatchPath{
    if(strCachePath == nil){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];

        NSString *categoryFolder =[NSString stringWithFormat:@"%@/BridgeImages",documentsDirectory];
        BOOL isDir = YES;
        if(![[NSFileManager defaultManager] fileExistsAtPath:categoryFolder isDirectory:&isDir]){
            NSError *error = nil;
            [[NSFileManager defaultManager]createDirectoryAtPath:categoryFolder withIntermediateDirectories:YES attributes:nil error:&error];
        }
        strCachePath = [[NSString alloc]initWithFormat:@"%@",categoryFolder];
        
    }
    return strCachePath;
}
#pragma mark - Image Utilities

-(UIImage*)GetImageFromStroage:(NSString *)strID{
    NSString *file = [NSString stringWithFormat:@"%@/%@",strCachePath,strID];
//    NSLog(@"FILE: %@",file);
    NSFileManager *fmg = [NSFileManager defaultManager];
    if([fmg fileExistsAtPath:file]){
        UIImage*img = [UIImage imageWithContentsOfFile:file];
        return img;
    }
    return nil;
}

-(UIImage *)GetImageFromStroageForURL:(NSString *)strURL{
    NSFileManager *fmg = [NSFileManager defaultManager];
    if([fmg fileExistsAtPath:strURL]){
        UIImage *img = [UIImage imageWithContentsOfFile:strURL];
        return img;
    }
    return nil;
}

-(UIImage *)GetImageFromStroageForLiveURL:(NSString *)strURL{
    NSString *lpath = [strURL lastPathComponent];
    NSString *path = [NSString stringWithFormat:@"%@/%@",strCachePath,lpath];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path]){
        UIImage *img = [UIImage imageWithContentsOfFile:strLocalFilePath];
        return img;
    }
    return nil;
}

@end

@implementation SDIAsyncImageView
@synthesize shouldMask;
@synthesize shouldShowLoader;
@synthesize delegate;
@synthesize intRow;
@synthesize type;
@synthesize cell;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        arrDownloader = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc{
    delegate = nil;
    Destroy(strLocalFilePath);
    [self CancelAllDownload];
#ifdef WITHOUT_ARC
    [super dealloc];
#endif
}

-(void)removeFromSuperview{
      delegate = nil;
    [self CancelAllDownload];
    isRemoved = YES;
    //XLog(@"Removed from superView ");
}

-(void)AdddGestureWithDelegate:(id<SDIAsyncImageViewDelegate>)delegate{
    self.userInteractionEnabled = YES;
    self.delegate = delegate;
    UITapGestureRecognizer *oneTouch=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(OneTouchHandeler)];
   [oneTouch setNumberOfTouchesRequired:1];
    [oneTouch setNumberOfTapsRequired:1];
    [self addGestureRecognizer:oneTouch];
#ifdef WITHOUT_ARC
    [oneTouch release];
#endif
}

-(void)OneTouchHandeler{
    if(delegate && [delegate respondsToSelector:@selector(asynchImageViewDidTapped:)]){
        [delegate asynchImageViewDidTapped:self];
    }
}

-(void)CancelAllDownload{
    for(int i = 0; i < [arrDownloader count]; i++){
        SDIAsyncImageDownloader *downloder = [arrDownloader objectAtIndex:i];
        downloder.delegate = nil;
        [downloder CancelDownload];
        [arrDownloader removeObjectAtIndex:i];
        i = 0;
    }
}

- (void)Setimage:(UIImage*)image withTempImageURL:(NSString*)tempImage{
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(image == nil){
              dispatch_async(dispatch_get_main_queue(), ^{
                  self.image = [UIImage imageNamed:tempImage];
              });
            return;
        }
        
        if(shouldMask){
            UIImage *mask = [UIImage imageNamed:@"mask_bg"];
            UIImage *mgMasked = [self maskImage:image withMask:mask];
            mgMasked = [mgMasked ScaleImageToRect:mgMasked displaySize:self.frame.size];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = mgMasked;
                [self setNeedsDisplay];
            });
        } else {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self setImage:image];
              });
        }
    });
}

- (void)loadImageFromURL:(NSString*)imageURL withTempImage:(NSString*)tempImage {
    //myQueue=[del GetDownloadQueue];
    
    if(imageURL != nil && imageURL.length > 0){
        self.backgroundColor = [UIColor clearColor];
        NSString *lpath = [imageURL lastPathComponent];
        Destroy(strLocalFilePath);
        strLocalFilePath = [[NSString alloc] initWithFormat:@"%@/%@",[SDIAsyncImageView GetCatchPath],lpath];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if(![fm fileExistsAtPath:strLocalFilePath]){
            if(tempImage != nil){
              self.contentMode = UIViewContentModeScaleAspectFill;
                self.image = [UIImage imageNamed:tempImage];
            } else {
                self.image = nil;
            }
           [self.superview setNeedsDisplay];
            
            if(shouldShowLoader == YES){
                [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
                HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
                HUD.mode = MBProgressHUDModeIndeterminate;
               // HUD.mode=MBProgressHUDModeAnnularDeterminate;
                
            }
            
            SDIAsyncImageDownloader *downloader = [[SDIAsyncImageDownloader alloc]init];
            [downloader setDelegate:self];
            [downloader DownloadImageForURL:imageURL];
            [arrDownloader addObject:downloader];
            #ifdef WITHOUT_ARC
                [downloader release];
            #endif
        } else {
            self.backgroundColor = [UIColor clearColor];
           // dispatch_async(myQueue, ^{
                
                if(shouldMask){
                    UIImage *mg = [UIImage imageWithContentsOfFile:strLocalFilePath];
                    UIImage *mask = [UIImage imageNamed:@"mask_bg@2x.png"];
                    UIImage *mgMasked = [self maskImage:mg withMask:mask];
                    
                    //mgMasked=[mgMasked ScaleImageToRect:mgMasked displaySize:self.frame.size];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = mgMasked;
                        [self setNeedsDisplay];
                    });
                    //[self setImage:mgMasked];
                    //[self performSelectorOnMainThread:@selector(setImage:) withObject:mgMasked waitUntilDone:YES];
                } else {
                   //self.contentMode=UIViewContentModeScaleToFill;
                    //self.contentMode=UIViewContentModeScaleAspectFit;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //NSLog(@"PATH:%@",strLocalFilePath);
                       // NSString *strpathing=@"/Users/sdi/Library/Developer/CoreSimulator/Devices/D53ECC1D-D72A-47A5-A32C-88D940CA2FAF/data/Containers/Data/Application/3E98DE99-4724-4E61-8E3C-E9F7890D95F2/Library/Caches/BridgeImages/1.png";/Volumes/DATA/Saravanan/Project/Casting/source/jul 1/Casting july 7.zip
                        UIImage *mg = [self GetImageFromStroageForURL:strLocalFilePath];//strLocalFilePath
                        if(mg != nil){
                           //saravanan
                           //  self.contentMode=UIViewContentModeCenter;
                           // if(GetIsIpad==YES){
                                   // mg =[mg cropCenterAndScaleImageToSize:self.frame.size];
                            
                            if(GetsFullView == YES){
                                self.contentMode = UIViewContentModeScaleAspectFit;
                                SetisFullView(NO);
                            } else {
                                
                               //mg = [mg cropCenterAndScaleImageToSize:self.frame.size];
                             mg = [mg imageByScalingAndCroppingForSize:self.frame.size];
                               
                               // mg = [mg ScaleImageToRect:mg displaySize:self.frame.size];
                                //self.contentMode = UIViewContentModeTop;
                                
                                  //  self.contentMode = UIViewContentModeScaleToFill;
                            }
                            self.image = mg;
                            [self setNeedsDisplay];
                        } else {
//                            NSLog(@"Img is nil");
                        }
                    });
                    
                    //self.image = [UIImage imageWithContentsOfFile:strLocalFilePath];
                }
           // });
        }
    } else {
        if(tempImage != nil){
            // NSLog(@"Temp image loaded");
            //self.contentMode = UIViewContentModeCenter;
                self.contentMode = UIViewContentModeScaleToFill;
            //self.contentMode = UIViewContentModeScaleAspectFit;
            self.image = [UIImage imageNamed:tempImage];
        }
        //self.image = nil;
    }
}

- (void)loadImageFromURL:(NSString*)imageURL withthumbImage:(NSString*)thumbImage {
    //myQueue=[del GetDownloadQueue];
    
    if(imageURL != nil && imageURL.length > 0){
        self.backgroundColor = [UIColor lightGrayColor];
        NSString *lpath = [imageURL lastPathComponent];
        Destroy(strLocalFilePath);
        strLocalFilePath = [[NSString alloc] initWithFormat:@"%@/%@",strCachePath,lpath];
        NSFileManager *fm = [NSFileManager defaultManager];
     
        if(![fm fileExistsAtPath:strLocalFilePath]){
            if(thumbImage != nil){
                //self.contentMode = UIViewContentModeCenter;
                 NSString *lpath2 = [thumbImage lastPathComponent];
                NSString *mgURL = [NSString stringWithFormat:@"%@/%@",strCachePath,lpath2];
                self.image = [UIImage imageWithContentsOfFile:mgURL];
            }
            if(shouldShowLoader == YES){
                [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
                HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
              //  HUD.mode = MBProgressHUDModeAnnularDeterminate;
                HUD.mode = MBProgressHUDModeIndeterminate;
            }
           // NSLog(@"New download :%@",imageURL);
            
            SDIAsyncImageDownloader *downloader = [[SDIAsyncImageDownloader alloc]init];
            [downloader setDelegate:self];
            [downloader DownloadImageForURL:imageURL];
            if(arrDownloader == nil )
                arrDownloader = [[NSMutableArray alloc]init];
            
            [arrDownloader addObject:downloader];
            //NSLog(@"Downloader count:%@",arrDownloader);
            #ifdef WITHOUT_ARC
                [downloader release];
            #endif
        } else {
            self.backgroundColor = [UIColor clearColor];
            // dispatch_async(myQueue, ^{
            
            if(shouldMask){
                UIImage *mg = [UIImage imageWithContentsOfFile:strLocalFilePath];
                UIImage *mask = [UIImage imageNamed:@"mask_bg@2x.png"];
                UIImage *mgMasked = [self maskImage:mg withMask:mask];
                mgMasked = [mgMasked ScaleImageToRect:mgMasked displaySize:self.frame.size];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = mgMasked;
                    [self setNeedsDisplay];
                });
                //[self setImage:mgMasked];
                //[self performSelectorOnMainThread:@selector(setImage:) withObject:mgMasked waitUntilDone:YES];
            } else {
                // self.contentMode=UIViewContentModeScaleToFill;
                UIImage *mg = [self GetImageFromStroageForURL:strLocalFilePath];
                
                self.image = mg;
                //self.image = [UIImage imageWithContentsOfFile:strLocalFilePath];
            }
            // });
        }
    } else {
        if(thumbImage != nil){
            NSString *lpath2 = [thumbImage lastPathComponent];
            NSString *mgURL = [NSString stringWithFormat:@"%@/%@",strCachePath,lpath2];
            self.image = [UIImage imageWithContentsOfFile:mgURL];
        }
    }
}

-(void)RemoveHude{
    
}

-(void)asyncConnection: (NSURLConnection *) connection
 didReceiveResponse:(NSURLResponse *) response{

    if(shouldShowLoader == YES){
        expectedLength = [response expectedContentLength];
        currentLength = 0;
        //HUD.mode = MBProgressHUDModeDeterminate;
    }
    // NSLog(@"download response");
}

//the URL connection calls this repeatedly as data arrives
- (void)asyncConnection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    currentLength += incrementalData.length;
    //NSLog(@"download len:%d",incrementalData.length);
    if(shouldShowLoader == YES && HUD != nil){
        HUD.progress = currentLength / (float)expectedLength;
    }
}

-(void)asyncImageDownloader:(SDIAsyncImageDownloader *)asimage didcompletedWithLocalURL:(NSString *)strURL{
    [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
	//Destroy(connection)
    //NSLog(@"%@=>%@",strLocalFilePath,strURL);
//    NSFileManager *defMngr = [NSFileManager defaultManager];
  
    if([strLocalFilePath isEqualToString:strURL]){
        if(delegate && [delegate respondsToSelector:@selector(asynchImageView:didCachedImage:)]){
            [delegate asynchImageView:self didCachedImage:strURL];
        }
//        NSLog(@"Download URL:%@",strURL);
        self.autoresizingMask = ( UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight );
        if(isRemoved == YES){return;}
        [self UpdateImage:strURL];
    } else {
//         NSLog(@"Not found");
    }
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//so self data now has the complete image
 
	//Destroy(connection)
    MQ_
    self.autoresizingMask = ( UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight );
    [self UpdateImage:strLocalFilePath];
    [self setNeedsLayout];
    _MQ
   
	//NSLog(@"end");
}

-(void)RemoveHud{
    if(shouldShowLoader == YES){
        shouldShowLoader = NO;
//        NSLog(@"Hud removed");
        [MBProgressHUD hideHUDForView:self animated:YES];
        HUD = nil;
    }
}

-(void)HidProgressBar{
    if(shouldShowLoader == YES){
//        NSLog(@"Hud removed");
        [MBProgressHUD hideHUDForView:self animated:YES];
        HUD = nil;
    }
}

-(void)asyncconnection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
   [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:NO];
}

-(void)UpdateImage:(NSString*)filename{
   //self.contentMode=UIViewContentModeScaleToFill;
    if(isRemoved == YES){return;}
    
    self.backgroundColor = [UIColor clearColor];
    if(shouldMask){
        UIImage *mg = [UIImage imageWithContentsOfFile:filename];
        UIImage *mask = [UIImage imageNamed:@"mask_bg"];
        UIImage *mgMasked = [self maskImage:mg withMask:mask];
        [self performSelectorOnMainThread:@selector(setImage:) withObject:mgMasked waitUntilDone:YES];
    } else {
        UIImage *mg = [UIImage imageWithContentsOfFile:filename];
        
        if(GetsFullView == YES){
            self.contentMode = UIViewContentModeScaleAspectFit;
            SetisFullView(NO);
        } else {
            mg = [mg imageByScalingAndCroppingForSize:self.frame.size];
            self.contentMode=UIViewContentModeScaleToFill;
        }
        [self performSelectorOnMainThread:@selector(setImage:) withObject:mg waitUntilDone:YES];
    }
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}

/*
//just in case you want to get the image directly, here it is in subviews
- (UIImage*) image {
	return [self image];
}

*/

@end
