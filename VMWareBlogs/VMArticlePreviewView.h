//
//  VMArticlePreviewView.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/4/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMArticlePreviewView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) UIWebView *webView;


- (void)setDescriptionWithAttributedText:(NSString *)text;
@end
