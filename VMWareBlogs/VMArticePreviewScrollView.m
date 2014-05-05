//
//  VMArticePreviewScrollView.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/1/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticePreviewScrollView.h"

@implementation VMArticePreviewScrollView

float oldX, oldY; BOOL dragging;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"Touches Began");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
//    if ([[touch.view class] isSubclassOfClass:[UILabel class]]) {
        dragging = YES;
        oldX = touchLocation.x;
        oldY = touchLocation.y;
//    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"Touches Ended %f %f", oldX, oldY);
    dragging = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
//    if ([[touch.view class] isSubclassOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)touch.view;
        if (dragging) {
            CGRect frame = label.frame;
            frame.origin.x = label.frame.origin.x + touchLocation.x - oldX;
            frame.origin.y = label.frame.origin.y + touchLocation.y - oldY;
            label.frame = frame;
        }
//    }
}

@end
