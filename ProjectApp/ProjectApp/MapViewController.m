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
    [self.mapView setMapType:MKMapTypeHybrid];
    
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
    
    for (NSDictionary *dic in self.photos)
    {
        PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init];
        annotation.photo = [FlickrFetcher getPhotoInfo:dic[FLICKR_PHOTO_ID]];
        [self.mapView addAnnotation:annotation];
    }
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

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    if ([annotation isKindOfClass:[PhotoAnnotation class]]) // for Golden Gate Bridge
    {
        // try to dequeue an existing pin view first
        static NSString *identifier = @"photoAnnotation";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (pinView == nil)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:identifier];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: when the detail disclosure button is tapped, we respond to it via:
            //       calloutAccessoryControlTapped delegate method
            //
            // by using "calloutAccessoryControlTapped", it's a convenient way to find out which annotation was tapped
            //
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

@end
