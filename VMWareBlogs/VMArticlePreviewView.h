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

// define delegate property
@property (nonatomic, assign) id  delegate;

- (void)setDescriptionWithAttributedText:(NSString *)text;
@end

// define the protocol for the delegate
@protocol CustomClassDelegate

// define protocol functions that can be used in any class using this delegate
-(void)articlePreviewMoved:(float)offset;
-(void)articlePreviewFinishedMoving:(float)offset;

@end