//
//  PhotoCell.m
//  CustomImagePicker
//

#import "PhotoCell.h"

@interface PhotoCell ()
// 1
@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property(nonatomic, weak) IBOutlet UIImageView *tickView;

@end

@implementation PhotoCell

- (id)initWithFrame:(CGRect)frame {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    // Initialization code
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"PhotoCell" owner:self options:nil];
    
    if ([arrayOfViews count] < 1) {
      return nil;
    }
    
    if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
      return nil;
    }
    
    self = [arrayOfViews objectAtIndex:0];
    
  }
  
  return self;
}

-(void) showTick
{
  [self.tickView setHidden:NO];
}

-(void) hideTick
{
  [self.tickView setHidden:YES];
}

- (void) setAsset:(ALAsset *)asset
{
  // 2
  _asset = asset;
  self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

@end
