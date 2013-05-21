//
//  ImageViewController.m
//  ProjectApp
//
//  Created by Kewin Remeczki on 08/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "ImageViewController.h"
#import "FlickrFetcher.h"
#import "PhotoDescriptionVC.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) NSDictionary *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ImageViewController

#define MAX_ZOOM_SCALE 2.0

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
    
    // Making sure the back button shows "Back" instead of the title of the parent VC.
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
}


-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];;
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void) setPhotoInfo:(NSDictionary *)image
{
    self.image = image;
    [self setImageURL:[FlickrFetcher urlForPhoto:image format:FlickrPhotoFormatLarge]];
}


// fetches the data from the URL
// turns it into an image
// adjusts the scroll view's content size to fit the image
// sets the image as the image view's image
// Using threads
- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        [self.spinner startAnimating];      // if self.spinner is nil, does nothing
        NSURL *imageURL = self.imageURL;    // grab the URL before we start (then check it below)
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            //Start the network indicator
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // bad
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];  // could take a while
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // bad
            // UIImage is one of the few UIKit objects which is thread-safe, so we can do this here
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            // check to make sure we are even still interested in this image (might have touched away)
            if (self.imageURL == imageURL) {
                // dispatch back to main queue to do UIKit work
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                       // self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        self.imageView.contentMode = UIViewContentModeCenter;
                        [self setZoomScale];
                    }
                    [self.spinner stopAnimating];  // spinner should have hidesWhenStopped set
                });
            }
        });
    }
}

-(void)setZoomScale {
    //We need to find the lesser minimum that still shows the whole picture
    float heightZoomMin = self.scrollView.bounds.size.height / self.imageView.image.size.height;
    float widthZoomMin  = self.scrollView.bounds.size.width  / self.imageView.image.size.width;
    //Zoom to the lesser level to see the whole picture
    self.scrollView.zoomScale = MIN(widthZoomMin, heightZoomMin);
    //Also set the minimum to the lesser level, so there is only background visible on the botom or side but never both
    self.scrollView.minimumZoomScale = self.scrollView.zoomScale;
    
    
    //Just in case we get an image with less pixels than our view area, set the minZoom to 1.0
    if (self.scrollView.minimumZoomScale > MAX_ZOOM_SCALE ) {
        self.scrollView.minimumZoomScale = 1;
    }
}

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

// Method for returning the view which will be zoomed when the user pinches.

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}


// Action for pushing the description view when swiping.
- (IBAction)showDescription:(UISwipeGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"Photo Description" sender:self.image];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[NSDictionary class]]) {
        NSDictionary *image = sender;
        if ([segue.identifier isEqualToString:@"Photo Description"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(setPhotoInfo:)]) {
                [segue.destinationViewController performSelector:@selector(importPhotoInfo:) withObject:[FlickrFetcher getPhotoInfo:image[FLICKR_PHOTO_ID]]];
                [segue.destinationViewController setTitle:self.title];
            }
        }
    }
}

@end
