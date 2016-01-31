//
//  Photo+CoreDataProperties.h
//  OBY
//
//  Created by JP Halis on 1/30/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Photo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Photo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *creator;
@property (nullable, nonatomic, retain) NSString *photo;
@property (nullable, nonatomic, retain) NSString *descrip;
@property (nullable, nonatomic, retain) NSString *like_count;
@property (nullable, nonatomic, retain) NSString *comment_count;

@end

NS_ASSUME_NONNULL_END
