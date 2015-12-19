//
//  UIViewControllerAdditions.h
//  MapCut
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIViewController (UIViewControllerAdditions)
-(void) showMessage:(NSString *)text withTitle:(NSString *)title;
-(void) showMessage:(NSString *)text withTag:(int)tag withTarget:(id)target;
-(void) showMessage:(NSString *)text ;

-(void) MemoryReport ;
-(void) updateProgressMessage:(NSString*)message;
-(void) setBusy:(BOOL)busy;
-(void) setBusy:(BOOL)busy forMessage:(NSString*)message;
@end
