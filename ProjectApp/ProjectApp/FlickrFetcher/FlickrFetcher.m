//
//  FlickrFetcher.m
//
//  Created for Stanford CS193p Winter 2013.
//  Copyright 2013 Stanford University
//  All rights reserved.
//

#import "FlickrFetcher.h"
#import "FlickrAPIKey.h"
#import "FlickrAuthentication.h"

#define FLICKR_PLACE_ID @"place_id"

@implementation FlickrFetcher

+ (NSDictionary *)executeFlickrFetch:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@&format=json&nojsoncallback=1&api_key=%@", query, FlickrAPIKey];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (NSLOG_FLICKR) NSLog(@"[%@ %@] sent %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), query);
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    if (NSLOG_FLICKR) NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
    return results;
}

+ (NSArray *)getAllPhotos
{
    NSString *request = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=iosProject2013&format=rest", API_KEY];
    
    return [[self executeFlickrFetch:request] valueForKeyPath:@"photos.photo"];
}



// Method for retrieving all information of a photo.
+ (NSDictionary *)getPhotoInfo:(NSString *)photoId
{
    NSString *request = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&photo_id=%@", photoId];
    
    return [[self executeFlickrFetch:request] valueForKeyPath:@"photo"];
}

+ (NSString *)urlStringForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format
{
	id farm = [photo objectForKey:@"farm"];
	id server = [photo objectForKey:@"server"];
	id photo_id = [photo objectForKey:@"id"];
	id secret = [photo objectForKey:@"secret"];
	if (format == FlickrPhotoFormatOriginal) secret = [photo objectForKey:@"originalsecret"];
    
	NSString *fileType = @"jpg";
	if (format == FlickrPhotoFormatOriginal) fileType = [photo objectForKey:@"originalformat"];
	
	if (!farm || !server || !photo_id || !secret) return nil;
	
	NSString *formatString = @"s";
	switch (format) {
		case FlickrPhotoFormatSquare:    formatString = @"s"; break;
		case FlickrPhotoFormatLarge:     formatString = @"b"; break;
        case FlickrPhotoFormatThumbnail: formatString = @"t"; break;
        case FlickrPhotoFormatSmall:     formatString = @"m"; break;
        case FlickrPhotoFormatMedium500: formatString = @"-"; break;
        case FlickrPhotoFormatMedium640: formatString = @"z"; break;
		case FlickrPhotoFormatOriginal:  formatString = @"o"; break;
	}
    
	return [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_%@.%@", farm, server, photo_id, secret, formatString, fileType];
}

+ (NSURL *)urlForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format
{
    return [NSURL URLWithString:[self urlStringForPhoto:photo format:format]];
}

@end
