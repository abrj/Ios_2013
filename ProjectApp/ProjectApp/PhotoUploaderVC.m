//
//  PhotoUploaderVC.m
//  ProjectApp
//
//  Created by Anders Jorgensen on 09/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//



#import "PhotoUploaderVC.h"
#import "FlickrFetcher.h"
#import "FlickrAuthentication.h"
#import <QuartzCore/QuartzCore.h>



@interface PhotoUploaderVC ()

@property (strong, nonatomic) NSString *frob;
@property (strong, nonatomic) NSString *token;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


@end

@implementation PhotoUploaderVC


#define FLICKR_UPLOAD_URL @"http://api.flickr.com/services/upload"
-(void) setPickedImage:(UIImage *)pickedImage
{
    _pickedImage = pickedImage;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.descriptionText.layer.borderWidth = 1;
    [self.descriptionText.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.descriptionText.layer setBorderColor: [[UIColor brownColor] CGColor]];
    [self.descriptionText.layer setBorderWidth: 1.0];
    [self.descriptionText.layer setCornerRadius:8.0f];
    [self.descriptionText.layer setMasksToBounds:YES];
}

- (IBAction)prepareForUpload:(id)sender
{
    //Add observer to 'tokenFetchedAndSet' and calls uploadImage, when the notifcation is raised
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadImage) name:@"tokenFetchedAndSet" object:nil];
    [self.spinner startAnimating];
    [FlickrAuthentication getAcessToken];
}


//Makes the keyboard hide, if the user touched outside of the keyboard or textfield
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.titleText isFirstResponder] && [touch view] != self.titleText) {
        [self.titleText resignFirstResponder];
    }
    if ([self.descriptionText isFirstResponder] && [touch view] != self.descriptionText) {
        [self.descriptionText resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}


-(void)uploadImage
{
    
    NSString *desc = self.descriptionText.text;
    NSString *tag = @"iosProject2013";
    self.token = [FlickrAuthentication getToken];
    NSString *uploadSig = [FlickrAuthentication getSignatureKey:[NSString stringWithFormat:@"%@api_key%@auth_token%@description%@tags%@", SECRECT_KEY, API_KEY, self.token, desc, tag]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:FLICKR_UPLOAD_URL]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------7d44e178b0434";
    
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"api_key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", API_KEY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"auth_token\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", self.token] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"api_sig\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", uploadSig] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Description
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",desc] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Tag
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"tags\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",tag] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Image
    UIImage *image = self.pickedImage;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n", self.titleText.text] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:imageData];
    
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    // create the connection with the request
    // and start loading the data
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [theConnection start];
  
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"String sent from server %@",[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
    [self.spinner stopAnimating];
     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload complete!"
                                                    message:@"Your picture has been uploaded to your account at Flickr"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
