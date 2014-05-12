//
//  VMArticleOptions.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleOptions.h"
#import "VMCommon.h"
#import <Social/Social.h>

@interface VMArticleOptions (){
    UITextView *sharingTextView;
}

@property (strong, nonatomic) VMCommon *common;
@property (strong, nonatomic) UIView *dropDownView;
@property (strong, nonatomic) id viewController;
@end

@implementation VMArticleOptions
@synthesize isHidden;
@synthesize viewController;

- (id)initWithFrame:(CGRect)frame viewController:(id)vc height:(float)height {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        //Configure visible drop down menu.
        CGRect rect = self.frame;
        rect.origin.y = -1 * height;
        rect.size.height = height;
        _dropDownView = [[UIView alloc] initWithFrame:rect];
        _common = [[VMCommon alloc] init];
        [_dropDownView setBackgroundColor:[_common colorWithHexString:@"8A8D91"]];
        [self addSubview:_dropDownView];
        
        //set default to hidden.
        self.isHidden = YES;
        self.userInteractionEnabled = NO;
        
        //The setup code (in viewDidLoad in your view controller)
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
        
        [self configureDropDownButtons];
    }
    return self;
}

- (void)configureDropDownButtons {
    
    UIButton *facebookBtn = [[UIButton alloc] initWithFrame:CGRectMake(87.0, 21.0, 58.0, 58.0)];
    [facebookBtn setImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    [facebookBtn setImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateSelected];
    
    [facebookBtn addTarget:self
                    action:@selector(fbParticipationBtnHandler)
          forControlEvents:UIControlEventTouchUpInside];

    
    [_dropDownView addSubview:facebookBtn];
    
    UIButton *twitterBtn = [[UIButton alloc] initWithFrame:CGRectMake(175.0, 21.0, 58.0, 58.0)];
    [twitterBtn setImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
    [twitterBtn setImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateSelected];
    
    [twitterBtn addTarget:self
                   action:@selector(twitterParticipationBtnHandler)
         forControlEvents:UIControlEventTouchUpInside];
    
    [_dropDownView addSubview:twitterBtn];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)toggleDropDown {
    [UIView animateWithDuration:0.6 animations:^{
        CGRect rect = _dropDownView.layer.frame;
        
        if([self isHidden]) {
            rect.origin.y = 0;
            _dropDownView.layer.frame = rect;
            isHidden = NO;
            self.userInteractionEnabled = YES;
        } else {
            rect.origin.y = -1 * _dropDownView.layer.frame.size.height;
            _dropDownView.layer.frame = rect;
            isHidden = YES;
        }
    } completion:^(BOOL finished) {
        NSLog(@"Animation completed");
    }];
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _dropDownView.layer.frame;
        rect.origin.y = -1 * _dropDownView.layer.frame.size.height;
        _dropDownView.layer.frame = rect;
        isHidden = YES;
        
    } completion:^(BOOL finished) {
        NSLog(@"Animation completed");
        self.userInteractionEnabled = NO;
    }];
}

- (void)fbParticipationBtnHandler {
    [self.delegate facebookButtonTapped];
}

- (void)twitterParticipationBtnHandler {    
    [self.delegate twitterButtonTapped];
}



@end
