//
//  VMJunkArticleViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/16/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMJunkArticleViewController.h"

@interface VMJunkArticleViewController ()

@end

@implementation VMJunkArticleViewController

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
    
    self.title = @"Preview";
    self.navigationController.navigationBarHidden = NO;
    
    CGRect selfRect = self.view.frame;
    NSLog(@"x: %f y: %f", self.view.frame.origin.x, self.view.frame.origin.y);
    
    selfRect.origin.y = 500.0;
    self.view.frame = selfRect;
    self.view.backgroundColor = [UIColor yellowColor];
    
    CGRect rect = self.view.frame;
    rect.origin.x = 0;
    rect.origin.y = 64;
    rect.size.width = 320.0;
    rect.size.height = 504.0;
    UIView *label = [[UIView alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor greenColor];
    [self.view addSubview:label];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    lab.text = @"Hello world";
    [label addSubview:lab];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
