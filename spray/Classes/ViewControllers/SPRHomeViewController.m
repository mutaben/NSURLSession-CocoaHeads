//
//  SPRHomeViewController.m
//  spray
//
//  Created by Mustapha Tarek BEN LECHHAB on 12/05/2014.
//  Copyright (c) 2014 Octiplex. All rights reserved.
//

#import "SPRHomeViewController.h"
#import "SPRNetworkManager.h"
#import "UIImageView+Network.h"

@interface SPRHomeViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)searchButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;

@end

@implementation SPRHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.usernameField.delegate = self ;
}


- (IBAction)searchButtonTapped:(id)sender
{
    self.searchButton.enabled = NO ;
    [self.usernameField resignFirstResponder];
    [SPRNetworkManager profileRequestForUsername:self.usernameField.text
                               completionHandler:^(NSDictionary *result, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       
                                       self.searchButton.enabled = YES ;
                                       
                                       if (error)
                                       {
                                           UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"An error occurred"
                                                                                                message:error.localizedDescription
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:@"OK"
                                                                                      otherButtonTitles: nil];
                                           [errorAlert show];
                                       }
                                       else
                                       {
                                           self.bioLabel.text = result[@"data"][@"description"][@"text"] ;
                                           [self.profileImageView setUrl:[NSURL URLWithString:result[@"data"][@"avatar_image"][@"url"]]];
                                       }
                                   });
                               }];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES ;
}

@end
