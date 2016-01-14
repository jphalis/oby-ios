//
//  PhotoViewController.h
//  

#import <UIKit/UIKit.h>


@protocol PhotoViewControllerDelegate <NSObject>
@required
-(void)removeImage;

@end

@interface PhotoViewController: UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) NSString *PhotoId;
@property (strong, nonatomic) NSString *photoURL;
@property (strong, nonatomic) NSString *photoDeleteURL;
@property (strong, nonatomic) NSString *photoCreator;
@property (nonatomic, assign) id<PhotoViewControllerDelegate> delegate;

- (IBAction)actionSheetButtonPressed:(id)sender;

@end
