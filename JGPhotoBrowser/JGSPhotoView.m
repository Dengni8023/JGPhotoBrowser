//
//  JGSPhotoView.m
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSPhotoView.h"
#import "JGSPhotoStatusView.h"
//#import "UIView+WebCache.h"
#import "JGSourceBase.h"

@interface JGSPhotoView () <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL zoomByDoubleTap;
@property (nonatomic, strong) SDAnimatedImageView *imgViewWithGIF;
@property (nonatomic, strong) JGSPhotoStatusView *photoStatusView;

@end

@implementation JGSPhotoView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        // 图片
        _imgViewWithGIF = [[SDAnimatedImageView alloc] init];
        _imgViewWithGIF.backgroundColor = [UIColor blackColor];
        _imgViewWithGIF.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imgViewWithGIF];
        
        // 进度条
        _photoStatusView = [[JGSPhotoStatusView alloc] init];
        
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
    [self.imgViewWithGIF sd_cancelCurrentImageLoad]; // 取消请求
}

#pragma mark - 显示图片
- (void)setPhoto:(JGSPhoto *)photo {
    
    _photo = photo;
    
    [self startLoadPhotoImage];
    [self adjustFrame];
}

- (void)adjustFrame {
    
    if (self.imgViewWithGIF.image == nil) {
        return;
    }
    
    // 基本尺寸参数
    CGFloat boundsWidth = CGRectGetWidth(self.frame);
    CGFloat boundsHeight = CGRectGetHeight(self.frame);
    CGFloat imageWidth = self.imgViewWithGIF.image.size.width;
    CGFloat imageHeight = self.imgViewWithGIF.image.size.height;
    
    // 设置伸缩比例
    CGFloat imageScale = boundsWidth / imageWidth;
    CGFloat minScale = MIN(0.5, imageScale);
    
    CGFloat maxScale = 4.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, MAX(0, (boundsHeight- imageHeight*imageScale) * 0.5), boundsWidth, imageHeight *imageScale);
    
    self.contentSize = CGSizeMake(CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame));
    self.imgViewWithGIF.frame = imageFrame;
}

#pragma mark - Load
- (void)startLoadPhotoImage {
    
    if (self.photo.image) {
        
        [self.photoStatusView removeFromSuperview];
        self.imgViewWithGIF.image = self.photo.image;
        self.scrollEnabled = YES;
    }
    else {
        
        self.imgViewWithGIF.image = self.photo.placeholder;
        self.scrollEnabled = NO;
        
        // 直接显示进度条
        [self.photoStatusView showWithStatus:JGSPhotoStatusLoading];
        [self addSubview:self.photoStatusView];
        
        JGSWeakSelf
        [self.imgViewWithGIF sd_setImageWithURL:self.photo.url placeholderImage:(self.photo.image ?: self.photo.placeholder) options:(SDWebImageRetryFailed | SDWebImageLowPriority | SDWebImageHandleCookies | SDWebImageTransformAnimatedImage) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
            if (receivedSize > JGSPhotoLoadMinProgress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    JGSStrongSelf
                    self.photoStatusView.progress = (CGFloat)receivedSize / expectedSize;
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
    
    if (self.imgViewWithGIF.image) {
        
        self.scrollEnabled = YES;
        self.photo.image = self.imgViewWithGIF.image;
        [self.photoStatusView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    }
    else {
        
        [self addSubview:self.photoStatusView];
        [self.photoStatusView showWithStatus:JGSPhotoStatusLoadFail];
    }
    
    // 设置缩放比例
    [self adjustFrame];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (self.zoomByDoubleTap) {
        
        CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(self.imgViewWithGIF.frame)) * 0.5;
        insetY = MAX(insetY, 0.0);
        if (ABS(self.imgViewWithGIF.frame.origin.y - insetY) > JGSMinimumPoint) {
            
            CGRect imageViewFrame = self.imgViewWithGIF.frame;
            imageViewFrame = CGRectMake(imageViewFrame.origin.x, insetY, imageViewFrame.size.width, imageViewFrame.size.height);
            self.imgViewWithGIF.frame = imageViewFrame;
        }
    }
    
    return self.imgViewWithGIF;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    self.zoomByDoubleTap = NO;
    CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(self.imgViewWithGIF.frame)) * 0.5;
    insetY = MAX(insetY, 0.0);
    if (ABS(self.imgViewWithGIF.frame.origin.y - insetY) > JGSMinimumPoint) {
        
        JGSWeakSelf
        [UIView animateWithDuration:0.2 animations:^{
            
            JGSStrongSelf
            CGRect imageViewFrame = self.imgViewWithGIF.frame;
            imageViewFrame = CGRectMake(imageViewFrame.origin.x, insetY, imageViewFrame.size.width, imageViewFrame.size.height);
            self.imgViewWithGIF.frame = imageViewFrame;
        }];
    }
}

#pragma mark - Gesture
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    
    // 移除提示
    JGSWeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        JGSStrongSelf
        self.photoStatusView.alpha = 0;
    } completion:^(BOOL finished) {
        JGSStrongSelf
        [self.photoStatusView removeFromSuperview];
    }];
    
    // 通知代理
    if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        [self.photoViewDelegate photoViewSingleTap:self];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    
    //双击放大
    self.zoomByDoubleTap = YES;
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
