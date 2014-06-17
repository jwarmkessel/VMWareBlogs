//
//  VMOverlayView.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/6/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMOverlayView.h"

@interface VMOverlayView ()
@property (strong, nonatomic) UIButton *removeButton;

- (void)addTransparentView;
- (void)addRemoveButton;
- (void)removeSelf;
- (void)addLabels;
- (UILabel *)createOverlayLabelsWithFrame: (CGRect)rect;
- (UIImageView *)createArrowImage:(NSString *)imageName frame:(CGRect)rect;
@end

@implementation VMOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code


    }
    return self;
}

- (void)addTransparentView {
    CGRect transparentFrame = self.frame;
    UIView *transparentView = [[UIView alloc] initWithFrame:transparentFrame];
    transparentView.backgroundColor = [UIColor blackColor];
    transparentView.alpha = 0.7;
    [self addSubview:transparentView];
    
    [self addRemoveButton];
    [self addLabels];
}

- (void)addRemoveButton {
    CGRect removeButtonFrame = self.frame;
    removeButtonFrame.origin.x = 260;
    removeButtonFrame.origin.y = 70;
    removeButtonFrame.size = CGSizeMake(58, 58);
    
    self.removeButton = [[UIButton alloc] initWithFrame:removeButtonFrame];
    [self.removeButton setBackgroundImage:[UIImage imageNamed:@"CloseX.png"] forState:UIControlStateNormal];
    [self.removeButton setBackgroundImage:[UIImage imageNamed:@"CloseXPressed.png"] forState:UIControlStateSelected];
    
    //Add action to button.
    [self.removeButton addTarget:self
                          action:@selector(removeSelf)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self flashOn:self.removeButton];
    
    [self addSubview:self.removeButton];
}

- (void)removeSelf {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];

}

- (void) addLabels {
    
    //A label
    CGRect labelFrame1 = CGRectMake(20.0, 400.0, 320.0, 40.0);
    UILabel *label1 = [self createOverlayLabelsWithFrame:labelFrame1];
    label1.text = @"Click anywhere to navigate away.";
    [self addSubview:label1];
    
    CGRect imageFrame1 = CGRectMake(200.0, 432.0, 320.0, 40.0);
    UIImageView *imageView1 = [self createArrowImage:@"blue-arrow-right.png" frame:imageFrame1];
    [self addSubview:imageView1];
    
    
    
    CGRect labelFrame2 = CGRectMake(0.0, 38.0, 320.0, 40.0);
    UILabel *label2 = [self createOverlayLabelsWithFrame:labelFrame2];
    label2.text = @"Click for more options to share or save for later.";
    [self addSubview:label2];
    
    CGRect imageFrame2 = CGRectMake(250.0, 5.0, 320.0, 40.0);
    UIImageView *imageView2 = [self createArrowImage:@"blue-arrow-right.png" frame:imageFrame2];
    imageView2.image = [UIImage imageWithCGImage:imageView2.image.CGImage
                                                scale:imageView2.image.scale orientation: UIImageOrientationDownMirrored];
    [self addSubview:imageView2];
    
    
    
    
    
    CGRect labelFrame3 = CGRectMake(40.0, 335.0, 320.0, 40.0);
    UILabel *label3 = [self createOverlayLabelsWithFrame:labelFrame3];
    label3.text = @"Swipe up to continue to full article.";
    [self addSubview:label3];
    
    CGRect imageFrame3 = CGRectMake(130.0, 300.0, 320.0, 40.0);
    UIImageView *imageView3 = [self createArrowImage:@"blue-arrow-left.png" frame:imageFrame3];
    imageView3.image = [UIImage imageWithCGImage:imageView3.image.CGImage
                                           scale:imageView3.image.scale orientation: UIImageOrientationDownMirrored];
    
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -500;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 20 * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
    imageView3.layer.transform = rotationAndPerspectiveTransform;
    
    [self addSubview:imageView3];
    
}

- (UILabel *)createOverlayLabelsWithFrame: (CGRect)rect {

    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.textColor = [UIColor colorWithHexString:@"39AECF"];
    [label setFont:[UIFont fontWithName:@"Arial" size:15.0f]];
    
    return label;
    
}

- (UIImageView *)createArrowImage:(NSString *)imageName frame:(CGRect)rect {
    rect.size.width = 58.0f;
    rect.size.width = 58.0f;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView setImage:[UIImage imageNamed:imageName]];

    return imageView;
}

- (void)flashOff:(UIView *)v
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = .3;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        [self flashOn:v];
    }];
}

- (void)flashOn:(UIView *)v
{
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = 1;
    } completion:^(BOOL finished) {
        [self flashOff:v];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code


    
}*/


@end
