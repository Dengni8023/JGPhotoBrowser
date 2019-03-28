//
//  UIViewController+JGSPhotoBrowser.m
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSPhotoBrowser.h"
#import "JGSourceBase.h"
#import "JGSPhotoView.h"
#import "JGSPhotoToolView.h"
#import "JGSPhotoDescriptionView.h"
#import "FLAnimatedImageView+WebCache.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import "JGSPhotoStatusView.h"

CGFloat JGSPhotoBrowserDescriptionHeight = 86;
FOUNDATION_EXTERN void JGSPhotoBrowserSetDescriptionHeight(CGFloat descriptionHeight) {
    JGSPhotoBrowserDescriptionHeight = descriptionHeight > 44 ? descriptionHeight : 86;
}

@interface JGSPhotoBrowser () <UIScrollViewDelegate, JGSPhotoViewDelegate>

@property (nonatomic, assign) BOOL showTools; // 显示浮层
@property (nonatomic, assign) BOOL showImgDesc; // 显示图片介绍文字

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) NSMutableSet<JGSPhotoView *> *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet<JGSPhotoView *> *reusablePhotoViews;
@property (nonatomic, strong) JGSPhotoStatusView *statusView;
@property (nonatomic, strong) JGSPhotoToolView *photoToolView;
@property (nonatomic, strong) JGSPhotoDescriptionView *photoDescView;

@end

@implementation JGSPhotoBrowser

static const NSInteger JGSPhotoViewTagOffset = 1000;
static const char JGSBrowserWindowKey = '\0';

/**
 内存管理处理，全局管理内存，外部不需要管理内存
 */
static NSMutableArray<JGSPhotoBrowser *> *showingBrowser = nil;

#pragma mark - Life Cycle
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self initialize];
        
        self.showTools = YES;
        self.showSaveBtn = YES;
    }
    return self;
}

- (instancetype)initWithPhotos:(NSArray<JGSPhoto *> *)photos index:(NSInteger)curIndex {
    return [self initWithPhotos:photos index:curIndex showSave:YES];
}

- (instancetype)initWithPhotos:(NSArray<JGSPhoto *> *)photos index:(NSInteger)curIndex showSave:(BOOL)showSaveBtn {
    
    self = [super init];
    if (self) {
        
        [self initialize];
        
        self.showTools = YES;
        self.photos = photos;
        self.currentIndex = curIndex;
        self.showSaveBtn = showSaveBtn;
    }
    return self;
}

- (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        showingBrowser = [[NSMutableArray alloc] init];
    });
}

- (void)setPhotos:(NSArray<JGSPhoto *> *)photos {
    
    _photos = photos;
    [self.photos enumerateObjectsUsingBlock:^(JGSPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.index = idx;
        self.showImgDesc = (self.showImgDesc || obj.imgDescription.length > 0);
    }];
}

- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewElements];
}

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
    _statusView = [[JGSPhotoStatusView alloc] init];
    [self.view addSubview:_statusView];
    _statusView.hidden = YES;
    
    // tool
    _photoToolView = [[JGSPhotoToolView alloc] initWithPhotosCount:_photos.count index:_currentIndex];
    [self.view addSubview:_photoToolView];
    
    JGSWeakSelf
    self.photoToolView.showSaveBtn = self.showSaveBtn;
    if (self.showImgDesc) {
        self.photoToolView.closeShowAction = ^{
            JGSStrongSelf
            [self closePhotoShow];
        };
    }
    self.photoToolView.saveShowPhotoAction = ^(NSInteger index) {
        JGSStrongSelf
        [self saveCurrentShowPhoto];
    };
    
    // image description
    if (self.showImgDesc) {
        self.photoDescView = [[JGSPhotoDescriptionView alloc] init];
        [self.view addSubview:self.photoDescView];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat viewW = CGRectGetWidth(self.view.frame);
    CGFloat viewH = CGRectGetHeight(self.view.frame);
    CGRect viewRect = CGRectMake(0, 0, viewW, viewH);
    self.maskView.frame = viewRect;
    self.statusView.frame = viewRect;
    
    self.photoScrollView.frame = viewRect;
    self.photoScrollView.contentSize = CGSizeMake(viewW * self.photos.count, 0);
    self.photoScrollView.contentOffset = CGPointMake(self.currentIndex * viewW, 0);
    
    if (self.showTools) {
        
        UIEdgeInsets safeInsets = [self viewSafeAreaInsets];
        
        CGFloat toolHeight = self.showImgDesc ? (44 + safeInsets.top) : (49 + safeInsets.bottom);
        self.photoToolView.frame = CGRectMake(0, self.showImgDesc ? 0 : (viewH - toolHeight), viewW, toolHeight);
        self.photoToolView.contentInset = UIEdgeInsetsMake(self.showImgDesc ? safeInsets.top : 0, safeInsets.left, self.showImgDesc ? 0 : safeInsets.bottom, safeInsets.right);
        
        CGFloat descHeight = JGSPhotoBrowserDescriptionHeight + safeInsets.bottom;
        self.photoDescView.frame = CGRectMake(0, viewH - descHeight, viewW, descHeight);
        self.photoDescView.contentInset = UIEdgeInsetsMake(0, safeInsets.left, safeInsets.bottom, safeInsets.right);
    }
}

- (UIEdgeInsets)viewSafeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (UIWindow *)photoBrowserWindow {
    UIWindow *window = objc_getAssociatedObject(self, &JGSBrowserWindowKey);
    if (!window) {
        window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        objc_setAssociatedObject(self, &JGSBrowserWindowKey, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    
    self.visiblePhotoViews = self.visiblePhotoViews ?: [NSMutableSet set];
    self.reusablePhotoViews = self.reusablePhotoViews ?: [NSMutableSet set];
    
    CGFloat viewW = CGRectGetWidth(self.view.bounds);
    self.photoScrollView.contentSize = CGSizeMake(viewW * self.photos.count, 0);
    self.photoScrollView.contentOffset = CGPointMake(self.currentIndex * viewW, 0);
    
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
    
    CGRect visibleBounds = self.photoScrollView.bounds;
    NSInteger firstIndex = floorf((CGRectGetMinX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = floorf((CGRectGetMaxX(visibleBounds) - 1) / CGRectGetWidth(visibleBounds));
    firstIndex = MIN(MAX(0, firstIndex), self.photos.count - 1);
    lastIndex = MIN(MAX(0, lastIndex), self.photos.count - 1);
    
    // 回收不再显示的ImageView
    __block NSInteger photoViewIndex = 0;
    JGSWeakSelf
    [self.visiblePhotoViews enumerateObjectsUsingBlock:^(JGSPhotoView * _Nonnull obj, BOOL * _Nonnull stop) {
        
        photoViewIndex = obj.tag - JGSPhotoViewTagOffset;
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            JGSStrongSelf
            [self.reusablePhotoViews addObject:obj];
            [obj removeFromSuperview];
        }
    }];
    
    [self.visiblePhotoViews minusSet:self.reusablePhotoViews];
    while (self.reusablePhotoViews.count > 2) {
        [self.reusablePhotoViews removeObject:[self.reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:index];
        }
    }
}

//  显示一个图片view
- (void)showPhotoViewAtIndex:(NSInteger)index {
    
    JGSPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) {
        // 添加新的图片view
        photoView = [[JGSPhotoView alloc] init];
    }
    photoView.photoViewDelegate = self;
    
    // 调整当前页的frame
    CGRect bounds = self.photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.origin.x = (bounds.size.width * index);
    photoView.tag = JGSPhotoViewTagOffset + index;
    
    JGSPhoto *photo = self.photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    self.photoDescView.hidden = photo.imgDescription.length == 0;
    [self.visiblePhotoViews addObject:photoView];
    [self.photoScrollView addSubview:photoView];
    [self loadImageNearIndex:index];
}

//  加载index附近的图片
- (void)loadImageNearIndex:(NSInteger)index {
    
    if (index > 0) {
        JGSPhoto *photo = self.photos[index - 1];
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:(SDWebImageRetryFailed | SDWebImageLowPriority) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            //do nothing
        }];
    }
    
    if (index < self.photos.count - 1) {
        
        JGSPhoto *photo = self.photos[index + 1];
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:(SDWebImageRetryFailed | SDWebImageLowPriority) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            //do nothing
        }];
    }
}

//  index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    
    __block BOOL isShow = NO;
    [self.visiblePhotoViews enumerateObjectsUsingBlock:^(JGSPhotoView * _Nonnull obj, BOOL * _Nonnull stop) {
        
        isShow = (obj.tag - JGSPhotoViewTagOffset == index);
        *stop = isShow;
    }];
    return  isShow;
}

// 重用页面
- (JGSPhotoView *)dequeueReusablePhotoView {
    
    JGSPhotoView *photoView = [self.reusablePhotoViews anyObject];
    if (photoView) {
        [self.reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

#pragma mark - phToolView
- (void)updateTollbarState {
    
    self.currentIndex = self.photoScrollView.contentOffset.x / self.photoScrollView.frame.size.width;
    [self.photoToolView changeCurrentIndex:self.currentIndex indexSaved:self.photos[self.currentIndex].saved];
    self.photoDescView.text = self.photos[self.currentIndex].imgDescription;
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
    
    JGSWeakSelf
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 保存相片到相册
        JGSStrongSelf
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        if (authorizationStatus == PHAuthorizationStatusAuthorized) {
            [self saveShowingImageToPhotoLibrary];
        }
        else if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
            
            JGSWeakSelf
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                JGSStrongSelf
                if (status == PHAuthorizationStatusAuthorized) {
                    [self saveShowingImageToPhotoLibrary];
                }
                else {
                    JGSWeakSelf
                    dispatch_async(dispatch_get_main_queue(), ^{
                        JGSStrongSelf
                        [self changePhotoStatusViewWithStatus:JGSPhotoStatusPrivacy];
                    });
                }
            }];
        }
        else {
            
            JGSWeakSelf
            dispatch_async(dispatch_get_main_queue(), ^{
                JGSStrongSelf
                [self changePhotoStatusViewWithStatus:JGSPhotoStatusPrivacy];
            });
        }
    });
}

- (void)saveShowingImageToPhotoLibrary {
    
    JGSWeakSelf
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        JGSStrongSelf
        JGSPhoto *showPhoto = [self.photos objectAtIndex:self.currentIndex];
        NSData *saveData = showPhoto.GIFImage.data ?: UIImageJPEGRepresentation(showPhoto.image, 1.f);
        
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        [request addResourceWithType:PHAssetResourceTypePhoto data:saveData options:nil];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            JGSStrongSelf
            BOOL saved = success && !error ? YES : NO;
            JGSPhoto *showPhoto = [self.photos objectAtIndex:self.currentIndex];
            showPhoto.saved = saved ? YES : NO;
            [self.photoToolView changeCurrentIndex:self.currentIndex indexSaved:saved];
            
            [self changePhotoStatusViewWithStatus:saved ? JGSPhotoStatusSaveSuccess : JGSPhotoStatusSaveFail];
        });
    }];
}

- (void)changePhotoStatusViewWithStatus:(JGSPhotoStatus)status {
    
    self.statusView.hidden = NO;
    self.statusView.alpha = 1.f;
    [self.statusView showWithStatus:status];
    
    JGSWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JGSStrongSelf
        [UIView animateWithDuration:0.2 animations:^{
            self.statusView.alpha = 0;
        } completion:^(BOOL finished) {
            self.statusView.hidden = YES;
        }];
    });
}

#pragma mark - JGSPhotoViewDelegate
- (void)photoViewImageFinishLoad:(JGSPhotoView *)photoView {
    [self updateTollbarState];
}

- (void)photoViewSingleTap:(JGSPhotoView *)photoView {
    
    if (self.showImgDesc) {
        
        self.showTools = !self.showTools;
        CGFloat viewH = CGRectGetHeight(self.view.frame);
        
        CGRect toolRect = self.photoToolView.frame;
        toolRect.origin.y = self.showTools ? 0 : -CGRectGetHeight(toolRect);
        
        CGRect descRect = self.photoDescView.frame;
        descRect.origin.y = viewH - (self.showTools ? CGRectGetHeight(descRect) : 0);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.photoToolView.frame = toolRect;
            self.photoDescView.frame = descRect;
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
