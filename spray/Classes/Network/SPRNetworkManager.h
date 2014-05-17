//
//  SPRNetworkManager.h
//  spray
//
//  Created by Mustapha Tarek BEN LECHHAB on 12/05/2014.
//  Copyright (c) 2014 Octiplex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPRNetworkManager : NSObject

- (id)initWithDelegate:(id<NSURLSessionDelegate>)delegate ;

+ (void)profileRequestForUsername:(NSString*)username completionHandler:(void(^)(NSDictionary *result, NSError *error))completion ;
- (void)uploadFile:(NSData*)imageData completionHandler:(void (^)(NSDictionary *result, NSError *))completion;

@end
