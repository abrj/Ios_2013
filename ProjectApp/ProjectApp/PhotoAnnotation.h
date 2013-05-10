//
//  PhotoAnnotation.h
//  ProjectApp
//
//  Created by Kewin Remeczki on 10/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PhotoAnnotation : NSObject <MKAnnotation>

@property (readwrite, nonatomic) CLLocationCoordinate2D *location;
@property (readwrite, nonatomic) NSString *title;
@property (readwrite, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSData *urlForPhoto;
@property (readwrite, nonatomic) NSUInteger *index;



@end
