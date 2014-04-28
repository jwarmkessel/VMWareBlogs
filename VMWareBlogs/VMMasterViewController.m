//
//  VMMasterViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/15/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMMasterViewController.h"
#import "VMArticleTableViewController.h"
#import "VMTestViewController.h"

#import <AwesomeMenu.h>
#import <AwesomeMenuItem.h>

#import "VMTestViewController.h"

@interface VMMasterViewController ()
@property (nonatomic, strong) VMArticleTableViewController *atVC;
@property (nonatomic, strong) VMTestViewController *tVC;
@end

@implementation VMMasterViewController
@synthesize container;

-(BOOL)helloWorld {
    NSLog(@"Parent says Hello world");
    
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Instantiate child view controller.
    self.tVC = (VMTestViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"testView"];
    [self addChildViewController:self.tVC];
    self.tVC.view.frame = CGRectMake(160.0, 284.0, 0.0, 0.0);
    self.tVC.view.alpha = 0;
    [self.view addSubview:self.tVC.view];
    [self.tVC didMoveToParentViewController:self];
    
    //Instantiate child view controller.
    self.atVC = (VMArticleTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"articleTableView"];
    [self addChildViewController:self.atVC];
    self.atVC.tableView.frame = CGRectMake(0.0, 0.0, 320.0, 568.0);
    [self.view addSubview:self.atVC.tableView];
    [self.atVC didMoveToParentViewController:self];
    
    //Add the menu
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    
    // the start item, similar to "add" button of Path
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton.png"]
                                                       highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"]
                                                           ContentImage:[UIImage imageNamed:@"icon-plus.png"]
                                                highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
    
    CGRect rect = CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height);
    NSArray *menus = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, nil];
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:rect menus:menus];
    
    menu.delegate = self;
    
    menu.startPoint = CGPointMake(40.0, 284.0);
    [self.view addSubview:menu];
    [self.view bringSubviewToFront:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)transitionViews {
    [self.view bringSubviewToFront:self.tVC.view];
    [self.tVC openAnimateView];
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
