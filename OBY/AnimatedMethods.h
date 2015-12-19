//
//  AnimatedMethods.h
//  Bridge
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AnimatedMethods : NSObject
+(BOOL)firstimage:(UIImage *)image1 isEqualTo:(UIImage *)image2;
+(void)animatedFadeHiddenWithAlpha:(UIView *)fromView;
+(void)animatedView:(UIView *)fromView secondView:(UIView *)toView;
+(void)animatedCurlDown:(UIView *)fromView secondView:(UIView *)toView;
+(void)animatedFlipFromTop:(UIView *)fromView secondView:(UIView *)toView;
+(void)example;
+(void)animatedFade:(UIView *)fromView;
+(void)curlUp:(UIView *)fromView;
+(void)animatedCurlUp:(UIView *)fromView secondView:(UIView *)toView;
+(void)animatedFadeEarse:(UIView *)fromView;
+(void)zoomIn:(UIView *)fromView;
+(void)zoomOut:(UIView *)fromView;
+(void)animatedFadeOut:(UIView *)fromView;
+(void)animatedFadeHidden:(UIView *)fromView;
+(void)animatedFadeShow:(UIView *)fromView;
+(void)animatedMovingView:(UIView *)fromView fromFrame:(CGRect) fromFrame toFrame:(CGRect) toFrame;

+(void)animatedFlipFrombottom:(UIView *)fromView secondView:(UIView *)toView;

+(void)animatedFlipFromRight:(UIView *)fromView secondView:(UIView *)toView;
+(void)animatedFlipFromLeft:(UIView *)fromView secondView:(UIView *)toView;

+(void)AnimateViewUP:(UIView *)view;
+(void)AnimateViewDown:(UIView *)view;

+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
