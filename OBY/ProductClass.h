//
//  ProductClass.h
//  

#import <Foundation/Foundation.h>


@interface ProductClass : NSObject

@property (nonatomic, retain) NSString *product_id;
@property (nonatomic, assign) BOOL is_listed;
@property (nonatomic, assign) BOOL is_featured;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, retain) NSString *slug;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *cost;
@property (nonatomic, retain) NSString *discount_cost;
@property (nonatomic, retain) NSString *promo_code;
@property (nonatomic, retain) NSMutableArray *buyers;
@property (nonatomic, assign) BOOL is_useable;
@property (nonatomic, retain) NSString *max_downloads;
@property (nonatomic, retain) NSString *list_date_start;
@property (nonatomic, retain) NSString *list_date_end;
@property (nonatomic, retain) NSString *use_date_start;
@property (nonatomic, retain) NSString *use_date_end;
@property (nonatomic, assign) BOOL is_purchased;

@end
