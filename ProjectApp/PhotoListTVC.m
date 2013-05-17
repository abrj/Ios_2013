//
//  PhotoListTVC.m
//  ProjectApp
//
//  Created by Anders Jorgensen on 08/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "PhotoListTVC.h"
#import "FlickrFetcher.h"


@implementation PhotoListTVC
- (IBAction)refreshControl:(id)sender {
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [super viewWillAppear:animated];
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadLatestPhotosFromFlickr];
    //Hooks up the refreshcontrol for the selector method
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)refresh:(UIRefreshControl *)sender
{
    [self loadLatestPhotosFromFlickr];
}

- (void)loadLatestPhotosFromFlickr
{
    // start the animation if it's not already going
    [self.refreshControl beginRefreshing];
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

// loads up a table view cell with the title and owner of the photo at the given row in the Model

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}

// Preparing the image to be shown when clicking on a table cell. 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotoInfo:)]) {
                    NSDictionary *image = self.photos[indexPath.row];
                    [segue.destinationViewController performSelector:@selector(setPhotoInfo:) withObject:image];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}


@end
