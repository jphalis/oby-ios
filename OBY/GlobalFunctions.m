//
//  GlobalFunctions.m
//  OBY
//

#import <Foundation/Foundation.h>
#import <KiipSDK/KiipSDK.h>

#import "defs.h"
#import "GlobalFunctions.h"
#import "Message.h"
#import "Reachability.h"
#import "TWMessageBarManager.h"


void checkNetworkReachability() {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Network Error"
                                                       description:NETWORK_UNAVAILABLE
                                                              type:TWMessageBarMessageTypeError
                                                          duration:6.0];
        //        [self showMessage:NETWORK_UNAVAILABLE];
        return;
    }
}

void doRewardCheck() {
    // Check REWARDCHECKURL
    // If `deserves_reward` == True, show Kiip reward
    // Subtract reward amount from user's available points
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@",REWARDCHECKURL];
        NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                 timeoutInterval:60];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
        [_request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            //            if(error != nil){
            //                NSLog(@"%@",error);
            //            }
            if ([data length] > 0 && error == nil){
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSString *rewardResult = [JSONValue objectForKey:@"deserves_reward"];
                if([rewardResult boolValue] == YES){
                    [[Kiip sharedInstance] saveMoment:@"being awesome!" withCompletionHandler:^(KPPoptart *poptart, NSError *error){
                        if (error){
                            // NSLog(@"Something's wrong");
                            // handle with an Alert dialog.
                        }
                        if (poptart){
                            // NSLog(@"Successful moment save. Showing reward.");
                            [poptart show];
                            
                            NSString *urlString = [NSString stringWithFormat:@"%@",REWARDREDEEMEDURL];
                            NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                                     timeoutInterval:60];
                            NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserName, GetUserPassword];
                            NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
                            NSString *base64String = [plainData base64EncodedStringWithOptions:0];
                            NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
                            [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
                            [_request setHTTPMethod:@"GET"];
                            
                            [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                            }];
                        }
                        if (!poptart){
                            // NSLog(@"Successful moment save, but no reward available.");
                        }
                    }];
                }
            }
        }];
    });
}

void showServerError() {
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Server Error"
                                                   description:SERVER_ERROR
                                                          type:TWMessageBarMessageTypeError
                                                      duration:4.0];
}

@implementation NSString(MyNSStringCategoryName)
+ (NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"k", @"m", @"b"];
        
        for (NSInteger i = abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    
    return abbrevNum;
}

+ (NSString *)floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}
@end
