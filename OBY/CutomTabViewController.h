//
//  CutomTabViewController.h
//

#import <UIKit/UIKit.h>


@interface CutomTabViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (strong, nonatomic) UICollectionView *currentView;

@end
