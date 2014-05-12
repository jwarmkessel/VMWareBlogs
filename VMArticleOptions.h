//
//  VMArticleOptions.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMArticleOptions : UIView

@property (nonatomic, assign, getter=isHidden) BOOL isHidden;

// define delegate property
@property (nonatomic, assign) id  delegate;

- (id)initWithFrame:(CGRect)frame viewController:(id)vc height:(float)height;
- (void)toggleDropDown;
@end

// define the protocol for the delegate
@protocol VMArticleOptionsDelegate

// define protocol functions that can be used in any class using this delegate
-(void)twitterButtonTapped;
-(void)facebookButtonTapped;

@end