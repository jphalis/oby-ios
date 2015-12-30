//
//  UIViewControllerAdditions.m
//

#import "UIViewControllerAdditions.h"
#import "AppDelegate.h"
#import <mach/mach.h>


@implementation UIViewController (UIViewControllerAdditions)

#pragma mark UIAlertView methods

- (void)showMessage:(NSString *)text withTitle:(NSString *)title {
	UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title 	
													message:text 
												   delegate:nil 
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	//[alert release];
}

-(void)showMessage:(NSString *)text withTag:(int)tag withTarget:(id)target {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:@"" 	
													message:text 
												   delegate:nil 
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
    [alert setDelegate:target];
    [alert setTag:tag];
    [alert show];
	//[alert release];
}

- (void)showMessage:(NSString *)text {
	UIAlertView * alert =[[UIAlertView alloc] initWithTitle:@"Alert"
													message:text
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	//[alert release];
}

#pragma mark ProgressView methods

-(void)setBusy:(BOOL)busy {
    AppDelegate *appDelegate =[AppDelegate getDelegate];
    if(!busy){
        [appDelegate hideHUDForView:self.view];
    } else {
        [appDelegate showHUDAddedTo:self.view];
    }
}

-(void)setBusyFront:(BOOL)busy {
    AppDelegate *appDelegate =[AppDelegate getDelegate];
    if(!busy){
        [appDelegate hideHUDForView:appDelegate.window];
    } else {
        [appDelegate showHUDAddedTo:appDelegate.window];
    }
}

-(void)setBusy:(BOOL)busy forMessage:(NSString*)message {
    AppDelegate *appDelegate =[AppDelegate getDelegate];
    if(!busy){
        [appDelegate hideHUDForView:self.view];
    } else {
        [appDelegate showHUDAddedTo:self.view message:message];
    }
}

-(void) updateProgressMessage:(NSString*)message {
    AppDelegate *appDelegate =[AppDelegate getDelegate];
    [appDelegate UpdateMessage:message];
}

#pragma mark - Utilities methods 
 
-(void)MemoryReport {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        //ALog(@"%@: Memory in use %d mb",NSStringFromClass([self class]),info.resident_size/(1024*1024));
        
    } else {
        //ALog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}

@end
