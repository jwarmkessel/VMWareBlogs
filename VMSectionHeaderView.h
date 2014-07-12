//
//  VMSectionHeaderView.h
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 7/9/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SectionHeaderFooterViewDelegate;

@interface VMSectionHeaderView : UITableViewHeaderFooterView

@property (getter = isOpen) BOOL open;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *disclosureButton;
@property (nonatomic, weak) id <SectionHeaderFooterViewDelegate> delegate;

@property (nonatomic) NSInteger section;

- (void)toggleOpenWithUserAction:(BOOL)userAction;

@end

#pragma mark -

/*
 Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.
 */
@protocol SectionHeaderFooterViewDelegate <NSObject>

@optional
- (void)sectionHeaderView:(VMSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section;
- (void)sectionHeaderView:(VMSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;

@end
