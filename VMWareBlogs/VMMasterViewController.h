//
//  VMMasterViewController.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/15/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwesomeMenu.h"

@interface VMMasterViewController : UIViewController <AwesomeMenuDelegate>
@property (strong, nonatomic) IBOutlet UIView *container;

-(BOOL)helloWorld;
@end
