//
//  NotesManager.h
//  SimpleCoreDataApp
//
//  Created by v.y.ignatov on 12/02/2016.
//  Copyright © 2016 v.y.ignatov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersistenceController.h"

@interface NotesManager : NSObject

+ (instancetype)sharedInstance;

- (void)loadNotes:(NSInteger)number color:(UIColor*)color;
- (NSFetchedResultsController *)getFetchedControllerWithAscendingSort:(BOOL)isAscending;

@end
