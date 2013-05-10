//
//  NewPhotoViewController.m
//  ProjectApp
//
//  Created by Anders Jorgensen on 08/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "NewPhotoViewController.h"

@interface NewPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *pickPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *photoNewButton;
@property (weak, nonatomic) IBOutlet UIButton *existingPhotoButton;

@end

@implementation NewPhotoViewController


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

-(void)viewDidLoad
{
    [self pickPhotoButton].hidden = YES;
}
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
    [self pickPhotoButton].hidden = NO;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Checks if the sender is the right one
    if([sender isKindOfClass:[UIButton class]]){
        if ([segue.identifier isEqualToString:@"PickedImage"]){
            if ([segue.destinationViewController respondsToSelector:@selector(setPickedImage:)]){
                [segue.destinationViewController performSelector:@selector(setPickedImage:) withObject:image];
                
            }
        }
    }
}
@end
