//
//  AsyncImageView.h
//  ITDealer
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <AddressBook/AddressBook.h>

@protocol SDIAsyncImageViewDelegate;
@protocol SDIAsyncImageDownloaderDelegate;

// Image downloader

@interface SDIAsyncImageDownloader : NSObject {
    NSURLConnection *connection ;
    NSMutableData *data;
    NSString *strLocalFilePath;
    dispatch_queue_t            myQueue;
    int currentLength;
    int expectedLength;
#ifdef WITHOUT_ARC
    id<SDIAsyncImageDownloaderDelegate>delegate;
#endif
}

#ifdef WITHOUT_ARC
@property(nonatomic,assign) id<SDIAsyncImageDownloaderDelegate>delegate;
#else
@property(nonatomic,weak) id<SDIAsyncImageDownloaderDelegate>delegate;
#endif

-(void)DownloadImageForURL:(NSString *)imageURL;
-(void)CancelDownload;

@end

// Image download Manager

@interface SDIAsyncImageDownloadManager: NSObject
{
    NSMutableDictionary *dicCatache;
    NSMutableDictionary *dicCatacheDelegate;
    NSMutableDictionary *dicCatacheUDID;
}
+(id)defaultManager;
-(void)DownloadImageForURL:(NSString *)strURL withDelegate:(id<SDIAsyncImageDownloaderDelegate>)delegate;
-(void)RemoveDelegate:(id<SDIAsyncImageDownloaderDelegate>)delegate;

@end

@protocol SDIAsyncImageDownloaderDelegate <NSObject>

-(void)asyncImageDownloader:(SDIAsyncImageDownloader *)asimage didcompletedWithLocalURL:(NSString *)strURL;
@optional
-(void) asyncConnection :(NSURLConnection *) connection
      didReceiveResponse:(NSURLResponse *) response;
- (void)asyncConnection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData;
-(void)asyncconnection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end


@interface SDIAsyncImageView : UIImageView <NSURLConnectionDelegate,SDIAsyncImageDownloaderDelegate>{
	NSURLConnection *connection ;
	NSMutableData *data;
    NSString *strLocalFilePath;
    dispatch_queue_t            myQueue;
    BOOL shouldMask;
    UIActivityIndicatorView *acview;
    BOOL shouldShowLoader;
    MBProgressHUD *HUD;
    int currentLength;
    int expectedLength;
    int intRow;
#ifdef WITHOUT_ARC
   UITableViewCell *cell;
    id<SDIAsyncImageViewDelegate> delegate;
#endif
      NSMutableArray *arrDownloader;
    int type;
    BOOL isRemoved;
  
}

#ifdef WITHOUT_ARC
@property(nonatomic,assign) UITableViewCell *cell;
@property(nonatomic,assign)id<SDIAsyncImageViewDelegate> delegate;
#else 
@property(nonatomic,weak) UITableViewCell *cell;
@property(nonatomic,weak)id<SDIAsyncImageViewDelegate> delegate;
#endif
@property(nonatomic,assign)int intRow;
@property(nonatomic,assign)int type;
@property(nonatomic,assign)BOOL shouldMask;
@property(nonatomic,assign)BOOL shouldShowLoader;
- (void)AdddGestureWithDelegate:(id<SDIAsyncImageViewDelegate>)delegate;
- (void)loadImageFromURL:(NSString*)imageURL withTempImage:(NSString*)tempImage;
- (void)Setimage:(UIImage*)image withTempImageURL:(NSString*)tempImage;
- (void)loadImageFromURL:(NSString*)imageURL withthumbImage:(NSString*)thumbImage;
-(void)CancelAllDownload;
-(void)RemoveHud;

@end

@protocol SDIAsyncImageViewDelegate <NSObject>

@optional
-(void)asynchImageView:(SDIAsyncImageView *)mgView didCachedImage:(NSString *)strFilePath;
-(void)asynchImageViewDidTapped:(SDIAsyncImageView *)mgView;

@end

@interface SDIAsyncImageView (cache)
+(NSString *)GetCatchPath;
-(UIImage*)GetImageFromStroage:(NSString *)strID;
-(UIImage *)GetImageFromStroageForURL:(NSString *)strURL;
-(UIImage *)GetImageFromStroageForLiveURL:(NSString *)strURL;
-(void)DownloadImageForURL:(NSString *)imageURL;

@end
