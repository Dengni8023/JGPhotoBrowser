//
//  JGPBBrowserController.m
//  JGPhotoBrowser
//
//  Created by Mei Jigao on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "JGPBBrowserController.h"
#import "JGSourceBase.h"
#import "JGPBPhoto.h"
#import "JGPBPhotoView.h"
#import "JGPBPhotoToolView.h"
#import "JGPBPhotoInfoView.h"
#import "FLAnimatedImageView+WebCache.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import "JGPBStatusView.h"

#define JGPBPhotoViewTagOffset 1000
#define JGPBPhotoViewIndex(photoView) (photoView.tag - JGPBPhotoViewTagOffset)

@interface JGPBBrowserController () <UIScrollViewDelegate, JGPBPhotoViewDelegate>

// 所有的图片对象
@property (nonatomic, strong) NSArray<JGPBPhoto *> *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentIndex;
// 保存按钮
@property (nonatomic, assign) NSUInteger showSaveBtn;
// 显示浮层
@property (nonatomic, assign) BOOL showTools;

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) NSMutableSet<JGPBPhotoView *> *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet<JGPBPhotoView *> *reusablePhotoViews;
@property (nonatomic, strong) JGPBStatusView *statusView;
@property (nonatomic, strong) JGPBPhotoToolView *phToolView;
@property (nonatomic, strong) JGPBPhotoInfoView *phInfoView;

@end

@implementation JGPBBrowserController

static const char JGPBBrowserWindowKey = '\0';

/**
 内存管理处理，全局管理内存，外部不需要管理内存
 */
static NSMutableArray<JGPBBrowserController *> *showingBrowser = nil;

#pragma mark - init
- (instancetype)initWithPhotos:(NSArray<JGPBPhoto *> *)photos index:(NSInteger)curIndex {
    return [self initWithPhotos:photos index:curIndex showSave:YES];
}

- (instancetype)initWithPhotos:(NSArray<JGPBPhoto *> *)photos index:(NSInteger)curIndex showSave:(BOOL)showSaveBtn {
    
    self = [super init];
    if (self) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            showingBrowser = [[NSMutableArray alloc] init];
        });
        
        _showTools = YES;
        _photos = photos;
        _currentIndex = curIndex;
        _showSaveBtn = showSaveBtn;
        
        [self initDatas];
    }
    
    return self;
}

- (void)initDatas {
    
    [_photos enumerateObjectsUsingBlock:^(JGPBPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.index = idx;
    }];
}

- (void)dealloc {
    
    //JGSCLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewElements];
}

#pragma mark - Control
- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return [self photoBrowserWindow].alpha == 1.f;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - View
- (void)setupViewElements {
    
    // mask
    self.view.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _maskView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.view addSubview:_maskView];
    
    // scroll
    _photoScrollView = [[UIScrollView alloc] init];
    _photoScrollView.pagingEnabled = YES;
    _photoScrollView.delegate = self;
    _photoScrollView.showsHorizontalScrollIndicator = NO;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_photoScrollView];
    
    // status
    _statusView = [[JGPBStatusView alloc] init];
    [self.view addSubview:_statusView];
    _statusView.hidden = YES;
    
    // tool
    _phToolView = [[JGPBPhotoToolView alloc] initWithPhotosCount:_photos.count index:_currentIndex];
    [self.view addSubview:_phToolView];
    
    JGSCWeak(self)
    _phToolView.showSaveBtn = _showSaveBtn;
    if ([self photoHasExtraText]) {
        _phToolView.closeShowAction = ^{
            JGSCStrong(self);
            [self closePhotoShow];
        };
    }
    _phToolView.saveShowPhotoAction = ^(NSInteger index) {
        JGSCStrong(self);
        [self saveCurrentShowPhoto];
    };
    
    // extra
    if ([self photoHasExtraText]) {
        
        _phInfoView = [[JGPBPhotoInfoView alloc] init];
        [self.view addSubview:_phInfoView];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _maskView.frame = self.view.bounds;
    _statusView.frame = self.view.bounds;
    
    _photoScrollView.frame = self.view.bounds;
    CGFloat viewW = CGRectGetWidth(self.view.bounds);
    _photoScrollView.contentSize = CGSizeMake(viewW * _photos.count, 0);
    _photoScrollView.contentOffset = CGPointMake(_currentIndex * viewW, 0);
    
    if (_showTools) {
        
        BOOL topTool = [self photoHasExtraText];
        UIEdgeInsets safeInsets = [self viewSafeAreaInsets];
        _phToolView.frame = CGRectMake(0, topTool ? safeInsets.top : (CGRectGetHeight(self.view.bounds) - 49 - safeInsets.bottom), CGRectGetWidth(self.view.bounds), topTool ? 44 : 49);
        _phToolView.browserSafeAreaInsets = UIEdgeInsetsMake(topTool ? safeInsets.top : 0, 0, topTool ? 0 : safeInsets.bottom, 0);
        
        _phInfoView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 80 - safeInsets.bottom, CGRectGetWidth(self.view.bounds), 80);
        _phInfoView.browserSafeAreaInsets = UIEdgeInsetsMake(0, 0, safeInsets.bottom, 0);
    }
}

- (UIEdgeInsets)viewSafeAreaInsets {
    
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

#pragma mark - Getter
- (BOOL)photoHasExtraText {
    
    for (JGPBPhoto *photo in _photos) {
        if (photo.extraText.length > 0) {
            return YES;
        }
    }
    return NO;
}

- (UIWindow *)photoBrowserWindow {
    
    UIWindow *window = objc_getAssociatedObject(self, &JGPBBrowserWindowKey);
    if (!window) {
        window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        objc_setAssociatedObject(self, &JGPBBrowserWindowKey, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return window;
}

#pragma mark - Show
- (void)show {
    
    UIWindow *window = [self photoBrowserWindow];
    window.hidden = NO;
    window.alpha = 0;
    window.rootViewController = self;
    [self.view layoutIfNeeded];
    
    //初始化数据
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [showingBrowser addObject:self];
    
    _visiblePhotoViews = _visiblePhotoViews ?: [NSMutableSet set];
    _reusablePhotoViews = _reusablePhotoViews ?: [NSMutableSet set];
    
    CGFloat viewW = CGRectGetWidth(self.view.bounds);
    _photoScrollView.contentSize = CGSizeMake(viewW * _photos.count, 0);
    _photoScrollView.contentOffset = CGPointMake(_currentIndex * viewW, 0);
    
    [self updateTollbarState];
    [self showPhotos];
    
    //渐变显示
    window.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        
        window.alpha = 1.0;
        [self setNeedsStatusBarAppearanceUpdate];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showPhotos {
    
    CGRect visibleBounds = _photoScrollView.bounds;
    NSInteger firstIndex = floorf((CGRectGetMinX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = floorf((CGRectGetMaxX(visibleBounds) - 1) / CGRectGetWidth(visibleBounds));
    firstIndex = MIN(MAX(0, firstIndex), _photos.count - 1);
    lastIndex = MIN(MAX(0, lastIndex), _photos.count - 1);
    
    // 回收不再显示的ImageView
    __block NSInteger photoViewIndex = 0;
    JGSCWeak(self)
    [_visiblePhotoViews enumerateObjectsUsingBlock:^(JGPBPhotoView * _Nonnull obj, BOOL * _Nonnull stop) {
        
        photoViewIndex = JGPBPhotoViewIndex(obj);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            JGSCStrong(self);
            [self.reusablePhotoViews addObject:obj];
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
    
    JGPBPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) {
        
        // 添加新的图片view
        photoView = [[JGPBPhotoView alloc] init];
    }
    photoView.photoViewDelegate = self;
    
    // 调整当前页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.origin.x = (bounds.size.width * index);
    photoView.tag = JGPBPhotoViewTagOffset + index;
    
    JGPBPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

//  加载index附近的图片
- (void)loadImageNearIndex:(NSInteger)index {
    
    if (index > 0) {
        
        JGPBPhoto *photo = _photos[index - 1];
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:(SDWebImageRetryFailed | SDWebImageLowPriority) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
            //do nothing
        }];
    }
    
    if (index < _photos.count - 1) {
        
        JGPBPhoto *photo = _photos[index + 1];
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:(SDWebImageRetryFailed | SDWebImageLowPriority) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
            //do nothing
        }];
    }
}

//  index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    
    __block BOOL isShow = NO;
    [_visiblePhotoViews enumerateObjectsUsingBlock:^(JGPBPhotoView * _Nonnull obj, BOOL * _Nonnull stop) {
        
        isShow = JGPBPhotoViewIndex(obj) == index;
        *stop = isShow;
    }];
    
    return  isShow;
}

// 重用页面
- (JGPBPhotoView *)dequeueReusablePhotoView {
    
    JGPBPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        
        [_reusablePhotoViews removeObject:photoView];
    }
    
    return photoView;
}

#pragma mark - phToolView
- (void)updateTollbarState {
    
    _currentIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    [_phToolView changeCurrentIndex:_currentIndex indexsaved:_photos[_currentIndex].saved];
    _phInfoView.text = _photos[_currentIndex].extraText;
}

- (void)closePhotoShow {
    
    UIWindow *window = [self photoBrowserWindow];
    [UIView animateWithDuration:0.3 animations:^{
        
        window.alpha = 0;
        [self setNeedsStatusBarAppearanceUpdate];
        
    } completion:^(BOOL finished) {
        
        window.hidden = YES;
        window.rootViewController = nil;
        [showingBrowser removeObject:self];
    }];
}

- (void)saveCurrentShowPhoto {
    
    JGSCWeak(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 保存相片到相册
        JGSCStrong(self);
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        if (authorizationStatus == PHAuthorizationStatusAuthorized) {
            
            [self saveShowingImageToPhotoLibrary];
        }
        else if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
            
            JGSCWeak(self)
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                JGSCStrong(self);
                if (status == PHAuthorizationStatusAuthorized) {
                    
                    [self saveShowingImageToPhotoLibrary];
                }
                else {
                    
                    JGSCWeak(self)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        JGSCStrong(self);
                        [self changePhotoStatusViewWithStatus:JGPBPhotoStatusPrivacy];
                    });
                }
            }];
        }
        else {
            
            JGSCWeak(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                
                JGSCStrong(self);
                [self changePhotoStatusViewWithStatus:JGPBPhotoStatusPrivacy];
            });
        }
    });
}

- (void)saveShowingImageToPhotoLibrary {
    
    JGSCWeak(self)
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        JGSCStrong(self);
        JGPBPhoto *showPhoto = [self.photos objectAtIndex:self.currentIndex];
        NSData *saveData = showPhoto.GIFImage.data ?: UIImageJPEGRepresentation(showPhoto.image, 1.f);
        if (@available(iOS 9.0, *)) {
            
            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
            [request addResourceWithType:PHAssetResourceTypePhoto data:saveData options:nil];
        }
        else {
            
            NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
            NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:temporaryFileName];
            NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
            NSError *error = nil;
            [saveData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
            
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
            [[NSFileManager defaultManager] removeItemAtURL:temporaryFileURL error:nil];
        }
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            JGSCStrong(self);
            BOOL saved = success && !error ? YES : NO;
            JGPBPhoto *showPhoto = [self.photos objectAtIndex:self.currentIndex];
            showPhoto.saved = saved ? YES : NO;
            [self.phToolView changeCurrentIndex:self.currentIndex indexsaved:saved];
            
            [self changePhotoStatusViewWithStatus:saved ? JGPBPhotoStatusSaveSuccess : JGPBPhotoStatusSaveFail];
        });
    }];
}

- (void)changePhotoStatusViewWithStatus:(JGPBPhotoStatus)status {
    
    _statusView.hidden = NO;
    _statusView.alpha = 1.f;
    [_statusView showWithStatus:status];
    
    JGSCWeak(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        JGSCStrong(self);
        [UIView animateWithDuration:0.2 animations:^{
            self.statusView.alpha = 0;
        } completion:^(BOOL finished) {
            self.statusView.hidden = YES;
        }];
    });
}

#pragma mark - JGPBPhotoViewDelegate
- (void)photoViewImageFinishLoad:(JGPBPhotoView *)photoView {
    
    [self updateTollbarState];
}

- (void)photoViewSingleTap:(JGPBPhotoView *)photoView {
    
    if ([self photoHasExtraText]) {
        
        _showTools = !_showTools;
        UIEdgeInsets safeInsets = [self viewSafeAreaInsets];
        
        CGFloat toolY = safeInsets.top, hideY = -(safeInsets.top + CGRectGetHeight(_phToolView.frame));
        CGFloat extraY = CGRectGetHeight(self.view.bounds) - (CGRectGetHeight(self.phInfoView.frame) + safeInsets.bottom);
        CGFloat extraHideY = CGRectGetHeight(self.view.bounds);
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.phToolView.frame = CGRectMake(0, self.showTools ? toolY : hideY, CGRectGetWidth(self.phToolView.frame), CGRectGetHeight(self.phToolView.frame));
            self.phInfoView.frame = CGRectMake(0, self.showTools ? extraY : extraHideY, CGRectGetWidth(self.phInfoView.frame), CGRectGetHeight(self.phInfoView.frame));
        }];
    }
    else {
        
        [self closePhotoShow];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self showPhotos];
    [self updateTollbarState];
}

#pragma mark - End

@end

@implementation JGPhotoBrowser

@end
