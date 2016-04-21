//
//  NetworkManager.h
//  SimpleCoreDataApp
//
//  Created by v.y.ignatov on 12/02/2016.
//  Copyright © 2016 v.y.ignatov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (instancetype)sharedInstance;

- (void)loadNoteWithCompletion:(void (^)(NSString *text, NSError *error))completion;

@end
