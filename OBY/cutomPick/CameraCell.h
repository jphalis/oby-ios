//
//  PhotoCell.h
//  CustomImagePicker
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Header.h"

@interface CameraCell : UICollectionViewCell
- (void) setAsset:(ALAsset *)asset;
- (void) setImage:(UIImage *)image;
- (UIImageView*) getImageView;
-(void) performSelectionAnimations;
-(void) hideTick;
-(void) showTick;
@property(nonatomic, strong) ALAsset *asset;
@end
