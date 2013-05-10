//
//  PhotoDescriptionVC.m
//  ProjectApp
//
//  Created by Kewin Remeczki on 09/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "PhotoDescriptionVC.h"
#import "FlickrFetcher.h"
#import <UIKit/UIKit.h>


@interface PhotoDescriptionVC ()

@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSDictionary *photoInfo;

@end

@implementation PhotoDescriptionVC

#define LABEL_HEIGHT 20.0
#define SPACE_BETWEEN_LABELS 50.0;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setLabels];
}

- (void) importPhotoInfo:(NSDictionary *)photo
{
    self.owner = [[[photo valueForKeyPath:FLICKR_PHOTO_OWNERINFO] valueForKeyPath:FLICKR_PHOTO_OWNERINFO_REALNAME] description];
    self.location = [NSString stringWithFormat:@"%@, %@, %@",
                     [[[[photo valueForKeyPath:FLICKR_PHOTO_LOCATION] valueForKeyPath:FLICKR_PHOTO_LOCATION_LOCALITY] valueForKeyPath:FLICKR_PLACE_NAME] description],
                     [[[[photo valueForKeyPath:FLICKR_PHOTO_LOCATION] valueForKeyPath:FLICKR_PHOTO_LOCATION_REGION] valueForKeyPath:FLICKR_PLACE_NAME] description],
                     [[[[photo valueForKeyPath:FLICKR_PHOTO_LOCATION] valueForKeyPath:FLICKR_PHOTO_LOCATION_COUNTRY] valueForKeyPath:FLICKR_PLACE_NAME] description]];
    self.date = [[[photo valueForKeyPath:FLICKR_PHOTO_DATE] valueForKeyPath:FLICKR_PHOTO_DATE_TAKEN] description];
    self.description = [[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
}

- (void) setHeaderLabels
{
    UILabel *ownerHeader = [[UILabel alloc] init];
    UILabel *dateHeader = [[UILabel alloc] init];
    UILabel *locationHeader = [[UILabel alloc] init];
    UILabel *descriptionHeader = [[UILabel alloc] init];
    
    ownerHeader.text = @" Owner";
    dateHeader.text = @" Date Posted";
    locationHeader.text = @" Location";
    descriptionHeader.text = @" Description";
    
    NSMutableArray *lblArray = [[NSMutableArray alloc] init];
    [lblArray addObject:ownerHeader];
    [lblArray addObject:dateHeader];
    [lblArray addObject:locationHeader];
    [lblArray addObject:descriptionHeader];
    
    float y = 0.0;
    
    for (UILabel *lbl in lblArray) {
        [self.view addSubview:lbl];
        lbl.frame = CGRectMake(0, y, self.view.bounds.size.width, LABEL_HEIGHT);
        lbl.backgroundColor = [UIColor grayColor];
        lbl.font = [UIFont fontWithName:@"Avenir Next Condensed" size:15.0];
        
        y += SPACE_BETWEEN_LABELS;
    }
}

-(void) setLabels
{
    [self setHeaderLabels];
    
    UITextView *descLbl = [[UITextView alloc] init];
    
    UILabel *ownerLbl = [[UILabel alloc] init];
    UILabel *dateLbl = [[UILabel alloc] init];
    UILabel *locLbl = [[UILabel alloc] init];
    
    ownerLbl.text = self.owner;
    dateLbl.text = self.date;
    locLbl.text = self.location;
    descLbl.text = self.description;
    
    NSMutableArray *lblArray = [[NSMutableArray alloc] init];
    [lblArray addObject:ownerLbl];
    [lblArray addObject:dateLbl];
    [lblArray addObject:locLbl];
    
    float y = 25.0;
    
    for (UILabel *lbl in lblArray) {
        [self.view addSubview:lbl];
        lbl.backgroundColor = [UIColor blackColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont fontWithName:@"Avenir Next Condensed" size:13.0];
        lbl.frame = CGRectMake(0, y, self.view.bounds.size.width, LABEL_HEIGHT);
        
        y += SPACE_BETWEEN_LABELS;
        
    }
    
    // Setting up the description text view. 
    descLbl.backgroundColor = [UIColor blackColor];
    descLbl.textColor = [UIColor whiteColor];
    descLbl.editable = NO;
    descLbl.font = [UIFont fontWithName:@"Avenir Next Condensed" size:13.0];

    [self.view addSubview:descLbl];
    // Setting the size.
    descLbl.frame = CGRectMake(0, y, self.view.bounds.size.width,
                                   self.view.bounds.size.height-y-95);
    
}


@end
