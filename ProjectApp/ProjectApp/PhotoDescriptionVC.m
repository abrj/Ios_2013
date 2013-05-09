//
//  PhotoDescriptionVC.m
//  ProjectApp
//
//  Created by Kewin Remeczki on 09/05/13.
//  Copyright (c) 2013 Abrj & Kdan. All rights reserved.
//

#import "PhotoDescriptionVC.h"

@interface PhotoDescriptionVC ()

@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation PhotoDescriptionVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setLabels];
}

-(UIScrollView *) scrollView
{
    if (!_scrollView) _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    return _scrollView;
}


-(void) setLabels
{
    
    
    
    self.scrollView.frame = CGRectMake(5, 5, self.view.bounds.size.width-10, self.view.bounds.size.height/2);
    [self.view addSubview:self.scrollView];
    
    UITextView *descLbl = [[UITextView alloc] init];
    UITextView *locLbl = [[UITextView alloc] init];
    
    locLbl.text = self.location;
    descLbl.text = self.description;
    
    [self.scrollView addSubview:descLbl];
    [self.view addSubview:locLbl];
    
    
    locLbl.textColor = [UIColor whiteColor];
    descLbl.textColor = [UIColor whiteColor];
    locLbl.backgroundColor = [UIColor greenColor];
    descLbl.backgroundColor = [UIColor grayColor];
    
    descLbl.frame = CGRectMake(0, 0, self.view.bounds.size.width-10, self.view.bounds.size.height);
    self.scrollView.contentSize = descLbl.frame.size;
    
    locLbl.frame = CGRectMake(5, descLbl.bounds.size.height+10, self.view.bounds.size.width-10, self.view.bounds.size.height/2);
}


@end
