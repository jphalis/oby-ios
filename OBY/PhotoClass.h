//
//  PhotoClass.h
//  

#import <Foundation/Foundation.h>


@interface PhotoClass : NSObject
@property (nonatomic, strong) NSString *category_url;
@property (nonatomic, retain) NSString *comment_count;
@property (nonatomic, retain) NSMutableArray *comment_set;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *creator;
@property (nonatomic, retain) NSString *creator_url;
@property (nonatomic, retain) NSString *PhotoId;
@property (nonatomic, retain) NSString *like_count;
@property (nonatomic, retain) NSMutableArray *likers;
@property (nonatomic, retain) NSString *modified;
@property (nonatomic, retain) NSString *photo;
@property (nonatomic, retain) NSString *slug;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, assign) BOOL isLike;
@end
