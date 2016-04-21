//
//  NotesManager.m
//  SimpleCoreDataApp
//
//  Created by v.y.ignatov on 12/02/2016.
//  Copyright © 2016 v.y.ignatov. All rights reserved.
//

#import "AppDelegate.h"
#import "NotesManager.h"
#import "PersistenceController.h"
#import "NetworkManager.h"
#import "Note.h"

static NSInteger const BACH_SIZE = 20;
static NSString * const ENTITY_NAME = @"Note";
static NSString * const ENTITY_DATE_KEY = @"dateCreated";

@interface NotesManager()

@property (strong, readonly) NSManagedObjectContext * backgroundContext;
@property (assign) NSInteger notesToSaveCounter;
@property (assign) NSInteger notesInContextCounter;
@property (strong, readonly) NSLock * countersLock;

@end

@implementation NotesManager

#pragma mark - Memory managment

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static NotesManager * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self initBackgroundContext];
        _notesToSaveCounter = 0;
        _notesInContextCounter = 0;
        _countersLock = [NSLock new];
    }
    return self;
}

- (void)initBackgroundContext
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        NSManagedObjectContext *moc = [PersistenceController sharedInstance].managedObjectContext;
        [self.backgroundContext setParentContext:moc];
    });
}

#pragma mark - Pulic methods

- (void)loadNotes:(NSInteger)number color:(UIColor *)color
{
    [self.countersLock lock];
    self.notesToSaveCounter +=number;
    [self.countersLock unlock];
    for (int loopCounter = 0; loopCounter < number; ++loopCounter)
    {
        [[NetworkManager sharedInstance] loadNoteWithCompletion:^(NSString *text, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                Note * newNote = (Note *)[NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.backgroundContext];
                newNote.dateCreated = [NSDate date];
                newNote.color = color;
                if (error) {
                    if (error.code == 3840) //serialization error
                    {
                        newNote.text = [NSString stringWithFormat:@"Api limit exceeded for %dth note", loopCounter + 1];
                    }
                    else
                    {
                        newNote.text = [NSString stringWithFormat:@"Server error in %dth note", loopCounter + 1];
                    }
                }
                else newNote.text = [NSString stringWithFormat:@"%@ %dth note", text, loopCounter + 1];
                [self saveBackgroundContextIfNeeded];
            });
        }];
    }
}

- (NSFetchedResultsController *)getFetchedControllerWithAscendingSort:(BOOL)isAscending
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [PersistenceController sharedInstance].privateContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:ENTITY_DATE_KEY ascending:isAscending];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:BACH_SIZE];
    NSFetchedResultsController * fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"Root"];
    return fetchedResultsController;
}

#pragma mark - Context Managment

- (void)saveBackgroundContextIfNeeded
{
    [self.countersLock lock];
    self.notesToSaveCounter --;
    self.notesInContextCounter ++;
    if ((self.notesInContextCounter >= BACH_SIZE && (self.notesToSaveCounter >= BACH_SIZE)) || self.notesToSaveCounter == 0)
    {
        self.notesInContextCounter = 0;
        [self.countersLock unlock];
        [self saveBackgroundContext];
    }
    else {
        [self.countersLock unlock];
    }
}

- (void)saveBackgroundContext
{
    [self.backgroundContext performBlockAndWait:^{
        NSError *error = nil;
        if([self.backgroundContext save:&error])
        {
            [[PersistenceController sharedInstance] save];
        }
        else {
            NSLog(@"error saving background ctx");
        }
    }];
}

@end
