//
//  FlickrAuthentication.h
//  ProjectApp
//
//  Created by Anders Jorgensen on 10/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrAuthentication : NSObject
#define API_KEY @"32742afe2ba425586223d166cf86bb94"
#define SECRECT_KEY @"71eb97fcc2b15929"

+(NSString *)getAcessToken;
+(NSString *)getSignatureKey:(NSString*)string;
@end
