//
//  PhotoCell.h
//  CustomImagePicker
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoCell : UICollectionViewCell
- (void) setAsset:(ALAsset *)asset;
-(void) performSelectionAnimations;
-(void) hideTick;
-(void) showTick;
@property(nonatomic, strong) ALAsset *asset;
@end
