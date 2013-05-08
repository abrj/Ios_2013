//
//  NewPhotoViewController.m
//  ProjectApp
//
//  Created by Anders Jorgensen on 08/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "NewPhotoViewController.h"

@interface NewPhotoViewController ()

@end

@implementation NewPhotoViewController

-(IBAction)TakePhoto{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
    
}

-(IBAction)ChooseExistingPhoto
{
    secondPicker = [[UIImagePickerController alloc] init];
    secondPicker.delegate = self;
    [secondPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:secondPicker animated:YES completion:NULL];
    
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [imageView setImage:image];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
