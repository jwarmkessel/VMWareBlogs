//
//  VMArticleViewController.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 4/7/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMArticleOptions.h"

@interface VMArticleViewController : UIViewController <UIWebViewDelegate, VMArticleOptionsDelegate, UITextViewDelegate>

@property (nonatomic, strong)NSString *articleURL;

- (IBAction)showToolsHandler:(id)sender;
- (IBAction)toolBarContainerHandler:(id)sender;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolBarButton;

@end
