//
//  JGPhotoBrowserDemoCell.m
//  JGPhotoBrowserDemo
//
//  Created by Mei Jigao on 2017/11/24.
//  Copyright © 2017年 MeiJigao. All rights reserved.
//

#import "JGPhotoBrowserDemoCell.h"
#import "FLAnimatedImageView.h"

@implementation JGPhotoBrowserDemoCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[FLAnimatedImageView alloc] init];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
}

@end
