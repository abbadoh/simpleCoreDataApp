//
//  PersistenceController.m
//  SimpleCoreDataApp
//
//  Created by v.y.ignatov on 11/02/2016.
//  Copyright © 2016 v.y.ignatov. All rights reserved.
//

#import "PersistenceController.h"

@interface PersistenceController()

@property (strong, readwrite) NSManagedObjectContext *managedObjectContext;


@end

@implementation PersistenceController

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PersistenceController * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self initializeCoreData];
    }
    return self;
}

- (void)initializeCoreData
{
    if (self.managedObjectContext) return;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SimpleCoreDataApp" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    self.privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.privateContext setPersistentStoreCoordinator:coordinator];
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.managedObjectContext setParentContext:self.privateContext];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSPersistentStoreCoordinator *psc = [self.privateContext persistentStoreCoordinator];
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption] = @YES;
        options[NSSQLitePragmasOption] = @{ @"journal_mode":@"DELETE" };
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"DataModel.sqlite"];
        NSError *error = nil;
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
    });
}

- (void)save;
{
    if (![self.privateContext hasChanges] && ![self.managedObjectContext hasChanges]) return;
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if([self.managedObjectContext save:&error])
        {
            [self.privateContext performBlock:^{
                NSError *privateError = nil;
                if(![self.privateContext save:&privateError]) {
                    NSLog(@"error saving private context");
                }
            }];
        }
        else {
            NSLog(@"error saving main context");
        }
    }];
}

@end
