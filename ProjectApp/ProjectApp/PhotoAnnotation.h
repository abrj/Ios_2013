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

@property (strong, nonatomic) NSDictionary *photo;
@property (strong, nonatomic) NSDictionary *photoForURL;

@end
