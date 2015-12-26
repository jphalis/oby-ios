//
//  ProfileClass.h
//

#import <Foundation/Foundation.h>


@interface ProfileClass : NSObject

@property (nonatomic, retain) NSString *Id;
@property (nonatomic, strong) NSString *account_url;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *full_name;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSMutableArray *arrphoto_set;
@property (nonatomic, retain) NSMutableArray *arrfollowers;
@property (nonatomic, retain) NSMutableArray *arrfollowings;
@property (nonatomic, retain) NSString *profile_picture;
@property (nonatomic, retain) NSString *followers_count;
@property (nonatomic, retain) NSString *following_count;

@end
