//
//  HelpViewController.h
//  GRouting
//
//  Created by Joseph Lin on 10/1/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HelpViewControllerDelegate;


@interface HelpViewController : UIViewController

@property (nonatomic, weak) id <HelpViewControllerDelegate> delegate;

@end


@protocol HelpViewControllerDelegate <NSObject>
- (void)dismissHelpController:(HelpViewController *)controller;
@end
