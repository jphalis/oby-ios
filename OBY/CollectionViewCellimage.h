//
//  CollectionViewCellimage.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface CollectionViewCellimage : UICollectionViewCell
@property (weak, nonatomic) IBOutlet SDIAsyncImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblLikes;
@property (weak, nonatomic) IBOutlet UILabel *lblComments;
@property (weak, nonatomic) IBOutlet UIButton *btnUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeBack;
@property (weak, nonatomic) IBOutlet UILabel *lblComentBack;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
@property (weak, nonatomic) IBOutlet UIImageView *imgLike;
@property (weak, nonatomic) IBOutlet UIButton *btnLikeList;
@property (weak, nonatomic) IBOutlet UIButton *btnCommentList;
@end
