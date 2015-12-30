//
//  AnimatedMethods.m
//  Bridge
//

#import "AnimatedMethods.h"
#import <UIKit/UIKit.h>

@implementation AnimatedMethods

+(void)animatedView:(UIView *)fromView secondView:(UIView *)toView{
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCurlUp
                    completion:nil];
}
+(void)animatedCurlDown:(UIView *)fromView secondView:(UIView *)toView{
    [UIView transitionFromView:fromView
                    toView:toView
                  duration:0.5
                   options:UIViewAnimationOptionTransitionCurlDown
                completion:nil];
}

+(void)animatedFlipFrombottom:(UIView *)fromView secondView:(UIView *)toView{
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    completion:nil];
}

+(void)animatedFlipFromTop:(UIView *)fromView secondView:(UIView *)toView{
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    completion:nil];
}

+(void)animatedFlipFromLeft:(UIView *)fromView secondView:(UIView *)toView{
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:nil];
}

+(void)animatedFlipFromRight:(UIView *)fromView secondView:(UIView *)toView{
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil];
}

+(void)example{
//    NSLog(@"example success");
}

+(void)animatedFade:(UIView *)fromView{
    fromView.alpha = 0.0;
    [UIView animateWithDuration:1.0
                      delay:0.0
                    options:UIViewAnimationOptionTransitionFlipFromTop
                 animations:^{
                     fromView.alpha = 1.0;
                 }
                 completion:nil
 ];
}

+(void)animatedFadeOut:(UIView *)fromView{
    [UIView animateWithDuration:1.0
                     animations:^{fromView.alpha=0.0;}
                     completion:^(BOOL finished){ [fromView removeFromSuperview];
                      fromView.alpha=1.0;
                     }];
   
    //[fromView removeFromSuperview];
}

+(void)animatedFadeHiddenWithAlpha:(UIView *)fromView{
    [UIView animateWithDuration:0.8 animations:^{
        fromView.alpha = 0;
    } completion: ^(BOOL finished) {
        fromView.hidden = finished;
        fromView.alpha=1;
    }];
}

+(void)animatedFadeHidden:(UIView *)fromView{
    [UIView animateWithDuration:0.8 animations:^{
        fromView.alpha = 0;
    } completion: ^(BOOL finished) {
        fromView.hidden = finished;
        
    }];
    
    /*
    [UIView animateWithDuration:1.0
                     animations:^{fromView.alpha=0.0;}
                     completion:^(BOOL finished){ [fromView setHidden:YES]; }];
    */
}

+(void)animatedFadeShow:(UIView *)fromView{
    fromView.alpha = 0;
    fromView.hidden = NO;
    [UIView animateWithDuration:1.5 animations:^{
        fromView.alpha = 1;
    }completion:^(BOOL finished){
        
    }
     ];

    /*
    [UIView animateWithDuration:1.0
                     animations:^{fromView.alpha=1.0;}
                     completion:^(BOOL finished){ [fromView setHidden:NO]; }];
    */
}

+(void)animatedFadeEarse:(UIView *)fromView{
    fromView.alpha = 1.0;
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         fromView.alpha = 0.0;
                     }
                     completion:nil
     ];
}

+(void)curlUp:(UIView *)fromView{
    fromView.alpha = 1.0;
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCurlUp
                     animations:^{
                         fromView.alpha = 1.0;
                     }
                     completion:nil
     ];
}

+(void)animatedCurlUp:(UIView *)fromView secondView:(UIView *)toView{
    [UIView transitionWithView:fromView duration:1.0
                   options:UIViewAnimationOptionTransitionCurlUp
                animations:^ { [toView removeFromSuperview]; }
                completion:nil];
}

+(void)zoomIn:(UIView *)fromView{    
    [UIView animateWithDuration:0 animations:^{
        fromView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.2 animations:^{
            fromView.transform = CGAffineTransformIdentity;
        }completion:^(BOOL finished){
        }];
    }];
}

+(void)zoomOut:(UIView *)fromView{
    [UIView animateWithDuration:0 animations:^{
        fromView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 animations:^{
            fromView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            
        }completion:^(BOOL finished){
           
            [fromView removeFromSuperview];
        }];
    }];
}

+(void)animatedMovingView:(UIView *)fromView fromFrame:(CGRect) fromFrame toFrame:(CGRect) toFrame{
    fromView.frame = fromFrame;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         fromView.frame = toFrame;
                     }
                     completion:nil
     ];
}

+(void)AnimateViewUP:(UIView *)view{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = view.frame;
        frame.origin.y -=20 ;
        view.frame= frame;
    }];
}

+(void)AnimateViewDown:(UIView *)view{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = view.frame;
        frame.origin.y =0;
        view.frame= frame;
    }];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(BOOL)firstimage:(UIImage *)image1 isEqualTo:(UIImage *)image2 {
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqualToData:data2];
}

@end
