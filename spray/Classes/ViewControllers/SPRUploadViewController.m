//
//  SPRUploadViewController.m
//  spray
//
//  Created by Mustapha Tarek BEN LECHHAB on 14/05/2014.
//  Copyright (c) 2014 Octiplex. All rights reserved.
//

#import "SPRUploadViewController.h"
#import "SPRNetworkManager.h"

@interface SPRUploadViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (strong, nonatomic) NSURL *imageURL ;
@property (strong, nonatomic) SPRNetworkManager *networkManager ;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *uploadProgressLabel;

- (IBAction)pickImageTapped:(id)sender;
- (IBAction)uploadButtonTapped:(id)sender;

@end

@implementation SPRUploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _networkManager = [[SPRNetworkManager alloc] initWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (IBAction)pickImageTapped:(id)sender
{
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary ;
    picker.delegate = self ;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)uploadButtonTapped:(id)sender
{
    NSData *image = UIImageJPEGRepresentation(self.mainImageView.image, 1);
    [self.networkManager uploadFile:image
                  completionHandler:^(NSDictionary *result, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error)
                        {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                message:error.localizedDescription
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                            [alertView show];
                        }
                        else
                        {
                            [[UIApplication sharedApplication] openURL:result[@"url"]];
                        }
                    });
                }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pictureTook = info[UIImagePickerControllerOriginalImage];
    NSURL *imageURL = info[UIImagePickerControllerReferenceURL];
    
    self.mainImageView.image = pictureTook ;
    self.imageURL = imageURL ;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateProgressWithValue:(CGFloat)progress
{
    if (progress != 1)
    {
        self.uploadProgressLabel.hidden = NO ;
        self.uploadProgressView.hidden = NO ;
        
        [self.uploadProgressView setProgress:progress animated:YES];
        NSUInteger percentageProgress = progress * 100 ;
        self.uploadProgressLabel.text = [NSString stringWithFormat:@"%lu%%",(unsigned long)percentageProgress];
        
    }
    else
    {
        self.uploadProgressLabel.hidden = YES ;
        self.uploadProgressView.hidden = YES ;
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    CGFloat progress = ((CGFloat)totalBytesSent/(CGFloat)totalBytesExpectedToSend);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateProgressWithValue:progress];
    });
    
    NSLog(@"Progress : %f \n",progress);
}
@end
