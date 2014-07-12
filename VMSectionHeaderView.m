//
//  VMSectionHeaderView.m
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 7/9/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "VMSectionHeaderView.h"

@implementation VMSectionHeaderView
@synthesize titleLabel = _titleLabel;
@synthesize open = _open;

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"346633"]];
        
        //Configure title label.
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        [_titleLabel setFont:[UIFont fontWithName:@"ArialMT" size:13]];
        _titleLabel.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_titleLabel];
        // set the selected image for the disclosure button
        [self.disclosureButton setImage:[UIImage imageNamed:@"carat-open.png"] forState:UIControlStateSelected];
        
        // set up the tap gesture recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(toggleOpen:)];
        [self addGestureRecognizer:tapGesture];
    }

    return self;
}

- (void)toggleOpen:(id)sender {
    [self toggleOpenWithUserAction:YES];
}

- (void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // toggle the disclosure button state
    self.disclosureButton.selected = !self.disclosureButton.selected;
    
    // if this was a user action, send the delegate the appropriate message
    if (userAction) {
        

        
        if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)] && self.open == NO) {
            
            [self.delegate sectionHeaderView:self sectionOpened:self.section];
            
        } else if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
            
            [self.delegate sectionHeaderView:self sectionClosed:self.section];
                
        
        }
    }
}


@end
