//
//  PhotoViewController.h
//  

#import <UIKit/UIKit.h>


@protocol  PhotoViewControllerDelegate <NSObject>
@required
-(void)removeImage;

@end

@interface PhotoViewController : UIViewController

@property (strong, nonatomic) NSString *photoURL;
@property (nonatomic, assign) id<PhotoViewControllerDelegate> delegate;

@end
