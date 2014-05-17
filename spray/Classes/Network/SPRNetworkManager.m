//
//  SPRNetworkManager.m
//  spray
//
//  Created by Mustapha Tarek BEN LECHHAB on 12/05/2014.
//  Copyright (c) 2014 Octiplex. All rights reserved.
//

#import "SPRNetworkManager.h"

static NSString* const kADNBaseURL = @"https://api.app.net" ;
static NSURLComponents *_baseURL ;

@interface SPRNetworkManager ()

@property (nonatomic, strong) NSURLComponents *endpoint ;
@property (nonatomic, strong) NSURLSession *mainSession ;

@end

@implementation SPRNetworkManager

- (id)initWithDelegate:(id<NSURLSessionDelegate>)delegate
{
    self = [super init];
    
    if (self)
    {
        _endpoint = [NSURLComponents componentsWithString:kADNBaseURL];
        NSURLSessionConfiguration *defaultConf = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultConf.HTTPAdditionalHeaders = @{
                                              @"Authorization" :
                                              @"Bearer __USER_TOKEN__"
                                              };
        
#warning Replace __USER_TOKEN__ above with your user token from App.net
        
        _mainSession = [NSURLSession sessionWithConfiguration:defaultConf delegate:delegate delegateQueue:nil];
    }
    return self ;
}


+(void)profileRequestForUsername:(NSString*)username completionHandler:(void(^)(NSDictionary *result, NSError *error))completion
{
    if (!username)
    {
        completion(nil,[NSError errorWithDomain:@"com.octiplex.spray" code:-1 userInfo:@{@"description":@"Username can't be null"}]);
        return ;
    }
    
    
    NSString *requestPath = [NSString stringWithFormat:@"%@/users/@%@",kADNBaseURL,username];
    
    NSURL *profileEndpoint = [NSURL URLWithString:requestPath];
    
    NSURLSessionConfiguration *ephemeralConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *privateSession = [NSURLSession sessionWithConfiguration:ephemeralConfiguration];
    
    NSURLSessionDataTask *fetchProfileTask =
    [privateSession dataTaskWithURL:profileEndpoint
                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                   {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response ;
                                       
                                       if (httpResponse.statusCode == 200)
                                       {
                                           NSError *jsonError = nil ;
                                           NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                                        options:0
                                                                                                          error:&jsonError];
                                           if (jsonError)
                                           {
                                               completion(nil,jsonError);
                                               return ;
                                           }
                                           
                                           completion(jsonResponse,nil);
                                       }
                                       else
                                       {
                                           completion(nil,[NSError errorWithDomain:@"com.octiplex.spray" code:-1 userInfo:nil]);
                                       }
                                       
                                   }];
    [fetchProfileTask resume];
}

- (void)uploadFile:(NSData*)imageData completionHandler:(void (^)(NSDictionary *result, NSError *))completion
{
    self.endpoint.path = @"/files";
    

    
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:self.endpoint.URL];
    uploadRequest.HTTPMethod = @"POST";
    
    NSString *formType = @"type=com.octiplex.spray;name=great_photo.jpg";
    uploadRequest.HTTPBody = [formType dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [self.mainSession dataTaskWithRequest:uploadRequest
                                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response ;
                                                             
                                                             if (httpResponse.statusCode == 200)
                                                             {
                                                                 NSError *jsonError = nil ;
                                                                 NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                                 
                                                                 if (jsonError)
                                                                 {
                                                                     completion(nil,jsonError);
                                                                     return ;
                                                                 }
                                                                 
                                                                 NSString *fileID = jsonResponse[@"data"][@"id"];
                                                                 [self uploadData:imageData fileID:fileID completionHandler:completion];
                                                             }
                                                             else
                                                             {
                                                                 completion(nil,[NSError errorWithDomain:@"com.octiplex.spray" code:httpResponse.statusCode userInfo:nil]);
                                                             }

                                                         }];
    
    [dataTask resume];
    
}

- (void)uploadData:(NSData *)imageData fileID:(NSString*)fileID completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    self.endpoint.path = [NSString stringWithFormat:@"/files/%@/content",fileID];
    
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:self.endpoint.URL];
    uploadRequest.HTTPMethod = @"PUT";
    [uploadRequest setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionUploadTask *dataTask = [self.mainSession uploadTaskWithRequest:uploadRequest
                                                                    fromData:imageData
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response ;
                                                               if (httpResponse.statusCode == 204)
                                                               {
                                                                   [self getFileURLForID:fileID completionHandler:completion];
                                                               }
                                                               else
                                                               {
                                                                   completion(nil,[NSError errorWithDomain:@"com.octiplex.spray" code:httpResponse.statusCode userInfo:nil]);
                                                               }
                                                           }];
    
    [dataTask resume];
    
}

-(void)getFileURLForID:(NSString*)fileID completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    self.endpoint.path = [NSString stringWithFormat:@"/files/%@",fileID];
    
    [[self.mainSession dataTaskWithURL:self.endpoint.URL
           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
               
               if (httpResponse.statusCode == 200)
               {
                   NSError *jsonError = nil ;
                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                   
                   if (jsonError)
                   {
                       completion(nil,jsonError);
                       return ;
                   }
                   NSURL *fileURL = [NSURL URLWithString:jsonResponse[@"data"][@"url"]];
                   
                   completion(@{@"url":fileURL},nil);
               }
               else
               {
                   completion(nil,[NSError errorWithDomain:@"com.octiplex.spray" code:httpResponse.statusCode userInfo:nil]);
               }
           }] resume];
}

@end
