//
//  UIImageView+Network.m
//  spray
//
//  Created by Mustapha Tarek BEN LECHHAB on 12/05/2014.
//  Copyright (c) 2014 Octiplex. All rights reserved.
//

#import "UIImageView+Network.h"

@implementation UIImageView (Network)

- (void)setUrl:(NSURL *)url
{
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:self.bounds];
    progressView.tag = 1001 ;
    [self addSubview:progressView];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:nil];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
                 

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *imageData = [NSData dataWithContentsOfFile:location.path];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[self viewWithTag:1001] removeFromSuperview];
        self.image = [UIImage imageWithData:imageData];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                                                                  didWriteData:(int64_t)bytesWritten
                                                                             totalBytesWritten:(int64_t)totalBytesWritten
                                                                     totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite  ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIProgressView *progressView = (UIProgressView*)[self viewWithTag:1001];
        [progressView setProgress:progress animated:YES];
    });

    NSLog(@"Progress : %f\n",progress);
}
@end
