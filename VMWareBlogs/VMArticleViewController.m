//
//  VMArticleViewController.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/7/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleViewController.h"
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
    
//    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"346633"];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) { // if iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone; //layout adjustements
    }
    
    NSLog(@"Set the articlePreviewView GUID %@", self.articleURL);
    
    CGRect mainScreenRect = [[UIScreen mainScreen] bounds];
    
    self.webView = [[UIWebView alloc] initWithFrame:mainScreenRect];
    [self.webView setDelegate:self];
    NSURL *url = [NSURL URLWithString:self.articleURL];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
    [self.view addSubview:self.webView];

    self.webView.scalesPageToFit = YES;
    
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor grayColor] CGColor];
    upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.webView.frame), 1.0f);
    [self.webView.layer addSublayer:upperBorder];
    
    CGRect indicatorView = self.webView.frame;
    indicatorView.size.width = 58.0f;
    indicatorView.size.height = 58.0f;
    indicatorView.origin.x = 160.0f;
    indicatorView.origin.y = 300.0f;
    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicatorView setCenter:self.webView.center];
    
    [self.indicatorView startAnimating];
    [self.view addSubview:self.indicatorView];
    
    //Setup the optional tools view.
    self.articleOptionsView = [[VMArticleOptions alloc] initWithFrame:mainScreenRect viewController:self height:100.0f];
        
    [self.articleOptionsView setDelegate:self];
    [self.view addSubview:self.articleOptionsView];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    NSLog(@"view will disappear");
    [self destroyWebView];
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
    [_webView delete:nil];
    [_webView reload];
}

// Destroy UIWebView
- (void)destroyWebView {
    NSLog(@"view will destroyWebView");
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading];
    [self.webView setDelegate:nil];
    [self.webView removeFromSuperview];
    [self setWebView:nil];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
}

#pragma mark - UIWebViewDelegate protocol methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad %d", webView.loading);
    [self.indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (IBAction)showToolsHandler:(id)sender {
    [self.articleOptionsView toggleDropDown];
}

- (IBAction)toolBarContainerHandler:(id)sender {
    [self showToolsHandler:sender];
}
@end
