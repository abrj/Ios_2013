//
//  PhotoFetcher.h
//  ProjectApp
//
//  Created by Anders Jorgensen on 08/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrFetcher.h"

@interface PhotoFetcher : NSObject

-(NSArray *)getNewPhotos;

@end
