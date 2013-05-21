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

// Shared properties
@property (strong, nonatomic) NSArray *photos;
@property (nonatomic, strong) IBOutlet ImageViewController *imageViewController;

// Properties for the Map
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *mapAnnotations;
@property (strong, nonatomic) CLLocationManager *locationManager;

// Properties for the tableview:
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation MapViewController

#define START_ZOOM_LEVEL 6

-(void)viewWillAppear:(BOOL)animated
{
    // Black Translucent top bar.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.title = @"Photos overview";
    [super viewWillAppear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startStandardUpdates];
    self.photos = [FlickrFetcher getAllPhotos];
    [self mapSetup];
    [self setAnnotationsForPhotos];
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    //Adds the refreshControl
    [self addRefreshControlToTableView];
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
    // Initializing the array for the annotations
    self. mapAnnotations = [[NSMutableArray alloc] init];
    // Create an annotation for each photo. 
    for (NSDictionary *dic in self.photos)
    {
        PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init];
        annotation.photo = [FlickrFetcher getPhotoInfo:dic[FLICKR_PHOTO_ID]];
        annotation.photoForURL = dic;
        [self.mapAnnotations addObject:annotation];
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.mapAnnotations];
}

// Method for starting the user-location updates on the location manager.
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

// When clicking on an annotations's button, this event will trigger.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // Getting the annotation. Normally you would save it as an id and check if the annotation isKindOfClass, but since we are only handling one annotion-type (PhotoAnnotation) we're creating this object.
    PhotoAnnotation <MKAnnotation> *annotation = [view annotation];
    
    // Calling the segue to show the image.
    [self performSegueWithIdentifier:@"showImage" sender:annotation];
}


// MKMapViewDelegate method for creating an annotation view.
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
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = rightButton;
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
    }
    
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

// Method for setting the title for the row in the table.
- (NSString *)titleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_TITLE] description]; // description because could be NSNull
}

// Method for setting the subtitle for the row in the table.
- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_OWNER] description]; // description because could be NSNull
}

// Method for setting the thumbnail for the row in the table.
-(UIImage *)imageForRow:(NSUInteger)row
{
    NSURL *imageURL = [FlickrFetcher urlForPhoto:self.photos[row] format:FlickrPhotoFormatSquare];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
    return [[UIImage alloc] initWithData:imageData];
}

// loads up a table view cell with the title and owner of the photo at the given row in the Model

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Creating a cell identifier.
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configuring the cell...
    // Colors and text of the cells
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.text = [self titleForRow:indexPath.row];
    
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    // Cell image
    cell.imageView.image = [self imageForRow:indexPath.row];
    
    return cell;
}

// When a table is selected, this method is called.
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the annotation associated with the cell clicked on.
    PhotoAnnotation *annotation = self.mapAnnotations[indexPath.row];
    
    // Zooming out for a nice animation:
    MKCoordinateRegion zoomedOutRegion = self.mapView.region;
    zoomedOutRegion.span.latitudeDelta *= 5;
    zoomedOutRegion.span.longitudeDelta *= 5;
    [self.mapView setRegion:zoomedOutRegion animated:YES];
    
    // Move the map to the region showing where the photo is located.
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500);
    
    [self.mapView setRegion:region animated:YES];
}

// When the disclosure button on a tablecell is clicked on, this method is called.
-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // Get the annotation associated with the cell clicked on.
    PhotoAnnotation *annotation = self.mapAnnotations[indexPath.row];
    // Perform the segue to show the photo.
    [self performSegueWithIdentifier:@"showImage" sender:annotation];
}

-(void)addRefreshControlToTableView
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
    
    //ADD THE REFRESHCONTROL TO THE PROPERTY HERE
    
}

-(void)refresh:(UIRefreshControl *)sender
{
    [self loadLatestPhotosFromFlickr];
}

- (void)loadLatestPhotosFromFlickr
{
    // start the animation if it's not already going
    if(self.refreshControl){
    [self.refreshControl beginRefreshing];
    }
    //start the network indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // fork off the Flickr fetch into another thread
    dispatch_queue_t loaderQ = dispatch_queue_create("flickr latest loader", NULL);
    dispatch_async(loaderQ, ^{
        // call Flickr
        NSArray *latestPhotos = [FlickrFetcher getAllPhotos];
        // when we have the results, use main queue to display them
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = latestPhotos; // makes UIKit calls, so must be main thread
            [self.refreshControl endRefreshing];  // stop the animation
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;     //hide the network indicator
            
            
        });
    });
}

// The prepareForSegue method. Called whenever an image is to be shown.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[PhotoAnnotation class]]) {
        PhotoAnnotation *annotation = sender;
        if ([segue.identifier isEqualToString:@"showImage"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(setPhotoInfo:)]) {
                NSDictionary *image = annotation.photoForURL;
                [segue.destinationViewController performSelector:@selector(setPhotoInfo:) withObject:image];
                [segue.destinationViewController setTitle:annotation.title];
            }
        }
    }
}

@end
