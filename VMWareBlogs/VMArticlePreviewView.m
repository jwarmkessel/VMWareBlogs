//
//  VMArticlePreviewView.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/4/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticlePreviewView.h"

@implementation VMArticlePreviewView


float oldX, oldY;
float touchBeganX, touchBeganY;
float offsetX, offsetY;
BOOL dragging;
UIView *newView;

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"IS this getting called?");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"IS this DRAW RECT getting called?");
    self.backgroundColor = [UIColor blueColor];
    
    [self setNeedsDisplay];
    
    newView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 109.0, 320.0, 300.0)];
    [newView setBackgroundColor:[UIColor blueColor]];
    [self addSubview:newView];
    // Drawing code
}


/*
 To get the offset. Get touch began location and touch end location.
 
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Test View Touches Began");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    //    if ([[touch.view class] isSubclassOfClass:[UILabel class]]) {
    dragging = YES;

    
    //    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Test View Touches Ended %f %f", oldX, oldY);
    dragging = NO;

    CGRect frame = self.frame;
    if (frame.origin.y > 0) { //frame exceeds the horizontal boundary
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];

        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        frame.origin.y = 0;
        self.frame = frame;
        
        [UIView commitAnimations];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"Test View Touches Ended %f %f", oldX, oldY);
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    //    if ([[touch.view class] isSubclassOfClass:[UILabel class]]) {
    UILabel *label = (UILabel *)touch.view;
    if (dragging) {
        NSLog(@"I am dragging");
        CGRect frame = self.frame;
        
        if (frame.origin.x > 0) { //frame exceeds the horizontal boundary
            frame.origin.x = 0;
            self.frame = frame;
        }
        
//        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
//        rotationAndPerspectiveTransform.m34 = 1.0 / -500;
//        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, blah * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
//        self.scrollView.layer.transform = rotationAndPerspectiveTransform;
        
        
        
        touchBeganY += touchLocation.y - oldY;
        NSLog(@"offset %f", self.frame.origin.y + touchLocation.y - oldY);
        NSLog(@"offset total %f", touchBeganY);
        
        //frame.origin.x = label.frame.origin.x + touchLocation.x - oldX;
        frame.origin.y = label.frame.origin.y + touchLocation.y - oldY;
        //label.frame = frame;
        
        //[UIView beginAnimations:nil context:nil];
        
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -500;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, (self.frame.origin.y + touchLocation.y - oldY) * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
        newView.layer.transform = rotationAndPerspectiveTransform;

    }
    //    }
}


@end
