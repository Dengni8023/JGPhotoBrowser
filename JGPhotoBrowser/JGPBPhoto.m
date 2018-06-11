//
//  JGPBPhoto.m
//  JGPhotoBrowser
//
//  Created by Mei Jigao on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "JGPBPhoto.h"
#import "JGSourceBase.h"

@implementation JGPBPhoto

#pragma mark - init
- (void)dealloc {
    
    //JGSCLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark 截图
- (UIImage *)capture:(UIView *)view {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)setSrcImageView:(UIImageView *)srcImageView {
    
    _srcImageView = srcImageView;
    _placeholder = self.placeholder ?: srcImageView.image;
    if (srcImageView.clipsToBounds) {
        
        _capture = [self capture:srcImageView];
    }
}

#pragma mark - End

@end

@implementation JGPhoto

@end
