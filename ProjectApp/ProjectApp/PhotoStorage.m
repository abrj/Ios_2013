//
//  PhotoStorage.m
//  ProjectApp
//
//  Created by Kewin Remeczki on 09/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "PhotoStorage.h"
#import "FlickrFetcher.h"

@implementation PhotoStorage

- (void)loadPhotoList
{
    self.photoList = [FlickrFetcher getAllPhotos];
}



@end
