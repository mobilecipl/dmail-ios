//
//  MenuSectionView.h
//  Dmail
//
//  Created by Karen Petrosyan on 9/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuSectionViewDelegate <NSObject>

- (void)onArrowClicked:(id)menuSection;
- (void)onAddAccountClicked;

@end


@interface MenuSectionView : UIView

@property (nonatomic, assign) id<MenuSectionViewDelegate> delegate;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) BOOL arrowUp;

//Creates view for some profile
- (instancetype)initWithFrame:(CGRect)frame email:(NSString *)email profileImageUrl:(NSString *)profileImageUrl selected:(BOOL)selected;
//Creates add account view
- (instancetype)initWithFrame:(CGRect)frame;
- (void)closeSection;

@end
