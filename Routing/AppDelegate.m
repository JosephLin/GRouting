//
//  AppDelegate.m
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import "ViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([MKDirectionsRequest isDirectionsRequestURL:url])
    {
        MKDirectionsRequest* directionsInfo = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
    
        if ( [self.window.rootViewController isMemberOfClass:[ViewController class]] )
        {
            [(ViewController*)self.window.rootViewController processRequest:directionsInfo];
        }
        return YES;
    }

    return NO;
}
	


@end
