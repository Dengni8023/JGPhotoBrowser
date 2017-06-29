//
//  JGPhotoBrowser.m
//  JGPhotoBrowserExample
//
//  Created by 梅继高 on 2017/6/29.
//  Copyright © 2017年 Jigao Mei. All rights reserved.
//

#import "JGPhotoBrowser.h"
#import "JGPhotoView.h"
#import "JGPhotoToolbar.h"
#import <SDWebImage/SDWebImagePrefetcher.h>

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface JGPhotoBrowser () <UIScrollViewDelegate, JGPhotoViewDelegate>

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) NSMutableSet<JGPhotoView *> *visiblePhotoViews, *reusablePhotoViews;
@property (nonatomic, strong) JGPhotoToolbar *toolbar;

@end

@implementation JGPhotoBrowser

/**
 内存管理处理，管理方式：show显示时存入数组，单机隐藏时移出数组
 
 ARC外部无内存管理时（如：局部初始化后设置参数并调用show显示）
 如不做处理，本类实例会立即释放内存，JGPhotoView设置的photoViewDelegate释放以及无法切换显示图片
 JGPhotoView的photoViewDelegate释放导致不响应代理方法
 */
static NSMutableArray<JGPhotoBrowser *> *showingBrowser = nil;

#pragma mark - init M
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            showingBrowser = [[NSMutableArray alloc] init];
        });
        
        _showSaveBtn = YES;
    }
    
    return self;
}

- (void)dealloc {
    
}

#pragma mark - get M
- (UIView *)view {
    
    if (!_view) {
        _view = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        _view.backgroundColor = [UIColor blackColor];
    }
    
    return _view;
}

- (UIScrollView *)photoScrollView {
    
    if (!_photoScrollView) {
        
        CGRect frame = self.view.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
    }
    
    return _photoScrollView;
}

- (JGPhotoToolbar *)toolbar {
    
    if (!_toolbar) {
        
        CGFloat barHeight = 49;
        CGFloat barY = self.view.frame.size.height - barHeight;
        _toolbar = [[JGPhotoToolbar alloc] init];
        _toolbar.showSaveBtn = _showSaveBtn;
        _toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _toolbar;
}

- (void)show {
    
    [showingBrowser addObject:self];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    //初始化数据
    {
        if (!_visiblePhotoViews) {
            _visiblePhotoViews = [NSMutableSet set];
        }
        if (!_reusablePhotoViews) {
            _reusablePhotoViews = [NSMutableSet set];
        }
        self.toolbar.photos = self.photos;
        
        CGRect frame = self.view.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);
        self.photoScrollView.contentSize = CGSizeMake(frame.size.width * self.photos.count, 0);
        self.photoScrollView.contentOffset = CGPointMake(self.currentPhotoIndex * frame.size.width, 0);
        
        [self.view addSubview:self.photoScrollView];
        [self.view addSubview:self.toolbar];
        [self updateTollbarState];
        [self showPhotos];
    }
    
    //渐变显示
    self.view.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.view.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

#pragma mark - set M
- (void)setPhotos:(NSArray *)photos {
    
    _photos = photos;
    if (_photos.count <= 0) {
        return;
    }
    
    [_photos enumerateObjectsUsingBlock:^(JGPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.index = idx;
    }];
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex {
    
    _currentPhotoIndex = currentPhotoIndex;
    if (_photoScrollView) {
        
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}

#pragma mark - Show Photos
- (void)showPhotos {
    
    CGRect visibleBounds = _photoScrollView.bounds;
    NSInteger firstIndex = floorf((CGRectGetMinX(visibleBounds) + kPadding * 2) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = floorf((CGRectGetMaxX(visibleBounds) - kPadding * 2 - 1) / CGRectGetWidth(visibleBounds));
    firstIndex = MIN(MAX(0, firstIndex), _photos.count - 1);
    firstIndex = MIN(MAX(0, lastIndex), _photos.count - 1);
    
    // 回收不再显示的ImageView
    __block NSInteger photoViewIndex = 0;
    [_visiblePhotoViews enumerateObjectsUsingBlock:^(JGPhotoView * _Nonnull obj, BOOL * _Nonnull stop) {
        
        photoViewIndex = kPhotoViewIndex(obj);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            
            [_reusablePhotoViews addObject:obj];
            [obj removeFromSuperview];
        }
    }];
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        
        if (![self isShowingPhotoViewAtIndex:index]) {
            
            [self showPhotoViewAtIndex:index];
        }
    }
    
}

//  显示一个图片view
- (void)showPhotoViewAtIndex:(NSInteger)index {
    
    JGPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) {
        
        // 添加新的图片view
        photoView = [[JGPhotoView alloc] init];
    }
    photoView.photoViewDelegate = self;
    
    // 调整当前页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    JGPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

//  加载index附近的图片
- (void)loadImageNearIndex:(NSInteger)index {
    
    if (index > 0) {
        
        JGPhoto *photo = _photos[index - 1];
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:(SDWebImageRetryFailed | SDWebImageLowPriority) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
            //do nothing
        }];
    }
    
    if (index < _photos.count - 1) {
        
        JGPhoto *photo = _photos[index + 1];
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:(SDWebImageRetryFailed | SDWebImageLowPriority) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
            //do nothing
        }];
    }
}

//  index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    
    __block BOOL isShow = NO;
    [_visiblePhotoViews enumerateObjectsUsingBlock:^(JGPhotoView * _Nonnull obj, BOOL * _Nonnull stop) {
        
        isShow = kPhotoViewIndex(obj) == index;
        *stop = isShow;
    }];
    
    return  isShow;
}

// 重用页面
- (JGPhotoView *)dequeueReusablePhotoView {
    
    JGPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        
        [_reusablePhotoViews removeObject:photoView];
    }
    
    return photoView;
}

#pragma mark - updateTollbarState
- (void)updateTollbarState {
    
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - JGPhotoViewDelegate
- (void)photoViewImageFinishLoad:(JGPhotoView *)photoView {
    
    [self updateTollbarState];
}

- (void)photoViewSingleTap:(JGPhotoView *)photoView {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    // 移除工具条
    [self.toolbar removeFromSuperview];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
        [showingBrowser removeObject:self];
    }];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self showPhotos];
    [self updateTollbarState];
}

@end
