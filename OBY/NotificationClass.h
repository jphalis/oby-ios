//
//  NotificationClass.h
//

#import <Foundation/Foundation.h>


@interface NotificationClass : NSObject

@property (nonatomic, strong) NSString *NotificationCount;
@property (nonatomic, retain) NSString *next;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSString *previous;
@property (nonatomic, retain) NSString *read;
@property (nonatomic, retain) NSString *display_thread;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSString *sender_url;
@property (nonatomic, retain) NSString *sender_profile_picture;
@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *verb;
@property (nonatomic, retain) NSAttributedString *commentText;
@property (nonatomic, retain) NSString *recipient;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *modified;
@property (nonatomic, retain) NSString *target_url;
@property (nonatomic, retain) NSString *target_photo;

@end
