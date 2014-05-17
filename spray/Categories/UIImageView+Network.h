//
//  UIImageView+Network.h
//  spray
//
//  Created by Mustapha Tarek BEN LECHHAB on 12/05/2014.
//  Copyright (c) 2014 Octiplex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Network) <NSURLSessionDownloadDelegate>

- (void)setUrl:(NSURL *)url ;

@end
