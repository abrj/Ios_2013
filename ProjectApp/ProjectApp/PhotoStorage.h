//
//  PhotoStorage.h
//  ProjectApp
//
//  Created by Kewin Remeczki on 09/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoStorage : NSObject

@property (strong, nonatomic) NSArray *photoList;

+ (void) loadPhotoList;

@end
