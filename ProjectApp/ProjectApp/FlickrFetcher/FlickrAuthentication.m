//
//  FlickrAuthentication.m
//  ProjectApp
//
//  Created by Anders Jorgensen on 10/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "FlickrAuthentication.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"


@interface FlickrAuthentication()

@end

@implementation FlickrAuthentication

static NSString *token = nil;
static NSString *frob = nil;

+(void)getAcessToken
{
    
    //Check the token at Flickr
    [self setToken:[[NSUserDefaults standardUserDefaults]
                            stringForKey:@"accessToken"]];
    if([self getToken]){
        if([self checkToken]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tokenFetchedAndSet" object:nil];
        }
        else{
            [self openBrowserForFlickrPermission];
        }
    }
    
    else{
        [self openBrowserForFlickrPermission];
    }
    
}


+(BOOL)checkToken
{
    NSString *api_sig = [self md5Hash:[NSString stringWithFormat:@"%@api_key%@auth_token%@formatjsonmethodflickr.auth.checkToken", SECRECT_KEY, API_KEY, [self getToken]]];
     NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.auth.checkToken&api_key=%@&format=json&auth_token=%@&api_sig=%@", API_KEY, [self getToken], api_sig]];
    NSError *error;
    NSData* data = [NSData dataWithContentsOfURL:requestURL options:NSDataReadingUncached error:&error];
    
    NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"checking token. response is : %@", strResponse);
    NSRange rangeValue = [strResponse rangeOfString:@"invalid" options:NSCaseInsensitiveSearch];
    if (rangeValue.length > 0){
        return false;
    } else{
        return true;
    }

}
+(void)setToken:(NSString*)newValue
{
    token = newValue;
}

+(void)setFrob:(NSString*)newValue
{
    frob = newValue;
}

+(NSString *)getToken
{
    return token;
}

+(NSString *)getSignatureKey:(NSString*)string
{
    return [self md5Hash:string];
}
//Opens the browser, so the user can validate that the app is allowed to access his account with write permissions
+(void)openBrowserForFlickrPermission
{
    //Adds self as observer to "urlFrobSet" and call parseFrob, when the notification is raised
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAndParseFrob:) name:@"urlFrobSet" object:nil];
    NSString *permissions = @"write";
    NSString *signatureKey = @"5c824b45c2e679f4ff1ea3afadd77e3e";   //Should be calling md5Hast method
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://flickr.com/services/auth/?api_key=%@&perms=%@&api_sig=%@", API_KEY, permissions, signatureKey]];
    //Opens the browser
    [[UIApplication sharedApplication] openURL:url];
}

//Gets called, when AppDelegates notifies that the frob is set and parses and set the self.frob
+(void)setAndParseFrob:(NSNotification*)notifcation
{
    //Gets the frob from the AppDelegate class
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *URL = appDelegate.urlFrob;
    //Splits the URL into an array
    NSArray *components = [URL componentsSeparatedByString:@"="];
    NSString *frobFromUrl = [components objectAtIndex:1];
    //Sets self.frob
    [self setFrob:frobFromUrl];
    [self getAccessTokenFromFrob:frob];
    
}

//Call the method at flickr flickr.auth.getToken
+(void)getAccessTokenFromFrob:(NSString*)frob
{
    NSString *api_sig = [self md5Hash:[NSString stringWithFormat:@"%@api_key%@formatjsonfrob%@methodflickr.auth.getToken", SECRECT_KEY, API_KEY, frob]];
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://flickr.com/services/rest/?method=flickr.auth.getToken&format=json&api_key=%@&frob=%@&api_sig=%@", API_KEY, frob, api_sig]];
    
    NSError *error;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSData* data = [NSData dataWithContentsOfURL:requestURL options:NSDataReadingUncached error:&error];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.token = [self ResponseUrlToToken:strResponse];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tokenFetchedAndSet" object:nil];
    [[NSUserDefaults standardUserDefaults]
     setObject:[self getToken] forKey:@"accessToken"];
}

//Parses the result from flickr.auth.getToken into a token string
+(NSString *)ResponseUrlToToken:(NSString*)responseString
{
    NSArray *components = [responseString componentsSeparatedByString:@","];
    NSArray *authCompoents = [[components objectAtIndex:0] componentsSeparatedByString:@"\""];
    NSMutableString *tokenString = [[authCompoents objectAtIndex:7] mutableCopy];
    [tokenString replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:(NSRange){0,[tokenString length]}];
    
    NSLog(@"the tokenString is %@", tokenString);
    return tokenString;
}

//Method for encrypting a string to MD5 string
+ (NSString*)md5Hash:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
@end
