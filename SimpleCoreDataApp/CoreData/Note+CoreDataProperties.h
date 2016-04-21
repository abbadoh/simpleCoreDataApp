//
//  Note+CoreDataProperties.h
//  SimpleCoreDataApp
//
//  Created by v.y.ignatov on 12/02/2016.
//  Copyright © 2016 v.y.ignatov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface Note (CoreDataProperties)

@property (nullable, nonatomic, retain) id color;
@property (nullable, nonatomic, retain) NSDate *dateCreated;
@property (nullable, nonatomic, retain) NSString *text;

@end

NS_ASSUME_NONNULL_END
