//
//  HelpViewController.m
//  GRouting
//
//  Created by Joseph Lin on 10/1/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)handleTap:(id)sender
{
    [self.delegate dismissHelpController:self];
}

@end
