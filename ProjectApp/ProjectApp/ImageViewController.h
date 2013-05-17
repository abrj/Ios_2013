//
//  ImageViewController.h
//  ProjectApp
//
//  Created by Kewin Remeczki on 08/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSURL *imageURL;
- (void) setPhotoInfo:(NSDictionary *)image;
@end
