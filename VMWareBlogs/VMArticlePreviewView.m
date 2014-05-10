//
//  VMArticlePreviewView.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/4/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticlePreviewView.h"

@interface VMArticlePreviewView()


@end

@implementation VMArticlePreviewView

float oldX, oldY;
float touchBeganX, touchBeganY;
float offsetX, offsetY;
float test;
BOOL dragging;


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

    // Drawing code
}

- (void)setDescriptionWithAttributedText:(NSString *)text {
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 600.0)];
    [self setAnchorPoint:CGPointMake(1.0, 0.0) forView:self.testView];
    self.testView.userInteractionEnabled = NO;
    [self addSubview:self.testView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 109.0)];
    [self.imageView setImage:[UIImage imageNamed:@"placeholder.png"]];
    [self.testView addSubview:self.imageView];
    
    UIView *imageViewCover = [[UIView alloc] initWithFrame:self.imageView.frame];
    [imageViewCover setBackgroundColor:[UIColor blackColor]];
    imageViewCover.alpha = 0.5;
    [self.imageView addSubview:imageViewCover];
    
    self.titleTextView = [[UITextView alloc] initWithFrame:self.imageView.frame];
    
    [self.titleTextView setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    self.titleTextView.textAlignment = NSTextAlignmentCenter;
    [self.titleTextView setBackgroundColor:[UIColor clearColor]];
    self.titleTextView.textColor = [UIColor whiteColor];
    
    [self.testView addSubview:self.titleTextView];
    
    self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 110.0, 320.0, 600.0)];
    [self.testView addSubview:self.descriptionTextView];

    //THIS WILL ONLY WORK FOR iOS 6 and greater.
    NSString *labelText = text;
    labelText = [NSString stringWithFormat:@"\t%@", labelText];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    
    
    //Set the scrollview size.
    self.descriptionTextView.attributedText = attributedString;
    self.descriptionTextView.textAlignment = NSTextAlignmentLeft;
    [self.descriptionTextView setTextColor:[self colorWithHexString:@"5D5B5B"]];
    [self.descriptionTextView setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
    
    NSLog(@"CHeck the description Text Field Height %f", self.descriptionTextView.frame.size.height);
}
/*
 To get the offset. Get touch began location and touch end location.
 
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Test View Touches Began");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    
    dragging = YES;
    oldX = touchLocation.x;
    oldY = touchLocation.y;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Test View Touches Ended %f %f", oldX, oldY);
    dragging = NO;
    
    CGRect frame = self.frame;
    
    [self.delegate articlePreviewFinishedMoving:test];


    if (frame.origin.y < 0) { //frame exceeds the horizontal boundary
        
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -500;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 1 * 0.0001 * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
        self.testView.layer.transform = rotationAndPerspectiveTransform;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        frame.origin.y = 0;
        self.frame = frame;
        
        [UIView commitAnimations];
        test = 0;
    } else if (frame.origin.y > 0) { //frame exceeds the horizontal boundary
        
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -500;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 1 * 0.0001 * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
        self.testView.layer.transform = rotationAndPerspectiveTransform;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        frame.origin.y = 0;
        self.frame = frame;
        
        [UIView commitAnimations];
        test = 0;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGRect frame = self.frame;
    touchBeganX = self.frame.origin.x - touchBeganX;
    touchBeganY = self.frame.origin.y - touchBeganY;
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    //    if ([[touch.view class] isSubclassOfClass:[UILabel class]]) {
    UILabel *label = (UILabel *)touch.view;
    if (dragging) {
        if (frame.origin.x > 0) { //frame exceeds the horizontal boundary
            frame.origin.x = 0;
            self.frame = frame;
        }
        
        test += touchLocation.y - oldY;
//        NSLog(@"Degrees to move %f", -1 * test * M_PI );
        //frame.origin.x = label.frame.origin.x + touchLocation.x - oldX;
        frame.origin.y = self.frame.origin.y + touchLocation.y - oldY;
        
        //3D transform code.
        [UIView beginAnimations:nil context:nil];
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -500;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -1 * test * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
        self.testView.layer.transform = rotationAndPerspectiveTransform;
        [UIView commitAnimations];
        
        [self.delegate articlePreviewMoved:test];
        
        label.frame = frame;
    }
}



-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

-(UIColor*)colorWithHexString:(NSString*)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


@end
