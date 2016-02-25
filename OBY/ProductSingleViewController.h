//
//  ProductSingleViewController.h
//  OBY
//

#import <UIKit/UIKit.h>


@protocol ProductSingleViewControllerDelegate <NSObject>
@required

@end

@interface ProductSingleViewController : UIViewController

@property (strong, nonatomic)NSString *owner;
@property (strong, nonatomic)UIImage *company_logo;
@property (strong, nonatomic)NSString *prod_title;
@property (strong, nonatomic)NSString *prod_descrip;
@property (strong, nonatomic)NSString *point_value;
@property (strong, nonatomic)NSString *prod_slug;
@property (nonatomic, assign) id<ProductSingleViewControllerDelegate> delegate;

@end
