//
//  PhotoAnnotation.m
//  ProjectApp
//
//  Created by Kewin Remeczki on 10/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "FlickrFetcher.h"
#import "PhotoAnnotation.h"

@interface PhotoAnnotation ()

@property (readwrite, nonatomic) NSString *title;
@property (readwrite, nonatomic) NSString *subtitle;

@end


@implementation PhotoAnnotation

-(void)setPhoto:(NSDictionary *)photo
{
    _photo = photo;
}

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = [[[self.photo valueForKeyPath:FLICKR_PHOTO_LOCATION] valueForKeyPath:FLICKR_LATITUDE] doubleValue];
    annotationCoord.longitude = [[[self.photo valueForKeyPath:FLICKR_PHOTO_LOCATION] valueForKeyPath:FLICKR_LONGITUDE] doubleValue];
    
    return annotationCoord;
}

-(NSString *)title
{
    return [[[self.photo valueForKeyPath:FLICKR_PHOTO_TITLE] valueForKeyPath:@"_content"] description];
}

-(NSString *)subtitle
{
    return [[self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
}

@end
