//
//  MapViewController.m
//  ProjectApp
//
//  Created by Kewin Remeczki on 09/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "FlickrFetcher.h"

@interface MapViewController ()

@property (strong, nonatomic) NSArray *photos;

@end

@implementation MapViewController

#define START_LOCATION_LATITUDE
#define START_LOCATION_LONGITUDE

// Google Map View
GMSMapView *mapView_;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.photos = [FlickrFetcher getAllPhotos];
}


- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self setPhotoMarkers];
}


- (void)loadView {
    
    
    // Create a GMSCameraPosition that tells the map to display the
    // latest posted photo at its location at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    self.view = mapView_;
    
    // Set the markers for the photos, on the map.
    [self setPhotoMarkers];
}

// Method for putting markers for each photo, on the map.
- (void)setPhotoMarkers
{
    for (NSDictionary *dic in self.photos)
    {
        double latitude = [dic[FLICKR_LATITUDE] doubleValue];
        double longitude = [dic[FLICKR_LONGITUDE] doubleValue];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(latitude, longitude);
        marker.title = [dic[FLICKR_PHOTO_TITLE] description];
        marker.snippet = [dic[FLICKR_PHOTO_TITLE] description];
        
        // Setting the icon of the marker to be the image:
        NSData *imgData = [[NSData alloc] initWithContentsOfURL:[FlickrFetcher urlForPhoto:dic format:FlickrPhotoFormatThumbnail]];
        UIImage *icon = [[UIImage alloc] initWithData:imgData];
        marker.icon = icon;
        marker.map = mapView_;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
