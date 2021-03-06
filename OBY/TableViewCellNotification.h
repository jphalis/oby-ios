//
//  TableViewCellNotification.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface TableViewCellNotification : UITableViewCell

@property (weak, nonatomic) IBOutlet SDIAsyncImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UITextView *txtNotification;
@property (weak, nonatomic) IBOutlet UIButton *btnUsrProfile;
@property (weak, nonatomic) IBOutlet UILabel *usrUsername;
@property (weak, nonatomic) IBOutlet UILabel *usrFullname;

@end
