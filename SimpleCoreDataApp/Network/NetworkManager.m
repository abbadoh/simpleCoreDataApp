//
//  NetworkManager.m
//  SimpleCoreDataApp
//
//  Created by v.y.ignatov on 12/02/2016.
//  Copyright © 2016 v.y.ignatov. All rights reserved.
//

#import "NetworkManager.h"

static NSString * const URL = @"http://www.randomtext.me/api/lorem/p-1/1-10";
static NSString * const TEXT_KEY = @"text_out";

@implementation NetworkManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static NetworkManager * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)loadNoteWithCompletion:(void (^)(NSString *text, NSError *error))completion
{
    NSParameterAssert(completion);
    
    
    
        NSURL *url = [NSURL URLWithString:URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error)
            {
                completion(nil, error);
            }
            else
            {
                NSError* serializationError = nil;
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&serializationError];
                
                if (serializationError) {
                    completion(nil, serializationError);
                }
                else
                {
                    completion([self ParseTextFromResponseDictionary:jsonDictionary], nil);
                }
            }
            
           
        }];
        [task resume];
}

- (NSString*)ParseTextFromResponseDictionary:(NSDictionary*)dict
{
    NSString *text = dict[TEXT_KEY];
    text = [text substringWithRange:NSMakeRange(3, text.length - 8)]; //remove tag
    return text;
}

@end
