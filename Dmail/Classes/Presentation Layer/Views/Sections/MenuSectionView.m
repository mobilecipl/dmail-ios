//
//  MenuSectionView.m
//  Dmail
//
//  Created by Karen Petrosyan on 9/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MenuSectionView.h"
#import "UIColor+AppColors.h"
#import "SWRevealViewController.h"
#import "UIImageView+WebCache.h"

const NSInteger imageBorderWidth = 2;

@interface MenuSectionView ()

@property (nonatomic,strong ) UIButton *buttonArrow;
@property (nonatomic,strong ) UIImageView *imageViewProfile;

@end

@implementation MenuSectionView

- (instancetype)initWithFrame:(CGRect)frame email:(NSString *)email profileImageUrl:(NSString *)profileImageUrl selected:(BOOL)selected {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.email = email;
        UIView *viewImageBorder = [[UIView alloc] initWithFrame:CGRectMake(15, (self.frame.size.height - 30)/2, 30, 30)];
        viewImageBorder.backgroundColor = [UIColor participantsColor];
        viewImageBorder.layer.masksToBounds = YES;
        viewImageBorder.layer.cornerRadius = viewImageBorder.frame.size.width/2;
        
        self.imageViewProfile = [[UIImageView alloc] initWithFrame:CGRectMake(imageBorderWidth, imageBorderWidth, viewImageBorder.frame.size.width - 2*imageBorderWidth, viewImageBorder.frame.size.height - 2*imageBorderWidth)];
        [viewImageBorder addSubview:self.imageViewProfile];
        self.imageViewProfile.layer.masksToBounds = YES;
        self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
        [self fetchProfileImageWithImageUrl:profileImageUrl];
        
        
        CGFloat labelWidth = 120;
        if (self.frame.size.width > 320) {
            labelWidth = 150;
        }
        UILabel *labelEmail = [[UILabel alloc] initWithFrame:CGRectMake(viewImageBorder.frame.origin.x + viewImageBorder.frame.size.width + 5, (self.frame.size.height - 20)/2, labelWidth, 30)];
        labelEmail.center = CGPointMake(labelEmail.center.x, self.center.y);
        labelEmail.text = email;
        labelEmail.font = [UIFont fontWithName:@"ProximaNova-Light" size:13.5];
        [self addSubview:labelEmail];
        
        if (selected) {
            labelEmail.textColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:35.0/255.0 blue:38.0/255.0 alpha:1];
            UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
            viewLine.backgroundColor = [UIColor colorWithRed:78.0/255.0 green:87.0/255.0 blue:93.0/255.0 alpha:1];
            [self addSubview:viewLine];
        }
        else {
            viewImageBorder.backgroundColor = [UIColor clearColor];
            labelEmail.textColor = [UIColor colorWithRed:167.0/255.0 green:181.0/255.0 blue:192.0/255.0 alpha:1];
            self.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:56.0/255.0 blue:61.0/255.0 alpha:1];
        }
        
        UIImage *imageArrow = [UIImage imageNamed:@"buttonArrowDown.png"];
        self.buttonArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        self.buttonArrow.frame = CGRectMake(labelEmail.frame.origin.x + labelEmail.frame.size.width, 0, imageArrow.size.width + 10, imageArrow.size.height + 20);
        [self.buttonArrow setImage:imageArrow forState:UIControlStateNormal];
        self.buttonArrow.center = CGPointMake(self.buttonArrow.center.x, self.center.y);
        [self.buttonArrow addTarget:self action:@selector(buttonArrowClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.buttonArrow];
        
        [self addSubview:viewImageBorder];
    }
    
    return self;
}

- (void)fetchProfileImageWithImageUrl:(NSString *)imageUrl {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:imageUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    [self.imageViewProfile setImage:image];
                }
                else {
                    [self fetchProfileImageWithImageUrl:imageUrl];
                }
            });
        }];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *imageAddAccount = [UIImage imageNamed:@"buttonAddAccountForSection.png"];
        UIButton *buttonAddAccount = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonAddAccount.frame = CGRectMake(22.5, 0, imageAddAccount.size.width, imageAddAccount.size.height);
        [buttonAddAccount setImage:imageAddAccount forState:UIControlStateNormal];
        buttonAddAccount.center = CGPointMake(buttonAddAccount.center.x, self.center.y);
        [buttonAddAccount addTarget:self action:@selector(buttonAddAccountClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonAddAccount];
    }
    
    return self;
}

- (void)closeSection {
    
    self.arrowUp = NO;
    [self.buttonArrow setImage:[UIImage imageNamed:@"buttonArrowDown.png"] forState:UIControlStateNormal];
    self.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:56.0/255.0 blue:61.0/255.0 alpha:1];
}

- (void)buttonArrowClicked {
    
    if (self.arrowUp) {
        [self.buttonArrow setImage:[UIImage imageNamed:@"buttonArrowDown.png"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonArrow setImage:[UIImage imageNamed:@"buttonArrowUp.png"] forState:UIControlStateNormal];
        self.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:35.0/255.0 blue:38.0/255.0 alpha:1];
        
    }
    
    self.arrowUp = !self.arrowUp;
    if ([self.delegate respondsToSelector:@selector(onArrowClicked:)]) {
        [self.delegate onArrowClicked:self];
    }
}

- (void)buttonAddAccountClicked {
    
    if ([self.delegate respondsToSelector:@selector(onAddAccountClicked)]) {
        [self.delegate onAddAccountClicked];
    }
}

@end
