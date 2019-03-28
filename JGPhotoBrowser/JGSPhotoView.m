//
//  JGSPhotoView.m
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSPhotoView.h"
#import "JGSPhotoStatusView.h"
#import "FLAnimatedImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "JGSourceBase.h"

@interface JGSPhotoView () <UIScrollViewDelegate> {
    
    BOOL _zoomByDoubleTap;
    FLAnimatedImageView *imgViewWithGIF;
    JGSPhotoStatusView *photoStatusView;
}

@end

@implementation JGSPhotoView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        // 图片
        imgViewWithGIF = [[FLAnimatedImageView alloc] init];
        imgViewWithGIF.backgroundColor = [UIColor blackColor];
        imgViewWithGIF.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imgViewWithGIF];
        
        // 进度条
        photoStatusView = [[JGSPhotoStatusView alloc] init];
        
        // 属性
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
    
    [imgViewWithGIF sd_cancelCurrentImageLoad]; // 取消请求
}

#pragma mark - View
//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    [self adjustFrame];
//}

#pragma mark - 显示图片
- (void)setPhoto:(JGSPhoto *)photo {
    
    _photo = photo;
    
    [self startLoadPhotoImage];
    [self adjustFrame];
}

- (void)adjustFrame {
    
    if (imgViewWithGIF.image == nil) {
        return;
    }
    
    // 基本尺寸参数
    CGFloat boundsWidth = self.bounds.size.width;
    CGFloat boundsHeight = self.bounds.size.height;
    CGFloat imageWidth = imgViewWithGIF.image.size.width;
    CGFloat imageHeight = imgViewWithGIF.image.size.height;
    
    // 设置伸缩比例
    CGFloat imageScale = boundsWidth / imageWidth;
    CGFloat minScale = MIN(0.8, imageScale);
    
    CGFloat maxScale = 3.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, MAX(0, (boundsHeight- imageHeight*imageScale) * 0.5), boundsWidth, imageHeight *imageScale);
    
    self.contentSize = CGSizeMake(CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame));
    imgViewWithGIF.frame = imageFrame;
}

#pragma mark - Load
- (void)startLoadPhotoImage {
    
    if (_photo.GIFImage) {
        
        [photoStatusView removeFromSuperview];
        imgViewWithGIF.animatedImage = _photo.GIFImage;
        self.scrollEnabled = YES;
    }
    else if (_photo.image) {
        
        [photoStatusView removeFromSuperview];
        imgViewWithGIF.image = _photo.image;
        self.scrollEnabled = YES;
    }
    else {
        
        imgViewWithGIF.image = _photo.placeholder;
        self.scrollEnabled = NO;
        
        // 直接显示进度条
        [photoStatusView showWithStatus:JGSPhotoStatusLoading];
        [self addSubview:photoStatusView];
        
        JGSWeakSelf
        JGSWeak(photoStatusView)
        [imgViewWithGIF sd_setImageWithURL:_photo.url placeholderImage:_photo.image ?: _photo.placeholder options:(SDWebImageRetryFailed | SDWebImageLowPriority | SDWebImageHandleCookies | SDWebImageTransformAnimatedImage) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
            if (receivedSize > JGSPhotoLoadMinProgress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    JGSStrong(photoStatusView);
                    photoStatusView.progress = (CGFloat)receivedSize / expectedSize;
                });
            }
            
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                JGSStrongSelf
                [self photoImageDidFinishLoad];
            });
        }];
    }
}

- (void)photoImageDidFinishLoad {
    
    if (imgViewWithGIF.image) {
        
        self.scrollEnabled = YES;
        _photo.GIFImage = imgViewWithGIF.animatedImage;
        _photo.image = imgViewWithGIF.image;
        [photoStatusView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    }
    else {
        
        [self addSubview:photoStatusView];
        [photoStatusView showWithStatus:JGSPhotoStatusLoadFail];
    }
    
    // 设置缩放比例
    [self adjustFrame];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (_zoomByDoubleTap) {
        
        CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(imgViewWithGIF.frame)) * 0.5;
        insetY = MAX(insetY, 0.0);
        if (ABS(imgViewWithGIF.frame.origin.y - insetY) > JGSMinimumPoint) {
            
            CGRect imageViewFrame = imgViewWithGIF.frame;
            imageViewFrame = CGRectMake(imageViewFrame.origin.x, insetY, imageViewFrame.size.width, imageViewFrame.size.height);
            imgViewWithGIF.frame = imageViewFrame;
        }
    }
    
    return imgViewWithGIF;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    _zoomByDoubleTap = NO;
    CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(imgViewWithGIF.frame)) * 0.5;
    insetY = MAX(insetY, 0.0);
    if (ABS(imgViewWithGIF.frame.origin.y - insetY) > JGSMinimumPoint) {
        
        JGSWeak(imgViewWithGIF)
        [UIView animateWithDuration:0.2 animations:^{
            
            JGSStrong(imgViewWithGIF)
            CGRect imageViewFrame = imgViewWithGIF.frame;
            imageViewFrame = CGRectMake(imageViewFrame.origin.x, insetY, imageViewFrame.size.width, imageViewFrame.size.height);
            imgViewWithGIF.frame = imageViewFrame;
        }];
    }
}

#pragma mark - Gesture
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    
    // 移除提示
    JGSWeak(photoStatusView)
    [UIView animateWithDuration:0.2 animations:^{
        JGSStrong(photoStatusView)
        photoStatusView.alpha = 0;
    } completion:^(BOOL finished) {
        JGSStrong(photoStatusView)
        [photoStatusView removeFromSuperview];
    }];
    
    // 通知代理
    if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        [self.photoViewDelegate photoViewSingleTap:self];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    
    //双击放大
    _zoomByDoubleTap = YES;
    if (self.zoomScale == self.maximumZoomScale) {
        
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else {
        
        CGPoint touchPoint = [tap locationInView:self];
        CGFloat scale = self.maximumZoomScale / self.zoomScale;
        CGRect rectTozoom = CGRectMake(touchPoint.x * scale, touchPoint.y * scale, 1, 1);
        [self zoomToRect:rectTozoom animated:YES];
    }
}

#pragma mark - End

@end
