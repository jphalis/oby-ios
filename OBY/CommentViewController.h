//
//  CommentViewController.h
//

#import <UIKit/UIKit.h>
#import "PhotoClass.h"


@protocol  CommentViewControllerDelegate <NSObject>
@required
-(void)setComment : (int)selectIndex commentCount :(NSString *)countStr;

@end

@interface CommentViewController : UIViewController

@property (nonatomic,assign)int selectRow;
@property (strong,nonatomic)PhotoClass *photoClass;
@property (nonatomic,assign) id<CommentViewControllerDelegate> delegate;

@end
