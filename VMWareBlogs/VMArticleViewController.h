//
//  VMArticleViewController.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/7/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMArticleViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong)NSString *articleURL;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)showToolsHandler:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *toolBarContainerView;
@property (strong, nonatomic) IBOutlet UIView *toolBarView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolBarButton;
- (IBAction)saveForLaterHandler:(id)sender;
- (IBAction)markAsReadHandler:(id)sender;
- (IBAction)toolBarContainerHandler:(id)sender;


@end
