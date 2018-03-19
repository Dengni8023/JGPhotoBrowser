//
//  DemoCollectionViewCell.m
//  JGPhotoBrowserDemo
//
//  Created by Mei Jigao on 2018/3/19.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "DemoCollectionViewCell.h"
#import <JGSourceBase/JGSourceBase.h>

@implementation DemoCollectionViewCell

#pragma mark - init & dealloc
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initViewElements];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initViewElements];
    }
    return self;
}

- (void)initViewElements {
    
    _imageView = [[FLAnimatedImageView alloc] init];
    [self.contentView addSubview:_imageView];
}

- (void)dealloc {
    
    JGLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
}

#pragma mark - End

@end
