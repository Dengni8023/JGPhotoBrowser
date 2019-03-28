//
//  JGSPhoto.m
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSPhoto.h"
#import "JGSourceBase.h"

@implementation JGSPhoto

#pragma mark - Life Cycle
- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - 截图
- (UIImage *)capture:(UIView *)view {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)setSrcImageView:(UIImageView *)srcImageView {
    
    _srcImageView = srcImageView;
    self.placeholder = self.placeholder ?: srcImageView.image;
    if (srcImageView.clipsToBounds) {
        _capture = [self capture:srcImageView];
    }
}

#pragma mark - End

@end
