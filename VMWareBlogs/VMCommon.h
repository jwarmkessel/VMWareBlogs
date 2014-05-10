//
//  VMCommon.h
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMCommon : NSObject

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;
-(UIColor*)colorWithHexString:(NSString*)hex;

@end
