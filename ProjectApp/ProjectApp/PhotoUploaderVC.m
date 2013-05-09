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
@end

@implementation PhotoUploaderVC

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
    NSLog(@"frobe is: %@", frobFromUrl);
    self.frob = frobFromUrl;
    NSLog(@"self.frobe is: %@", self.frob);
    
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://flickr.com/services/auth/?api_key=%@&perms=%@&api_sig=%@", apiKey, permissions, signatureKey]];
    [[UIApplication sharedApplication] openURL:url];
}



@end
