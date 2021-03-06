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
#import <ImageIO/ImageIO.h>
#import "AssetsLibrary/AssetsLibrary.h"




@interface PhotoUploaderVC () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSString *frob;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UITextField *locationText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic) Boolean isUploading;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;


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
    self.isUploading = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self getLocationFrom:self.pickedImage];

    //Sets up the textView borders
    self.descriptionText.layer.borderWidth = 1;
    [self.descriptionText.layer setBackgroundColor: [[UIColor grayColor] CGColor]];
    [self.descriptionText.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [self.descriptionText.layer setBorderWidth: 1.0];
    [self.descriptionText.layer setCornerRadius:8.0f];
    [self.descriptionText.layer setMasksToBounds:YES];
    
    //Set the background color for textfield
    self.titleText.backgroundColor = [UIColor grayColor];

    //Set the background color for locationTextfield
    self.locationText.backgroundColor = [UIColor grayColor];
    
    //set delegates for textfields
    self.titleText.delegate = self;
    self.descriptionText.delegate = self;
    
    //Set the corners for the uploadButton
    self.uploadButton.layer.cornerRadius = 8.0f;
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.spinner stopAnimating];
}


- (IBAction)prepareForUpload:(id)sender
{
    //Add observer to 'tokenFetchedAndSet' and calls uploadImage, when the notifcation is raised
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadImage) name:@"tokenFetchedAndSet" object:nil];
    [FlickrAuthentication getAcessToken];
}


//Makes the keyboard hide, if the user touched outside of the keyboard or textfield
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    //Title text field
    if ([self.titleText isFirstResponder] && [touch view] != self.titleText) {
        [self.titleText resignFirstResponder];
    }
    
    //Description text field
    if ([self.descriptionText isFirstResponder] && [touch view] != self.descriptionText) {
        [self.descriptionText resignFirstResponder];
    }
    
    //Location text field
    if ([self.locationText isFirstResponder] && [touch view] != self.locationText) {
        [self.locationText resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

//Hides the keyboard on return key
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleText || textField == self.locationText) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void) getLocationFrom:(UIImage *)image
{
    NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
    CGImageSourceRef imageData= CGImageSourceCreateWithData((__bridge CFDataRef)jpegData, NULL);    //The __bridge is used to cast the NSdata into CFDataRef
    NSDictionary* props = (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(imageData, 0, NULL);
    NSLog(@"the location is %@", props);
    
}

    
    

-(void)uploadImage
{
    //Checking if a upload already is in progress
    if(self.isUploading == NO){
        //there needs to be a title on the photo, so this ensures that the user types a title
        if(![self.titleText.text length] == 0){
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
            [self.spinner startAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            self.isUploading = YES;
            NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [theConnection start];
        }
        
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No title!"
                                                            message:@"You must specify a title on your photo!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    //Displayed if a upload already is in progress
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload in progress!"
                                                        message:@"One of your pictures is still uploading to Flickr. Please try again later"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
  
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"String sent from server %@",[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
    
    //Implement error codes here....
    
    
    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
    [self.spinner stopAnimating];
     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.isUploading = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload complete!"
                                                    message:@"Your picture has been uploaded to your account at Flickr"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    //Sends a notification that the photo have been uploaded
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoUploaded" object:self];
    [alert show];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

@end
