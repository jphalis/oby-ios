//
//  CreateViewController.h
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "IBActionSheet.h"


@interface CreateViewController : UIViewController <UIActionSheetDelegate, IBActionSheetDelegate>

@property IBActionSheet *standardIBAS, *customIBAS, *funkyIBAS;

@end
