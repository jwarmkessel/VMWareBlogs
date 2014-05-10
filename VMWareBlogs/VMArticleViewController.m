//
//  VMArticleViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/7/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleViewController.h"
#import "VMOverlayView.h"
#import "VMArticlePreviewView.h"

@interface VMArticleViewController ()
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (assign, nonatomic) BOOL toolBarIsHidden;
@property (strong, nonatomic) VMOverlayView *overlay;
@end

@implementation VMArticleViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLayoutSubviews {

    self.scrollView.contentSize = CGSizeMake(320, 504);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.webView setDelegate:self];
    [self.scrollView setDelegate:self];
    
    self.descriptionTextView.userInteractionEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    
    //Overlay challenge for BSafe
//    self.overlay = [[VMOverlayView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
//    
//    [self.view addSubview:self.overlay];
//    [self.overlay addTransparentView];
    
//    UIControlEventTouchDragInside
//    
//    UITapGestureRecognizer *singleFingerTap =
//    [[UITapGestureRecognizer alloc] initWithTarget:self
//                                            action:@selector(handleSingleTap:)];
//    [self.view addGestureRecognizer:singleFingerTap];
//    
//
//    [self.descriptionTextView addTarget:self action:@selector(imageMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    self.articlePreviewView.titleTextView.text = self.articleTitle;

    [self.articlePreviewView setDescriptionWithAttributedText:self.articleDescription];
    [self.articlePreviewView setDelegate:self];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,568.0, 320.0, 568)];
    NSURL *url = [NSURL URLWithString:@"http://www.vmwareblogs.com/article.jsp?id=5787401926475776"];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
    [self.view addSubview:self.webView];
    
    
//    yPoint = yPoint + self.descriptionTextView.contentSize.height; // Bingo, we have the new yPoiny now to start the next component.
    
    self.scrollView.backgroundColor = [UIColor whiteColor];


//    NSString *fullURL = self.articleURL;
//    NSURL *url = [NSURL URLWithString:fullURL];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:requestObj];
    
    // Do any additional setup after loading the view.

    
    //Override the back button.
//    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"< back"
//                                                       style:UIBarButtonItemStyleBordered
//                                                      target:self
//                                                      action:@selector(handleBack:)];
//    
//    [self.backButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                             [UIFont fontWithName:@"ArialMT" size:13], NSFontAttributeName,
//                                             [UIColor blueColor], NSForegroundColorAttributeName,
//                                             nil]
//                                   forState:UIControlStateNormal];
//    
//    self.navigationItem.leftBarButtonItem = self.backButton;

//    NSLog(@"HELLOW ORLD");
//    UIView *asdf = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,300)];
//    [asdf setBackgroundColor:[UIColor greenColor]];
//    [self.view addSubview:asdf];
//    self.view.alpha = 1;
//    [self.view setBackgroundColor:[UIColor purpleColor]];
//    [self.parentViewController.view sendSubviewToBack:self.view];
//    [self.view setBackgroundColor:[UIColor greenColor]];
//    
//    [self removeFromParentViewController];
//    [self.view removeFromSuperview];
//    [self view].hidden = YES;
}

#pragma mark VMArticlePreviewView delegate method
-(void)articlePreviewMoved:(float)offset {
    NSLog(@"SOMETHING HAPPENED");
    [UIView animateWithDuration:0.3 animations:^{
        self.articlePreviewView.testView.alpha = 0;
        
        self.webView.layer.frame = CGRectMake(0.0, 0.0, 320.0, 568.0);
    }];
}

- (void)handleBack:(id)sender {
    NSLog(@"check");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Set the navigation Bar
    UINavigationBar *navBar = [[self navigationController] navigationBar];
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    //Tool bar pre-configurations
    [self.toolBarContainerView setBackgroundColor:[UIColor clearColor]];
    [self.toolBarView setBackgroundColor:[self colorWithHexString:@"181515"]];
    [self.toolBarContainerView setAlpha:0.0];
    [self.toolBarContainerView setUserInteractionEnabled:NO];
    _toolBarIsHidden = YES;
    
    _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicator setCenter:CGPointMake(self.webView.center.x, self.webView.center.y)];
    [self.webView addSubview:_indicator];
    [_indicator startAnimating];
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

#pragma mark - UIScrollViewDelegate protocol methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    CGPoint offset = scrollView.contentOffset;

    CGRect buttonFrame = CGRectMake(0,0,320, 568);
    buttonFrame.origin.x += offset.x;
    buttonFrame.origin.y += offset.y;
    NSLog(@"button's frame: %f, %f, %f, %f", buttonFrame.origin.x, buttonFrame.origin.y, buttonFrame.size.width, buttonFrame.size.height);
    
    self.scrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging");
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDecelerating");
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"scrollViewWillEndDragging");
}

#pragma mark - UIWebViewDelegate protocol methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
    [_indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (IBAction)showToolsHandler:(id)sender {
    
    if(_toolBarIsHidden) {
        [self.toolBarContainerView setAlpha:1.0];

        [UIView animateWithDuration:0.2 animations:^{
            CGRect rect = CGRectMake(0.0f, 0.0f, 320.0f, self.toolBarContainerView.frame.size.height);
            self.toolBarContainerView.frame = rect;
            
        } completion:^(BOOL finished) {
            _toolBarIsHidden = NO;
            [self.toolBarContainerView setUserInteractionEnabled:YES];
        }];
    } else {
        
        [UIView animateWithDuration:0.2 animations:^{
            CGRect rect = CGRectMake(0.0f, (-1 * self.toolBarView.frame.size.height), 320.0f, self.toolBarContainerView.frame.size.height);
            self.toolBarContainerView.frame = rect;
            
        } completion:^(BOOL finished) {
            _toolBarIsHidden = YES;
            [self.toolBarContainerView setAlpha:0.0];
            [self.toolBarContainerView setUserInteractionEnabled:NO];
        }];
    }
}

-(UIColor*)colorWithHexString:(NSString*)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
- (IBAction)saveForLaterHandler:(id)sender {
    NSLog(@"Save For Later is being clicked");
}

- (IBAction)markAsReadHandler:(id)sender {
    NSLog(@"Mark As Read is being clicked");
}

- (IBAction)toolBarContainerHandler:(id)sender {
    [self showToolsHandler:sender];
}
@end
