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
#import "AFJSONRequestOperation.h"




@interface PhotoUploaderVC ()

@property (strong, nonatomic) NSString *frob;
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

-(void)testmethod
{
    NSString *api_sig = [self md5Hash:[NSString stringWithFormat:@"%@api_key%@formatjsonfrob%@methodflickr.auth.getToken", SECRECT_KEY, API_KEY, self.frob]];
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://flickr.com/services/rest/?method=flickr.auth.getToken&format=json&api_key=%@&frob=%@&api_sig=%@", API_KEY, self.frob, api_sig]];
    NSLog(@"the request url is %@", requestURL);
    
    NSError *error;
    NSData* data = [NSData dataWithContentsOfURL:requestURL options:NSDataReadingUncached error:&error];
    NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strResponse);
}

#define fetchQ dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
-(void) getTokenFromFrob:(NSString*)frob
{
    NSString *api_sig = [self md5Hash:[NSString stringWithFormat:@"%@api_key%@formatjsonfrob%@methodflickr.auth.getToken", SECRECT_KEY, API_KEY, frob]];
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://flickr.com/services/rest/?method=flickr.auth.getToken&format=json&api_key=%@&frob=%@&api_sig=%@", API_KEY, frob, api_sig]];
    NSLog(@"the request url is %@", requestURL);
    
    NSError *error;
    NSData* data = [NSData dataWithContentsOfURL:requestURL options:NSDataReadingUncached error:&error];
    NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strResponse);
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



@end
