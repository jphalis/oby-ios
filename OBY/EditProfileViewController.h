//
//  EditProfileViewController.h
//

#import <UIKit/UIKit.h>

#import "IBActionSheet.h"


@interface EditProfileViewController : UIViewController <UIActionSheetDelegate, IBActionSheetDelegate>
@property IBActionSheet *standardIBAS, *customIBAS, *funkyIBAS;
-(void)callMethod;

@end
