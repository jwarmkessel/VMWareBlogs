//
//  VMArticleViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/7/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleViewController.h"

@interface VMArticleViewController ()
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (assign, nonatomic) BOOL toolBarIsHidden;
@end

@implementation VMArticleViewController

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    NSLog(@"Touches began");
//    UITouch *touch = [[event allTouches] anyObject];
//    if ([touch.view isEqual: self.view] || touch.view == nil) {
//        return;
//    }
//    
//    lastLocation = [touch locationInView: self.view];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    NSLog(@"Touches moved");
//    UITouch *touch = [[event allTouches] anyObject];
//    if ([touch.view isEqual: self.view]) {
//        return;
//    }
//    
//    CGPoint location = [touch locationInView: self.view];
//    
//    CGFloat xDisplacement = location.x - lastLocation.x;
//    CGFloat yDisplacement = location.y - lastLocation.y;
//    
//    CGRect frame = touch.view.frame;
//    frame.origin.x += xDisplacement;
//    frame.origin.y += yDisplacement;
//    touch.view.frame = frame;
}

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
    
//    UIControlEventTouchDragInside
//    
//    UITapGestureRecognizer *singleFingerTap =
//    [[UITapGestureRecognizer alloc] initWithTarget:self
//                                            action:@selector(handleSingleTap:)];
//    [self.view addGestureRecognizer:singleFingerTap];
//    
//
//    [self.descriptionTextView addTarget:self action:@selector(imageMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    
    UIView *imageViewCover = [[UIView alloc] initWithFrame:self.imageView.frame];
    [imageViewCover setBackgroundColor:[UIColor blackColor]];
    imageViewCover.alpha = 0.5;
    [self.imageView addSubview:imageViewCover];
    
    self.titleTextView = [[UITextView alloc] initWithFrame:self.imageView.frame];
    self.titleTextView.text = self.articleTitle;
    [self.titleTextView setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    self.titleTextView.textAlignment = NSTextAlignmentCenter;
    [self.titleTextView setBackgroundColor:[UIColor clearColor]];
    self.titleTextView.textColor = [UIColor whiteColor];
    
    
    [imageViewCover addSubview:self.titleTextView];
    
    
    //THIS WILL ONLY WORK FOR iOS 6 and greater.
    NSString *labelText = self.articleDescription;
    labelText = [NSString stringWithFormat:@"\t%@", labelText];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];

    
    
    
    
    //Set the scrollview size.
    self.descriptionTextView.attributedText = attributedString;
    self.descriptionTextView.textAlignment = NSTextAlignmentLeft;
    [self.descriptionTextView setTextColor:[self colorWithHexString:@"5D5B5B"]];
    [self.descriptionTextView setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
    
    NSLog(@"CHeck the description Text Field Height %f", self.descriptionTextView.frame.size.height);
    
    
    
    float yPoint = 0.0f;
    
    
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
    [UIView
     animateWithDuration:0.2
     animations:^ {

         CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
         rotationAndPerspectiveTransform.m34 = 1.0 / -500;
         rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -45.0 * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
         self.scrollView.layer.transform = rotationAndPerspectiveTransform;
         
         
     }];
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
