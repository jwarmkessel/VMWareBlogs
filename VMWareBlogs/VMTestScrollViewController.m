//
//  VMTestScrollViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/30/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMTestScrollViewController.h"
#import "VMArticePreviewScrollView.h"

@interface VMTestScrollViewController ()
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation VMTestScrollViewController

@synthesize webView;

float blah;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    self.scrollView.contentSize = CGSizeMake(320, 604);
}

- (void)viewDidLoad
{
    NSLog(@"View did load");
    [super viewDidLoad];

    
    // Do any additional setup after loading the view.
    CGRect firstPartRect = CGRectMake(0.0, 130.0, 320.0f, 250.0);
    UITextView *firstPart = [[UITextView alloc] initWithFrame:firstPartRect];
    [firstPart setBackgroundColor:[UIColor yellowColor]];
    
    firstPart.text = @"aieowj awefiaofjaw awejfoiawjf wafa wefjoiafj f aoiwef awjfoia foiwaj fow aj foaaoiwfj afoiajf aieowj awefiaofjaw awejfoiawjf wafa wefjoiafj f aoiwef awjfoia foiwaj fow aj foaaoiwfj afoiajf aieowj awefiaofjaw awejfoiawjf wafa wefjoiafj f aoiwef awjfoia foiwaj fow aj foaaoiwfj afoiajf aieowj awefiaofjaw awejfoiawjf wafa wefjoiafj f aoiwef awjfoia foiwaj fow aj foaaoiwfj afoiajf aieowj awefiaofjaw awejfoiawjf wafa wefjoiafj f aoiwef awjfoia foiwaj fow aj END";
//    [firstPart setTextColor:[self colorWithHexString:@"5D5B5B"]];
    [firstPart setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
    firstPart.userInteractionEnabled = NO;
    [self.scrollView addSubview:firstPart];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 568.0, 320.0, 568.0)];
    NSURL *url = [NSURL URLWithString:@"http://www.vmwareblogs.com/article.jsp?id=6369767279558656"];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:urlRequest];
    
    [self.view addSubview:webView];
    
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIScrollView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
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
    //NSLog(@"button's frame: %f, %f, %f, %f", buttonFrame.origin.x, buttonFrame.origin.y, buttonFrame.size.width, buttonFrame.size.height);
    
    [self setAnchorPoint:CGPointMake(0.5,0) forView:self.scrollView];
    
    CGFloat scrollLimit = 50;
    if(buttonFrame.origin.y > scrollLimit) {
        [UIView
         animateWithDuration:0.2
         animations:^ {
             
             blah = buttonFrame.origin.y - scrollLimit;
             
             CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
             rotationAndPerspectiveTransform.m34 = 1.0 / -500;
             rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, blah * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
             self.scrollView.layer.transform = rotationAndPerspectiveTransform;
             
             
         }];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //NSLog(@"scrollViewWillBeginDragging");
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDecelerating");
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"scrollViewWillEndDragging %f", blah);
    if(blah < 140) {
        [UIView
         animateWithDuration:0.2
         animations:^ {
             
             CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
             rotationAndPerspectiveTransform.m34 = 1.0 / -500;
             rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0 * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
             self.scrollView.layer.transform = rotationAndPerspectiveTransform;
             
             NSLog(@"Scroll view default %f", self.scrollView.transform.ty);
            
         }];
    } else if(blah > 50.0) {
        
            NSLog(@"Showing webview");
            [self.scrollView setAlpha:0];
            webView.layer.frame = CGRectMake(0.0, 0.0, 320, 568);
            
        
        
    }
}

@end
