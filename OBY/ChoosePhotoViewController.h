//
//  ChoosePhotoViewController.h
//  OBY
//

#import <UIKit/UIKit.h>


@protocol  ChoosePhotoViewControllerDelegate <NSObject>
@required
-(void)selectImage :(UIImage*)imgSelect;
@end

@interface ChoosePhotoViewController : UIViewController
@property (nonatomic,assign) id<ChoosePhotoViewControllerDelegate> delegate;
@end
