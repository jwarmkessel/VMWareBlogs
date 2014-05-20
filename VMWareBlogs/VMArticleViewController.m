//
//  VMArticleViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/7/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleViewController.h"
#import "VMArticlePreviewView.h"
#import "VMArticleOptions.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface VMArticleViewController (){
    UITextView *sharingTextView;
}
@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) VMArticleOptions *articleOptionsView;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *fbAccount;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

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

//- (void)viewDidLayoutSubviews {
//
//    self.scrollView.contentSize = CGSizeMake(320, 504);
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
//    self.navigationController.navigationBarHidden = NO;

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) { // if iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone; //layout adjustements
    }
    
    //Setup Article Preview and segue animations.
    [self.articlePreviewView setDescriptionWithAttributedText:self.articleDescription];
    [self.articlePreviewView setDelegate:self];
    self.articlePreviewView.titleTextView.text = self.articleTitle;
    
    //Load the blog article into a webview.
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,475.0, 320.0, 568)];
    [self.webView setDelegate:self];
    NSURL *url = [NSURL URLWithString:self.articleURL];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
    [self.view addSubview:self.webView];
    
    CGRect indicatorView = self.webView.frame;
    indicatorView.size.width = 58.0f;
    indicatorView.size.height = 58.0f;
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:indicatorView];
    [self.indicatorView setCenter:self.webView.center];
    [self.webView addSubview:self.indicatorView];
    
    //Setup the optional tools view.
    CGRect rect = CGRectMake(0.0, 0.0, 320.0, 568.0);
    self.articleOptionsView = [[VMArticleOptions alloc] initWithFrame:rect viewController:self height:100.0f];
    [self.articleOptionsView setDelegate:self];
    [self.view addSubview:self.articleOptionsView];
    
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

- (IBAction)showToolsHandler:(id)sender {
    [self.articleOptionsView toggleDropDown];
}

#pragma mark VMArticleOptions delegate methods
-(void)twitterButtonTapped {
    NSLog(@"Twitter button is clicked");
    
    SLComposeViewController *sharingComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled) {
            
            NSLog(@"Cancelled");
            
        } else {
            NSLog(@"Posting to twitter.");
            
            //request update user participation
            NSLog(@"The result %d", result);
        }
        
        [sharingComposer dismissViewControllerAnimated:YES completion:nil];
    };
    [sharingComposer setCompletionHandler:completionHandler];
    //[sharingComposer setInitialText:[NSString stringWithFormat:@"%@ %@",[self editableText],[self permanentText]]];
    
    [sharingComposer addURL:[NSURL URLWithString:self.articleURL]];
    
    [self presentViewController:sharingComposer animated:YES completion:^{
        for (UIView *viewLayer1 in [[sharingComposer view] subviews]) {
            for (UIView *viewLayer2 in [viewLayer1 subviews]) {
                if ([viewLayer2 isKindOfClass:[UIView class]]) {
                    for (UIView *viewLayer3 in [viewLayer2 subviews]) {
                        if ([viewLayer3 isKindOfClass:[UITextView class]]) {
                            [(UITextView *)viewLayer3 setDelegate:self];
                            sharingTextView = (UITextView *)viewLayer3;
                        }
                    }
                }
            }
        }
    }];
}

-(void)facebookButtonTapped {
    // Initialize the account store
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    if (accountStore == nil) {
        accountStore = [[ACAccountStore alloc] init];
    }
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        NSLog(@"I'm totally logged in");
        //App id: 474606345992201
        //Secret key: 6cf03ae9cb0976ec0736557edbe14544
        
        ACAccountType * facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"474606345992201", ACFacebookAppIdKey,
                                 [NSArray arrayWithObject:@"email"], ACFacebookPermissionsKey,
                                 ACFacebookAudienceKey, ACFacebookAudienceEveryone,
                                 nil];
        
        [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSLog(@"Success");
                NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                
                ACAccount *fbAccount = [accounts lastObject];
                
                NSLog(@"===== username %@", fbAccount.userFullName);
            }
        }];
    }else {
        NSLog(@"Access not granted");
    }
    
    
    SLComposeViewController *sharingComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled) {
            
            NSLog(@"Cancelled");
            
        } else {
            NSLog(@"Posting to facebook.");
        }
        
        [sharingComposer dismissViewControllerAnimated:YES completion:nil];
    };
    [sharingComposer setCompletionHandler:completionHandler];
    //[sharingComposer setInitialText:[NSString stringWithFormat:@"%@ %@",[self editableText],[self permanentText]]];
    
    [sharingComposer addURL:[NSURL URLWithString:self.articleURL]];
    
    [self presentViewController:sharingComposer animated:YES completion:^{
        for (UIView *viewLayer1 in [[sharingComposer view] subviews]) {
            for (UIView *viewLayer2 in [viewLayer1 subviews]) {
                if ([viewLayer2 isKindOfClass:[UIView class]]) {
                    for (UIView *viewLayer3 in [viewLayer2 subviews]) {
                        if ([viewLayer3 isKindOfClass:[UITextView class]]) {
                            [(UITextView *)viewLayer3 setDelegate:self];
                            sharingTextView = (UITextView *)viewLayer3;
                        }
                    }
                }
            }
        }
    }];
    
}


#pragma mark VMArticlePreviewView delegate method
-(void)articlePreviewMoved:(float)offset {
    
    float asdf = 475 - fabsf(offset);
    
    if(asdf < 220) {
        [UIView animateWithDuration:0.01 animations:^{
            
            
            self.articlePreviewView.alpha = 0;
        }];
    }
    
    [UIView animateWithDuration:0.01 animations:^{

        
        self.webView.layer.frame = CGRectMake(0.0, asdf, 320.0, 568.0);
    }];
}

-(void)articlePreviewFinishedMoving:(float)offset {
    NSLog(@"articlePreviewFinishedMoving");
    [UIView beginAnimations:nil context:nil];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -2000;
    
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -500;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 20.0f * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);

    
    self.articlePreviewView.testView.layer.transform = rotationAndPerspectiveTransform;
    [UIView commitAnimations];

    [UIView animateWithDuration:0.3 animations:^{
        self.webView.layer.frame = CGRectMake(0.0, 0.0, 320.0, 568.0);
        self.articlePreviewView.testView.alpha = 0;
    }];
    
//    if(offset < -200) {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.articlePreviewView.testView.alpha = 0;
//            
//            self.webView.layer.frame = CGRectMake(0.0, 0.0, 320.0, 568.0);
//        }];
//    } else if(offset > -200) {
//        [UIView animateWithDuration:0.1 animations:^{
//            self.articlePreviewView.testView.alpha = 1;
//            
//            self.webView.layer.frame = CGRectMake(0.0, 475.0, 320.0, 568.0);
//        }];
//    }
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

#pragma mark - UIWebViewDelegate protocol methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad %hhd", webView.loading);
    if(webView.loading < 1) {
        NSLog(@"FINISHED LOADING");
        CGRect rect = CGRectMake(0.0, 0.0, 320.0, 58.0);
        rect.origin.y = self.articlePreviewView.frame.size.height - rect.size.height - (rect.size.height/2);
        UILabel *arrowLabel = [[UILabel alloc] initWithFrame:rect];
        arrowLabel.text = @"^";
        arrowLabel.textAlignment = NSTextAlignmentCenter;
        [arrowLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:40.0f]];
        arrowLabel.alpha = 0;
        [self.articlePreviewView addSubview:arrowLabel];
        
        [UIView animateWithDuration:0.2 animations:^{
            [arrowLabel setAlpha:0.8];
        }];
    }
    
    [_indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
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


- (IBAction)toolBarContainerHandler:(id)sender {
    [self showToolsHandler:sender];
}
@end
