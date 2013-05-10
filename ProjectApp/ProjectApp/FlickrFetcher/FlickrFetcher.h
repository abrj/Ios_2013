//
//  FlickrFetcher.h
//
//  Created for Stanford CS193p Winter 2013.
//  Copyright 2013 Stanford University
//  All rights reserved.
//

#import <Foundation/Foundation.h>

// tags in the photo dictionaries returned from stanfordPhotos or latestGeoreferencedPhotos

#define FLICKR_PHOTO_TITLE @"title"
#define FLICKR_PHOTO_DESCRIPTION @"description._content"  // must use valueForKeyPath: on this one
#define FLICKR_PLACE_NAME @"_content"
#define FLICKR_PHOTO_ID @"id"
#define FLICKR_LATITUDE @"latitude"
#define FLICKR_LONGITUDE @"longitude"
#define FLICKR_PHOTO_OWNER @"ownername"
#define FLICKR_TAGS @"tags"

// The following can only be used on a getPhotoInfo dictionary.
#define FLICKR_PHOTO_LOCATION @"location" // 10 Values: must use valueForKeyPath with FLICKR_PLACE_NAME on each of the following.
#define FLICKR_PHOTO_LOCATION_LOCALITY @"locality"
#define FLICKR_PHOTO_LOCATION_REGION @"region"
#define FLICKR_PHOTO_LOCATION_COUNTRY @"country" 

#define FLICKR_PHOTO_OWNERINFO @"owner" // 7 Values: must use valueForKeyPath on each.
#define FLICKR_PHOTO_OWNERINFO_REALNAME @"realname"

#define FLICKR_PHOTO_DATE @"dates" // 5 Values: must use valueForKeyPath.
#define FLICKR_PHOTO_DATE_TAKEN @"taken"




#define NSLOG_FLICKR NO

typedef enum {
	FlickrPhotoFormatSquare = 1,    // 75x75
	FlickrPhotoFormatLarge = 2,     // 1024x768
	FlickrPhotoFormatOriginal = 64,   // at least 1024x768
    FlickrPhotoFormatThumbnail = 3,
    FlickrPhotoFormatSmall = 4,
    FlickrPhotoFormatMedium500 = 5,
    FlickrPhotoFormatMedium640 = 6
} FlickrPhotoFormat;

@interface FlickrFetcher : NSObject

// fetch a bunch of Flickr photo dictionaries using the Flickr API
+ (NSArray *)getAllPhotos;
// Fetch information about a specific photo.
+ (NSDictionary *)getPhotoInfo:(NSString *)photoId;
// get the URL for a Flickr photo given a dictionary of Flickr photo info
//  (which can be gotten using stanfordPhotos or latestGeoreferencedPhotos)
+ (NSURL *)urlForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format;

@end
