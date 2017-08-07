//
//  JGPhotoView.m
//  JGPhotoBrowserExample
//
//  Created by 梅继高 on 2017/6/29.
//  Copyright © 2017年 Jigao Mei. All rights reserved.
//

#import "JGPhotoView.h"
#import "JGPhotoLoadingView.h"
#import <SDWebImage/FLAnimatedImageView+WebCache.h>
#import <objc/runtime.h>

#define ESWeak(var, weakVar) __weak __typeof(&*var) weakVar = var
#define ESStrong_DoNotCheckNil(weakVar, _var) __typeof(&*weakVar) _var = weakVar
#define ESStrong(weakVar, _var) ESStrong_DoNotCheckNil(weakVar, _var); if (!_var) return;

#define ESWeak_(var) ESWeak(var, weak_##var);
#define ESStrong_(var) ESStrong(weak_##var, _##var);

/** defines a weak `self` named `__weakSelf` */
#define ESWeakSelf      ESWeak(self, __weakSelf);
/** defines a strong `self` named `_self` from `__weakSelf` */
#define ESStrongSelf    ESStrong(__weakSelf, _self);

@interface JGPhotoView () <UIScrollViewDelegate> {
    
    BOOL _zoomByDoubleTap;
    FLAnimatedImageView *imgViewWithGIF;
    JGPhotoLoadingView *photoLoadingView;
}

@end

@implementation JGPhotoView

#pragma mark - init & dealloc
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
        photoLoadingView = [[JGPhotoLoadingView alloc] init];
        
        // 属性
        self.delegate = self;
        //self.showsHorizontalScrollIndicator = NO;
        //self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
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
    
    //NSLog(@"%s %zd :", __PRETTY_FUNCTION__, __LINE__);
    
    // 取消请求
    [imgViewWithGIF sd_setImageWithURL:[NSURL URLWithString:@"file:///abc"]];
}

#pragma mark - 显示图片
- (void)setPhoto:(JGPhoto *)photo {
    
    _photo = photo;
    
    [self startLoadPhotoImage];
    [self adjustFrame];
}

- (void)adjustFrame {
    
    if (imgViewWithGIF.image == nil) return;
    
    // 基本尺寸参数
    CGFloat boundsWidth = self.bounds.size.width;
    CGFloat boundsHeight = self.bounds.size.height;
    CGFloat imageWidth = imgViewWithGIF.image.size.width;
    CGFloat imageHeight = imgViewWithGIF.image.size.height;
    
    // 设置伸缩比例
    CGFloat imageScale = boundsWidth / imageWidth;
    CGFloat minScale = MIN(1.0, imageScale);
    
    CGFloat maxScale = 2.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, MAX(0, (boundsHeight- imageHeight*imageScale)/2), boundsWidth, imageHeight *imageScale);
    
    self.contentSize = CGSizeMake(CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame));
    imgViewWithGIF.frame = imageFrame;
}

#pragma mark - Load
- (void)startLoadPhotoImage {
    
    if (_photo.GIFImage) {
        
        [photoLoadingView removeFromSuperview];
        imgViewWithGIF.animatedImage = _photo.GIFImage;
        self.scrollEnabled = YES;
    }
    else if (_photo.image) {
        
        [photoLoadingView removeFromSuperview];
        imgViewWithGIF.image = _photo.image;
        self.scrollEnabled = YES;
    }
    else {
        
        imgViewWithGIF.image = _photo.placeholder;
        self.scrollEnabled = NO;
        
        // 直接显示进度条
        [photoLoadingView showLoading];
        [self addSubview:photoLoadingView];
        
        ESWeakSelf;
        ESWeak_(photoLoadingView);
        ESWeak_(imgViewWithGIF);
        
        [imgViewWithGIF sd_setImageWithURL:_photo.url placeholderImage:_photo.image ?: _photo.placeholder options:(SDWebImageRetryFailed | SDWebImageLowPriority | SDWebImageHandleCookies | SDWebImageTransformAnimatedImage) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
            ESStrong_(photoLoadingView);
            if (receivedSize > kMinProgress) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    photoLoadingView.progress = (float)receivedSize/expectedSize;
                });
            }
            
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            ESStrongSelf;
            ESStrong_(imgViewWithGIF);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_self photoImageDidFinishLoad];
            });
        }];
    }
}

- (void)photoImageDidFinishLoad {
    
    if (imgViewWithGIF.image) {
        
        self.scrollEnabled = YES;
        _photo.GIFImage = imgViewWithGIF.animatedImage;
        _photo.image = imgViewWithGIF.image;
        [photoLoadingView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    }
    else {
        
        [self addSubview:photoLoadingView];
        [photoLoadingView showFailure];
    }
    
    // 设置缩放比例
    [self adjustFrame];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (_zoomByDoubleTap) {
        
        CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(imgViewWithGIF.frame))/2;
        insetY = MAX(insetY, 0.0);
        if (ABS(imgViewWithGIF.frame.origin.y - insetY) > 0.5) {
            
            CGRect imageViewFrame = imgViewWithGIF.frame;
            imageViewFrame = CGRectMake(imageViewFrame.origin.x, insetY, imageViewFrame.size.width, imageViewFrame.size.height);
            imgViewWithGIF.frame = imageViewFrame;
        }
    }
    
    return imgViewWithGIF;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    _zoomByDoubleTap = NO;
    CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(imgViewWithGIF.frame))/2;
    insetY = MAX(insetY, 0.0);
    if (ABS(imgViewWithGIF.frame.origin.y - insetY) > 0.5) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect imageViewFrame = imgViewWithGIF.frame;
            imageViewFrame = CGRectMake(imageViewFrame.origin.x, insetY, imageViewFrame.size.width, imageViewFrame.size.height);
            imgViewWithGIF.frame = imageViewFrame;
        }];
    }
}

#pragma mark - 手势处理
//单击隐藏
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    
    // 移除进度条
    [photoLoadingView removeFromSuperview];
    
    // 通知代理
    if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        
        [self.photoViewDelegate photoViewSingleTap:self];
    }
}

//双击放大
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    
    _zoomByDoubleTap = YES;
    if (self.zoomScale == self.maximumZoomScale) {
        
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else {
        
        CGPoint touchPoint = [tap locationInView:self];
        CGFloat scale = self.maximumZoomScale/ self.zoomScale;
        CGRect rectTozoom=CGRectMake(touchPoint.x * scale, touchPoint.y * scale, 1, 1);
        [self zoomToRect:rectTozoom animated:YES];
    }
}

#pragma mark - End

@end
