//
//  VMArticleOptions.m
//  VMWareBlogs
//
//  Created by Justin Warmkessel on 5/10/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMArticleOptions.h"
#import "VMCommon.h"

@interface VMArticleOptions ()
@property (strong, nonatomic) VMCommon *common;
@property (strong, nonatomic) UIView *dropDownView;
@end

@implementation VMArticleOptions
@synthesize isHidden;

- (id)initWithFrame:(CGRect)frame height:(float)height {
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
        
        [self configureDropDownButtons];
    }
    return self;
}

- (void)configureDropDownButtons {
    
    UIButton *facebookBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 58.0, 58.0)];
    [self addSubview:facebookBtn];
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
        } else {
            rect.origin.y = -1 * _dropDownView.layer.frame.size.height;
            _dropDownView.layer.frame = rect;
            isHidden = YES;
        }
    } completion:^(BOOL finished) {
        NSLog(@"Animation completed");
    }];
}



@end
