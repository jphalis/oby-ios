//
//  CategoryViewController.h
//

#import <UIKit/UIKit.h>


@protocol CategoryViewControllerDelegate <NSObject>
@required
-(void)chooseCategory:(NSString *)choosedCategory selectedIndex:(int)selectIndex;
@end

@interface CategoryViewController : UIViewController
@property (nonatomic,assign) id<CategoryViewControllerDelegate> delegate;
@end
