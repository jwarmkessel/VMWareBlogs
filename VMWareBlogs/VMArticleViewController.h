//
//  VMArticleViewController.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/7/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMArticleViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong)NSString *articleURL;
@property (nonatomic, strong)NSString *articleTitle;
@property (nonatomic, strong)NSString *articleDescription;
@property (nonatomic, strong)UITextView *titleTextView;

- (IBAction)showToolsHandler:(id)sender;
- (IBAction)saveForLaterHandler:(id)sender;
- (IBAction)markAsReadHandler:(id)sender;
- (IBAction)toolBarContainerHandler:(id)sender;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIView *toolBarContainerView;
@property (strong, nonatomic) IBOutlet UIView *toolBarView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolBarButton;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end
