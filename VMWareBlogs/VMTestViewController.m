//
//  VMTestViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/17/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMTestViewController.h"
#import "VMMasterViewController.h"

@interface VMTestViewController ()

@end

@implementation VMTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openAnimateView {
    // scale the button down before the animation...
    NSLog(@"Open Animate View");
    
    
    self.view.transform = CGAffineTransformMakeScale(0, 0);

    self.view.transform = CGAffineTransformIdentity;
        
    CAKeyframeAnimation * keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    
    NSNumber *one = [[NSNumber alloc] initWithFloat:200];
    NSNumber *two = [[NSNumber alloc] initWithFloat:215];
    NSNumber *three = [[NSNumber alloc] initWithFloat:185];
    NSNumber *four = [[NSNumber alloc] initWithFloat:205];
    NSNumber *five = [[NSNumber alloc] initWithFloat:200];

    keyframeAnimation.values = [NSArray arrayWithObjects: one, two, three, four, five, nil];
    
    [keyframeAnimation setKeyTimes:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:0.9], [NSNumber numberWithFloat:1.0], nil]];
    [keyframeAnimation setDuration:0.3];
    
    self.view.layer.frame = CGRectMake(0.0, 100.0, 320, 200);

    [UIView animateWithDuration:1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                        self.view.alpha = 1;
                         keyframeAnimation.values = [NSArray arrayWithObjects: one, two, three, four, five, nil];
                         
                         [keyframeAnimation setKeyTimes:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:0.9], [NSNumber numberWithFloat:1.0], nil]];
                         [keyframeAnimation setDuration:0.3];
                         [self.view.layer addAnimation:keyframeAnimation forKey:@"somekey"];
                         
                         self.view.layer.frame = CGRectMake(0.0, 100.0, 320, 200);
                         

                     }
                     completion:nil];
    // now animate the view...
//    [UIView animateWithDuration:1.0
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//
//
//                     }
//                     completion:^(BOOL finished){
//                         
//                         
//                         /******/
//                         
////                         CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
////                         [animation setFromValue:[NSNumber numberWithFloat:startyPosition]];
////                         [animation setToValue:[NSNumber numberWithFloat:endyPosition]];
////                         [animation setDuration:.3];
////                         [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.5 :1.8 :1 :1]];
////                         [someView.layer addAnimation:animation forKey:@"somekey"];
//                     }];
    

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
