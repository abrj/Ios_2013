//
//  PhotoUploaderVC.m
//  ProjectApp
//
//  Created by Anders Jorgensen on 09/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//



#import "PhotoUploaderVC.h"
#import "FlickrFetcher.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"





@interface PhotoUploaderVC ()

@property (strong, nonatomic) NSString *frob;
@property (strong, nonatomic) NSString *token;
@end

@implementation PhotoUploaderVC


//71eb97fcc2b15929api_key32742afe2ba425586223d166cf86bb94frob72157633458824100-a1a18c5c0f785718-95576137methodflickr.auth.getToken
#define API_KEY @"32742afe2ba425586223d166cf86bb94"
#define SECRECT_KEY @"71eb97fcc2b15929"
-(void) setPickedImage:(NSData *)pickedImage
{
    _pickedImage = pickedImage;
}

-(void)setFrob:(NSString *)frob
{
    _frob = frob;
}


-(void)parseFrob:(NSNotification*)notifcation
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *URL = appDelegate.urlFrob;
    NSArray *components = [URL componentsSeparatedByString:@"="];
    NSString *frobFromUrl = [components objectAtIndex:1];
    self.frob = frobFromUrl;
    NSLog(@"self.frobe is: %@", self.frob);
    [self getTokenFromFrob:self.frob];
    
}

-(void) getTokenFromFrob:(NSString*)frob
{
    NSString *api_sig = [self md5Hash:[NSString stringWithFormat:@"%@api_key%@formatjsonfrob%@methodflickr.auth.getToken", SECRECT_KEY, API_KEY, frob]];
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://flickr.com/services/rest/?method=flickr.auth.getToken&format=json&api_key=%@&frob=%@&api_sig=%@", API_KEY, frob, api_sig]];
    NSLog(@"the request url is %@", requestURL);
    
    NSError *error;
    NSData* data = [NSData dataWithContentsOfURL:requestURL options:NSDataReadingUncached error:&error];

    NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strResponse);
    self.token = [self ResponseUrlToToken:strResponse];
    [self testUploadImage];
}

-(NSString *)ResponseUrlToToken:(NSString*)responseString
{
    NSArray *components = [responseString componentsSeparatedByString:@","];
    NSArray *authCompoents = [[components objectAtIndex:0] componentsSeparatedByString:@"\""];
    NSMutableString *tokenString = [[authCompoents objectAtIndex:7] mutableCopy];
   [tokenString replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:(NSRange){0,[tokenString length]}];

    NSLog(@"the tokenString is %@", tokenString);
    return tokenString;


}

- (NSString*)md5Hash:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
-(void)viewDidLoad
{
    [super viewDidLoad];
    //Adds self as observer to "urlFrobSet" and call parseFrob, when the notification is raised
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseFrob:) name:@"urlFrobSet" object:nil];
    [self uploadPhoto];
}

-(void)uploadPhoto
{
    
    NSString *apiKey = @"32742afe2ba425586223d166cf86bb94";
    NSString *permissions = @"write";
    NSString *signatureKey = @"5c824b45c2e679f4ff1ea3afadd77e3e";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://flickr.com/services/auth/?api_key=%@&perms=%@&api_sig=%@", API_KEY, permissions, signatureKey]];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)testUploadImage
{
    
    NSString *uploadSig = [self md5Hash:[NSString stringWithFormat:@"%@api_key%@auth_token%@", SECRECT_KEY, API_KEY, self.token]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [NSString stringWithFormat:@"http://api.flickr.com/services/upload/"];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [NSString stringWithString:@"---------------------------7d44e178b0434"];
    
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
    [body appendData:[@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    UIImage *image =[ UIImage imageNamed:@"smileyImage.jpeg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
}



@end
