//
//  NewPhotoViewController.h
//  ProjectApp
//
//  Created by Anders Jorgensen on 08/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewPhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *picker;
    UIImagePickerController *secondPicker;
    UIImage *image;
    
    IBOutlet UIImageView *imageView;   
}

-(IBAction)TakePhoto;

-(IBAction)ChooseExistingPhoto;

@end
