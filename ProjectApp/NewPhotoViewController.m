//
//  NewPhotoViewController.m
//  ProjectApp
//
//  Created by Anders Jorgensen on 08/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "NewPhotoViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface NewPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *pickPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *photoNewButton;
@property (weak, nonatomic) IBOutlet UIButton *existingPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;

@end

@implementation NewPhotoViewController


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //Set the graphics for buttons
    self.pickPhotoButton.layer.cornerRadius = 8.0f;
    self.photoNewButton.layer.cornerRadius = 8.0f;
    self.existingPhotoButton.layer.cornerRadius = 8.0f;
}


-(void)viewDidLoad
{
    //Hides the two buttons
    [self pickPhotoButton].hidden = YES;
    [self returnButton].hidden = YES;
    
    //Adds an observer to self and waits for notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidePhotoFromViewOnNotifaction:)
                                                 name:@"PhotoUploaded"
                                               object:nil];
}

-(void)hidePhotoFromViewOnNotifaction:(NSNotification *)notification
{
    imageView.image = nil;
    [self existingPhotoButton].hidden = NO;
    [self photoNewButton].hidden = NO;
    [self pickPhotoButton].hidden = YES;
    [self returnButton].hidden = YES;
    
}
//Disable rotation to landscape mode
- (BOOL)shouldAutorotate
{
    // Return YES for supported orientations
    return NO;
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
    [self returnButton].hidden = NO;
    [self existingPhotoButton].hidden = YES;
    [self photoNewButton].hidden = YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)return:(id)sender
{
    imageView.image = nil;
    [self existingPhotoButton].hidden = NO;
    [self photoNewButton].hidden = NO;
    [self pickPhotoButton].hidden = YES;
    [self returnButton].hidden = YES;
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
