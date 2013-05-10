//
//  PhotoAnnotation.m
//  ProjectApp
//
//  Created by Kewin Remeczki on 10/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "PhotoAnnotation.h"

@implementation PhotoAnnotation 

- (void) setLocation:(CLLocationCoordinate2D *)location
{
    _location = location;
}

-(void) setTitle:(NSString *)title
{
    _title = title;
}

-(void) setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
}

-(void) setUrlForPhoto:(NSData *)urlForPhoto
{
    _urlForPhoto = urlForPhoto;
}

@end
