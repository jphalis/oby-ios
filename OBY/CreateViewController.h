//
//  CreateViewController.h
//

#import <UIKit/UIKit.h>
#import "IBActionSheet.h"
#import <QuartzCore/QuartzCore.h>


@interface CreateViewController : UIViewController <UIActionSheetDelegate, IBActionSheetDelegate>
@property IBActionSheet *standardIBAS, *customIBAS, *funkyIBAS;
@end
