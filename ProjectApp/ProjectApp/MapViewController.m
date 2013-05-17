//
//  MapViewController.m
//  ProjectApp
//
//  Created by Kewin Remeczki on 09/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "MapViewController.h"
#import "FlickrFetcher.h"
#import "PhotoAnnotation.h"
#import "ImageViewController.h"


typedef enum AnnotationIndex : NSUInteger
{
    photoAnnotationIndex = 0,
} AnnotationIndex;

@interface MapViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray *photos;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *mapAnnotations;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet ImageViewController *imageViewController;

@end

@implementation MapViewController

#define START_ZOOM_LEVEL 6



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startStandardUpdates];
    self.photos = [FlickrFetcher getAllPhotos];
    [self mapSetup];
    [self setAnnotationsForPhotos];
}



- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
}


- (void)mapSetup {
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeSatellite];
    
    CLLocationDistance visibleDistance = 100000; // 100 kilometers
   
    // Sets the maps starting center point to Copenhagen.
    CLLocationCoordinate2D userLoc = CLLocationCoordinate2DMake(55.677, 12.561);
    
    if (self.locationManager.location) {
    userLoc = self.locationManager.location.coordinate;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(userLoc.latitude, userLoc.longitude), visibleDistance, visibleDistance);
    [self.mapView setRegion:region];
}

-(void) setAnnotationsForPhotos
{
    self. mapAnnotations = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in self.photos)
    {
        PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init];
        annotation.photo = [FlickrFetcher getPhotoInfo:dic[FLICKR_PHOTO_ID]];
        [self.mapAnnotations addObject:annotation];
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.mapAnnotations];
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 50;
    
    [self.locationManager startUpdatingLocation];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[PhotoAnnotation class]])
    {
        NSLog(@"Clicked on a PhotoAnnotation");
    }
    
    [self.navigationController pushViewController:self.imageViewController animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[PhotoAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:
                                     UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(myShowDetailsMethod:)
                  forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = rightButton;
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
    }
    
    return nil;
}
@end
