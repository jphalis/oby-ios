//
//  TableViewCellProducts.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface TableViewCellProducts : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UILabel *pointValue;
@property (weak, nonatomic) IBOutlet SDIAsyncImageView *companyLogo;

@end
