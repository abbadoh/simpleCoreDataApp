//
//  PersistenceController.h
//  SimpleCoreDataApp
//
//  Created by v.y.ignatov on 11/02/2016.
//  Copyright © 2016 v.y.ignatov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^InitCallbackBlock)(void);

@interface PersistenceController : NSObject

@property (strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong) NSManagedObjectContext *privateContext;

+ (instancetype)sharedInstance;

- (void)save;

@end
